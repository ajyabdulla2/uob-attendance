import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../leaves/domain/leave.dart';
import '../../stats/domain/absence_summary.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';
import '../domain/course.dart';
import '../domain/practical_group.dart';

/// One student's row in «لوحة المادة».
final class CoursePanelStudent {
  const CoursePanelStudent({required this.student, required this.group, required this.summaries});

  final Student student;

  /// Their practical group in this course, if any.
  final String? group;

  /// Key '' = one percentage for theory and practical together; otherwise
  /// 'theory' and 'practical' (the year's «نسبتان»).
  final Map<String, AbsenceSummary> summaries;

  /// The highest of their percentages (for ordering and the level colour).
  AbsenceSummary? get worst => summaries.values.isEmpty
      ? null
      : summaries.values.reduce((a, b) => b.percent > a.percent ? b : a);
}

/// Everything about one course, read from the server when the panel opens:
/// its classes and teachers, every lecture recorded in it, and its students
/// with their percentages. Lecture details (who was absent) load on demand.
final class CoursePanel {
  const CoursePanel({
    required this.course,
    required this.year,
    required this.classes,
    required this.groups,
    required this.sessions,
    required this.students,
  });

  final Course course;
  final AcademicYear? year;

  /// Theory first, then the practical groups.
  final List<Assignment> classes;
  final List<PracticalGroup> groups;

  /// Newest first.
  final List<AttendanceSession> sessions;
  final List<CoursePanelStudent> students;

  bool get separate => year != null && !year!.combinedTheoryPractical;

  List<Assignment> get theoryClasses => [for (final a in classes) if (a.type == AssignmentType.theory) a];
  List<Assignment> get practicalClasses => [for (final a in classes) if (a.type == AssignmentType.practical) a];

  /// Lectures recorded for [a]'s class (whoever recorded them).
  int lecturesOf(Assignment a) =>
      sessions.where((s) => s.type == a.type && s.target == a.target).length;

  static String _name(Assignment a) => a.teacherName.isEmpty ? a.teacherId : a.teacherName;

  /// Who taught [s]: the teacher who opened it if they teach this course,
  /// else the class's teachers, else the account that opened it.
  String teacherOf(AttendanceSession s) {
    for (final a in classes) {
      if (a.teacherId == s.openedBy) return _name(a);
    }
    final names = [
      for (final a in classes)
        if (a.type == s.type && a.target == s.target) _name(a),
    ];
    return names.isNotEmpty ? names.join('، ') : s.openedBy;
  }

  int count(AttendanceSession s, AttendanceStatus status) => s.counts[status] ?? 0;
}

/// Reads [CoursePanel]. Every query names the stage, so a stage manager's
/// reads pass the rules (`inStageScope(resource.data.stageId)`); equality
/// filters only, so no composite index is needed.
class CoursePanelRepository {
  CoursePanelRepository(this._fs);

  final FirebaseFirestore _fs;

  Future<CoursePanel?> load(String courseId) async {
    final courseSnap = await _fs.collection(Col.courses).doc(courseId).get();
    if (!courseSnap.exists) return null;
    final course = Course.fromMap(courseSnap.id, courseSnap.data()!);
    final stageId = course.stageId;

    final yearSnap = await _fs.collection(Col.academicYears).where('active', isEqualTo: true).limit(1).get();
    final year = yearSnap.docs.isEmpty ? null : AcademicYear.fromMap(yearSnap.docs.first.id, yearSnap.docs.first.data());

    final results = await Future.wait([
      _fs.collection(Col.assignments).where('stageId', isEqualTo: stageId).where('courseId', isEqualTo: courseId).get(),
      _fs.collection(Col.groups).where('stageId', isEqualTo: stageId).where('courseId', isEqualTo: courseId).get(),
      _fs.collection(Col.sessions).where('stageId', isEqualTo: stageId).where('courseId', isEqualTo: courseId).get(),
      _fs.collection(Col.students).where('stageId', isEqualTo: stageId).get(),
      _fs.collection(Col.stats).where('stageId', isEqualTo: stageId).where('courseId', isEqualTo: courseId).get(),
      _fs.collection(Col.leaves).where('stageId', isEqualTo: stageId).get(),
    ]);
    final [assignSnap, groupSnap, sessionSnap, studentSnap, statSnap, leaveSnap] = results;

    final classes = [for (final d in assignSnap.docs) Assignment.fromMap(d.id, d.data())]
      ..sort((a, b) => a.type != b.type
          ? a.type.index.compareTo(b.type.index)
          : a.target != b.target
              ? a.target.compareTo(b.target)
              : a.teacherName.compareTo(b.teacherName));
    final groups = [for (final d in groupSnap.docs) PracticalGroup.fromMap(d.id, d.data())]
      ..sort((a, b) => a.name.compareTo(b.name));
    final sessions = [for (final d in sessionSnap.docs) AttendanceSession.fromMap(d.id, d.data())]
      ..sort((x, y) => x.date != y.date ? y.date.compareTo(x.date) : y.lectureNo.compareTo(x.lectureNo));

    final groupOf = <String, String>{
      for (final g in groups)
        for (final id in g.studentIds) id: g.name,
    };
    final bySession = {
      for (final d in statSnap.docs)
        if (StudentCourseStat.fromMap(d.id, d.data()) case final s) s.studentId: s.bySession,
    };
    final leaves = <String, List<Leave>>{};
    for (final d in leaveSnap.docs) {
      final l = Leave.fromMap(d.id, d.data());
      if (l.isApproved) (leaves[l.studentId] ??= []).add(l);
    }

    AbsenceSummary summary(String studentId, String? type) => AbsenceSummary.of(
          bySession: bySession[studentId] ?? const {},
          leaves: leaves[studentId] ?? const [],
          units: course.units,
          year: year!,
          stageId: stageId,
          type: type,
        );

    final students = [
      for (final d in studentSnap.docs)
        if (Student.fromMap(d.id, d.data()) case final s when s.attendsLectures)
          CoursePanelStudent(
            student: s,
            group: groupOf[s.id],
            summaries: year == null
                ? const {}
                : year.combinedTheoryPractical
                    ? {'': summary(s.id, null)}
                    : {
                        AssignmentType.theory.name: summary(s.id, AssignmentType.theory.name),
                        if (course.hasPractical) AssignmentType.practical.name: summary(s.id, AssignmentType.practical.name),
                      },
          ),
    ]..sort((a, b) => Student.compare(a.student, b.student));

    return CoursePanel(
      course: course,
      year: year,
      classes: classes,
      groups: groups,
      sessions: sessions,
      students: students,
    );
  }

  /// One lecture's marks (one read per student), loaded when it is opened.
  Future<Map<String, AttendanceStatus>> marksOf(String sessionId) async {
    final snap = await _fs.collection(Col.sessions).doc(sessionId).collection(Col.records).get();
    return {
      for (final r in snap.docs)
        if (AttendanceRecord.fromMap(r.id, r.data()) case final rec) rec.studentId: rec.status,
    };
  }
}
