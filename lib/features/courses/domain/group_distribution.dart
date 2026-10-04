import '../../students/domain/student.dart';

/// Distributes students over [groupCount] practical groups «بالتساوي أبجدياً»:
/// students are sorted alphabetically (by sortKey) and cut into contiguous
/// blocks whose sizes differ by at most one (earlier groups get the extra).
///
/// Students who do not attend lectures (محمَّل، مؤجل، منسحب…) are skipped.
List<List<Student>> distributeAlphabetically(Iterable<Student> students, int groupCount) {
  if (groupCount < 1) throw ArgumentError.value(groupCount, 'groupCount', 'must be ≥ 1');
  final sorted = students.where((s) => s.attendsLectures).toList()..sort(Student.compare);
  final base = sorted.length ~/ groupCount;
  final extra = sorted.length % groupCount;
  final groups = <List<Student>>[];
  var start = 0;
  for (var g = 0; g < groupCount; g++) {
    final size = base + (g < extra ? 1 : 0);
    groups.add(sorted.sublist(start, start + size));
    start += size;
  }
  return groups;
}
