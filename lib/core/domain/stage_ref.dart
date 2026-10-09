/// Morning (صباحي) or evening (مسائي) study.
enum Shift { morning, evening }

/// Identifies one of the eight stages: level 1–4 × morning/evening.
/// The Firestore ID is `"{level}-{shift}"`, e.g. `3-morning`.
final class StageRef implements Comparable<StageRef> {
  const StageRef(this.level, this.shift)
      : assert(level >= minLevel && level <= maxLevel);

  static const minLevel = 1;
  static const maxLevel = 4;

  final int level;
  final Shift shift;

  String get id => '$level-${shift.name}';

  static final List<StageRef> all = [
    for (final shift in Shift.values)
      for (var level = minLevel; level <= maxLevel; level++) StageRef(level, shift),
  ];

  static final _pattern = RegExp(r'^([1-4])-(morning|evening)$');

  static StageRef? tryParse(String? id) {
    final m = _pattern.firstMatch(id ?? '');
    if (m == null) return null;
    return StageRef(int.parse(m[1]!), Shift.values.byName(m[2]!));
  }

  static StageRef parse(String id) =>
      tryParse(id) ?? (throw FormatException('Invalid stage id', id));

  @override
  int compareTo(StageRef other) => shift != other.shift
      ? shift.index.compareTo(other.shift.index)
      : level.compareTo(other.level);

  @override
  bool operator ==(Object other) =>
      other is StageRef && other.level == level && other.shift == shift;

  @override
  int get hashCode => Object.hash(level, shift);

  @override
  String toString() => id;
}
