import 'dart:math' as math;

/// What the admin is fixing.
enum FixKind { student, course, teacher }

/// Why a fix cannot run (shown in the preview).
enum FixProblem {
  invalidId,
  sameId,
  notFound,

  /// The new ID belongs to a different record (another name).
  targetExists,

  /// An admin changing their own e-mail would lock themselves out.
  ownAccount,

  /// Deletion: everything selected has attendance history.
  nothingToDelete,

  /// Deleting one account that recorded lectures (suspend it instead).
  hasHistory,
}

/// Counters of the preview («سيُنقل: …»).
enum FixCount { students, courses, users, groups, assignments, sessions, records, stats, leaves, kept }

enum FixOp { set, merge, update, delete }

/// One Firestore write of a fix. Values may hold Firestore sentinels.
final class FixWrite {
  const FixWrite.set(this.path, this.data) : op = FixOp.set;
  const FixWrite.merge(this.path, this.data) : op = FixOp.merge;
  const FixWrite.update(this.path, this.data) : op = FixOp.update;
  const FixWrite.delete(this.path)
      : op = FixOp.delete,
        data = const {};

  final FixOp op;
  final String path;
  final Map<String, Object?> data;

  @override
  String toString() => '${op.name} $path';
}

/// The preview of a fix and the writes that carry it out.
///
/// [phases] run in order and never share a batch: the rules check some
/// parents with `get()` (a group's course, an assignment's group and
/// teacher), which only sees committed data. Within a phase each item —
/// e.g. «copy this record to the new ID and delete the old one» — goes into
/// one batch when it fits, so an interrupted fix can simply be run again.
final class FixPlan {
  const FixPlan({
    this.problems = const [],
    this.counts = const {},
    this.phases = const [],
    this.mergeInto,
  });

  FixPlan.refused(FixProblem problem, {String? name})
      : problems = [problem],
        counts = const {},
        phases = const [],
        mergeInto = name;

  final List<FixProblem> problems;
  final Map<FixCount, int> counts;
  final List<List<List<FixWrite>>> phases;

  /// Name of the existing record the old one is merged into (or, with
  /// [FixProblem.targetExists], the other record's name).
  final String? mergeInto;

  bool get canApply => problems.isEmpty && writeCount > 0;
  int get writeCount => phases.fold(0, (n, p) => n + p.fold(0, (m, item) => m + item.length));

  /// Batches of at most [limit] writes (Firestore allows 500), phase by
  /// phase. Items are kept whole when they fit; a larger item is split in
  /// order (its copies come before its deletes).
  static List<List<FixWrite>> pack(List<List<List<FixWrite>>> phases, {int limit = 450}) {
    final batches = <List<FixWrite>>[];
    for (final phase in phases) {
      var current = <FixWrite>[];
      for (final item in phase) {
        if (current.isNotEmpty && current.length + item.length > limit) {
          batches.add(current);
          current = <FixWrite>[];
        }
        if (item.length <= limit) {
          current.addAll(item);
          continue;
        }
        for (var i = 0; i < item.length; i += limit) {
          batches.add(item.sublist(i, math.min(i + limit, item.length)));
        }
      }
      if (current.isNotEmpty) batches.add(current);
    }
    return batches;
  }
}
