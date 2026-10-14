import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../../leaves/domain/leave.dart';
import '../../stats/domain/absence_summary.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';
import '../domain/attendance_session.dart';

/// One class's register as stored on the server — what the admins open
/// from «متابعة التدريسيين» (the teacher's own register lives on the phone).
final class ServerRegister {
  const ServerRegister({
    required this.assignment,
    required this.courseName,
    required this.students,
    required this.sessions,
    required this.marks,
    required this.standings,
    required this.year,
  });

  final Assignment assignment;
  final String courseName;
  final List<Student> students;
  final List<AttendanceSession> sessions;

  /// session → student → status.
  final Map<String, Map<String, AttendanceStatus>> marks;
  final Map<String, AbsenceSummary> standings;
  final AcademicYear? year;
}

/// Reads one class from Firestore (admins read everything): the students
/// who attend it, its lectures with their records, and each student's
/// percentage in the course. About one read per lecture plus the stage's
/// students, stats and leaves — loaded only when an admin opens it.
class ServerRegisterRepository {
  ServerRegisterRepository(this._fs);

  final FirebaseFirestore _fs;

  /// The teacher's classes, by course then type and target.
  Future<List<Assignment>> classesOf(String teacherId) async {
    final snap = await _fs.collection(Col.assignments).where('teacherId', isEqualTo: teacherId).get();
    return [for (final d in snap.docs) Assignment.fromMap(d.id, d.data())]
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<ServerRegister?> loadById(String assignmentId) async {
    final snap = await _fs.collection(Col.assignments).doc(assignmentId).get();
    if (!snap.exists) return null;
    return load(Assignment.fromMap(snap.id, snap.data()!));
  }

  Future<ServerRegister> load(Assignment a) async {
    final yearSnap = await _fs.collection(Col.academicYears).where('active', isEqualTo: true).limit(1).get();
    final year = yearSnap.docs.isEmpty ? null : AcademicYear.fromMap(yearSnap.docs.first.id, yearSnap.docs.first.data());
    final courseSnap = await _fs.collection(Col.courses).doc(a.courseId).get();
    final course = courseSnap.exists ? Course.fromMap(courseSnap.id, courseSnap.data()!) : null;

    PracticalGroup? group;
    if (a.groupId != null) {
      final g = await _fs.collection(Col.groups).doc(a.groupId).get();
      if (g.exists) group = PracticalGroup.fromMap(g.id, g.data()!);
    }
    final studentSnap = await _fs.collection(Col.students).where('stageId', isEqualTo: a.stageId).get();
    final students = [
      for (final d in studentSnap.docs)
        if (Student.fromMap(d.id, d.data()) case final s
            when s.attendsLectures &&
                switch (a.type) {
                  AssignmentType.practical => group?.studentIds.contains(s.id) ?? false,
                  AssignmentType.theory => a.target == DocIds.allSections || s.section == a.target,
                })
          s,
    ]..sort(Student.compare);

    final sessionSnap = await _fs
        .collection(Col.sessions)
        .where('courseId', isEqualTo: a.courseId)
        .where('type', isEqualTo: a.type.name)
        .where('target', isEqualTo: a.target)
        .get();
    final sessions = [for (final d in sessionSnap.docs) AttendanceSession.fromMap(d.id, d.data())]
      ..sort((x, y) => x.date != y.date ? x.date.compareTo(y.date) : x.lectureNo.compareTo(y.lectureNo));
    final records = await Future.wait([
      for (final d in sessionSnap.docs) d.reference.collection(Col.records).get(),
    ]);
    final marks = {
      for (final (i, d) in sessionSnap.docs.indexed)
        d.id: {
          for (final r in records[i].docs)
            if (AttendanceRecord.fromMap(r.id, r.data()) case final rec) rec.studentId: rec.status,
        },
    };

    final standings = <String, AbsenceSummary>{};
    if (year != null && course != null) {
      final stats = await _fs
          .collection(Col.stats)
          .where('stageId', isEqualTo: a.stageId)
          .where('courseId', isEqualTo: a.courseId)
          .get();
      final bySession = {
        for (final d in stats.docs)
          if (StudentCourseStat.fromMap(d.id, d.data()) case final s) s.studentId: s.bySession,
      };
      final leaveSnap = await _fs.collection(Col.leaves).where('stageId', isEqualTo: a.stageId).get();
      final leaves = <String, List<Leave>>{};
      for (final d in leaveSnap.docs) {
        final l = Leave.fromMap(d.id, d.data());
        if (l.isApproved) (leaves[l.studentId] ??= []).add(l);
      }
      for (final s in students) {
        standings[s.id] = AbsenceSummary.of(
          bySession: bySession[s.id] ?? const {},
          leaves: leaves[s.id] ?? const [],
          units: course.units,
          year: year,
          stageId: course.stageId,
          type: year.combinedTheoryPractical ? null : a.type.name,
        );
      }
    }
    return ServerRegister(
      assignment: a,
      courseName: course?.name ?? (a.courseName.isEmpty ? a.courseId : a.courseName),
      students: students,
      sessions: sessions,
      marks: marks,
      standings: standings,
      year: year,
    );
  }
}
