import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../auth/application/auth_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../students/application/students_providers.dart';
import '../application/edit_requests_providers.dart';
import '../domain/edit_request.dart';

/// طلبات التعديل (stage managers and admins): approve — which changes the
/// record, the stats and the lecture — or reject, with an optional note.
class EditRequestsScreen extends ConsumerStatefulWidget {
  const EditRequestsScreen({super.key});

  @override
  ConsumerState<EditRequestsScreen> createState() => _EditRequestsScreenState();
}

class _EditRequestsScreenState extends ConsumerState<EditRequestsScreen> {
  StageRef? _stage;
  final _busy = <String>{};

  Future<void> _decide(EditRequest r, {required bool approve}) async {
    final l10n = context.l10n;
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(approve: approve),
    );
    if (note == null || !mounted) return;
    setState(() => _busy.add(r.id));
    try {
      final repo = ref.read(editRequestsRepositoryProvider);
      final actor = ref.read(signedInUserProvider).id;
      if (approve) {
        await repo.approve(r, note: note, actor: actor);
      } else {
        await repo.reject(r, note: note, actor: actor);
      }
      if (mounted) showSnack(context, approve ? l10n.editRequestApproved : l10n.editRequestRejected);
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editRequestsTitle)),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<StageRef>(
                    key: const Key('requests.stage'),
                    initialValue: stage,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                    items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                    onChanged: (s) => setState(() => _stage = s),
                  ),
                ),
                Expanded(child: _list(stage)),
              ],
            ),
    );
  }

  Widget _list(StageRef stage) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final m = MaterialLocalizations.of(context);
    final names = {for (final s in ref.watch(stageStudentsProvider(stage.id)).value ?? const []) s.id: s.fullName};
    final courses = {for (final c in ref.watch(stageCoursesProvider(stage.id)).value ?? const []) c.id: c.name};
    return AsyncBody<List<EditRequest>>(
      value: ref.watch(pendingEditRequestsProvider(stage.id)),
      data: (requests) => requests.isEmpty
          ? Center(child: MessageView(icon: Icons.inbox, title: l10n.editRequestsEmpty))
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                for (final r in requests)
                  Card(
                    key: Key('request.${r.id}'),
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(names[r.studentId] ?? r.studentId, style: Theme.of(context).textTheme.titleMedium),
                          if (EditRequest.parseSession(r.sessionId) case final p?)
                            Text(l10n.editRequestLecture(
                              courses[p.courseId] ?? p.courseId,
                              DocIds.parseDateKey(p.dateKey) == null ? p.dateKey : m.formatMediumDate(DocIds.parseDateKey(p.dateKey)!),
                              p.lectureNo,
                            )),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (r.currentStatus case final from?) ...[
                                _status(context, from, palette),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  // Mirrors with the text direction: points from «now» to «requested».
                                  child: Icon(Icons.arrow_forward, size: 18),
                                ),
                              ],
                              _status(context, r.requestedStatus, palette),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(l10n.editRequestWhy(r.reason)),
                          Text(r.requestedBy, textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                key: Key('request.reject.${r.id}'),
                                onPressed: _busy.contains(r.id) ? null : () => _decide(r, approve: false),
                                child: Text(l10n.editRequestReject),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                key: Key('request.approve.${r.id}'),
                                onPressed: _busy.contains(r.id) ? null : () => _decide(r, approve: true),
                                child: Text(l10n.editRequestApprove),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _status(BuildContext context, AttendanceStatus s, StatusPalette palette) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(StatusPalette.iconForStatus(s), color: palette.forStatus(s), size: 18),
          const SizedBox(width: 4),
          Text(context.l10n.attendance(s)),
        ],
      );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.approve});

  final bool approve;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.approve ? l10n.editRequestApprove : l10n.editRequestReject),
      content: TextField(
        key: const Key('request.note'),
        controller: _note,
        decoration: InputDecoration(labelText: l10n.editRequestNote),
        maxLength: 300,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('request.confirm'),
          onPressed: () => Navigator.pop(context, _note.text),
          child: Text(widget.approve ? l10n.editRequestApprove : l10n.editRequestReject),
        ),
      ],
    );
  }
}
