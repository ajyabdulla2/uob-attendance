import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/diagnostics/error_log.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../application/audit_providers.dart';
import '../domain/audit_entry.dart';

/// سجل التدقيق: who changed what and when, newest first, 50 at a time.
/// Admins see everything (or one stage); stage managers their stages.
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  /// null = the whole department (admins only).
  StageRef? _stage;
  bool _stageChosen = false;
  final _entries = <AuditEntry>[];
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  StageRef? get _effectiveStage {
    final perms = ref.read(permissionsProvider);
    if (_stageChosen) return _stage;
    return perms.isAdmin ? null : perms.manageableStages.firstOrNull;
  }

  Future<void> _reload() async {
    setState(() {
      _entries.clear();
      _cursor = null;
      _done = false;
      _error = null;
    });
    await _more();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    final perms = ref.read(permissionsProvider);
    final stage = _effectiveStage;
    if (stage == null && !perms.isAdmin) return setState(() => _done = true);
    setState(() => _loading = true);
    try {
      final page = await ref.read(auditRepositoryProvider).page(stageId: stage?.id, after: _cursor);
      if (!mounted) return;
      setState(() {
        _entries.addAll(page.entries);
        _cursor = page.cursor;
        _done = page.cursor == null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final stages = perms.manageableStages;
    final stage = _effectiveStage;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionUpdate,
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<StageRef?>(
              key: const Key('audit.stage'),
              initialValue: stage,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
              items: [
                if (perms.isAdmin) DropdownMenuItem<StageRef?>(value: null, child: Text(l10n.auditAllStages)),
                for (final s in stages) DropdownMenuItem<StageRef?>(value: s, child: Text(l10n.stage(s))),
              ],
              onChanged: (s) {
                setState(() {
                  _stage = s;
                  _stageChosen = true;
                });
                _reload();
              },
            ),
          ),
          Expanded(child: _list(context)),
        ],
      ),
    );
  }

  Widget _list(BuildContext context) {
    final l10n = context.l10n;
    if (_error != null && _entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageView(icon: Icons.error_outline, title: l10n.errorGeneric(ErrorLog.describe(_error!))),
            TextButton(
              onPressed: () => showReportDialog(context, ErrorLog.report(ErrorLog.record(_error!))),
              child: Text(l10n.errorDetails),
            ),
          ],
        ),
      );
    }
    if (_entries.isEmpty) {
      return _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(child: MessageView(icon: Icons.inbox, title: l10n.auditEmpty));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400) _more();
        return false;
      },
      child: ListView.builder(
        key: const Key('audit.list'),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _entries.length + 1,
        itemBuilder: (context, i) {
          if (i == _entries.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _done
                      ? Center(child: Text(l10n.auditEnd, style: Theme.of(context).textTheme.bodySmall))
                      : OutlinedButton(onPressed: _more, child: Text(l10n.auditMore)),
            );
          }
          return _EntryTile(entry: _entries[i]);
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final at = entry.at?.toLocal();
    final when = at == null ? '' : '${m.formatMediumDate(at)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(at))}';
    final theme = Theme.of(context);
    return ExpansionTile(
      leading: Icon(_icon(entry.action)),
      title: Text(l10n.auditAction(entry.action)),
      subtitle: Text(
        [when, bidiIsolate(entry.actor), if (entry.stageId != null) l10n.stageId(entry.stageId!)].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      children: [
        SelectableText(entry.targetPath, textDirection: TextDirection.ltr, style: theme.textTheme.bodySmall),
        if (entry.before case final b? when b.isNotEmpty) _fields(context, l10n.auditBefore, b),
        if (entry.after case final a? when a.isNotEmpty) _fields(context, l10n.auditAfter, a),
      ],
    );
  }

  Widget _fields(BuildContext context, String label, Map<String, Object?> fields) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            for (final e in fields.entries)
              Text('${e.key}: ${_show(e.value)}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );

  static String _show(Object? v) => switch (v) {
        Timestamp t => t.toDate().toLocal().toString().substring(0, 16),
        List l => l.map(_show).join('، '),
        Map m => '{${m.entries.map((e) => '${e.key}: ${_show(e.value)}').join('، ')}}',
        null => '—',
        _ => '$v',
      };

  static IconData _icon(String action) => switch (action.split('.').first) {
        'record' || 'editRequest' => Icons.edit_calendar,
        'leave' => Icons.event_available,
        'warnings' => Icons.warning_amber,
        'user' || 'users' => Icons.person_outline,
        'student' || 'students' => Icons.person_outline,
        'course' || 'courses' => Icons.menu_book_outlined,
        'import' => Icons.upload_file,
        'year' => Icons.tune,
        'backup' => Icons.cloud_upload_outlined,
        _ => Icons.schedule,
      };
}
