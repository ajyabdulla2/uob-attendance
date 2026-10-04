import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/core/utils/arabic_text.dart';

void main() {
  group('ArabicText', () {
    test('converts Arabic-Indic and Persian digits', () {
      expect(ArabicText.normalizeDigits('٢٠٢٦ و ۱۲'), '2026 و 12');
    });

    test('normalizes spelling variants for comparison', () {
      expect(ArabicText.normalizeForCompare('  أحمـــد   عليّ  '), ArabicText.normalizeForCompare('احمد علي'));
      expect(ArabicText.normalizeForCompare('فاطمة'), ArabicText.normalizeForCompare('فاطمه'));
      expect(ArabicText.normalizeForCompare('مصطفى'), ArabicText.normalizeForCompare('مصطفي'));
      expect(ArabicText.normalizeForCompare('إسراء'), ArabicText.normalizeForCompare('اسراء'));
      expect(ArabicText.normalizeForCompare('عبد الله حسن'), ArabicText.normalizeForCompare('عبدالله حسن'));
      expect(ArabicText.normalizeForCompare('Ali  HASAN'), 'ali hasan');
    });

    test('counts words', () {
      expect(ArabicText.wordCount(' علي  حسين جاسم محمد '), 4);
      expect(ArabicText.wordCount(''), 0);
    });

    test('sortKey orders alphabetically and places a transferred student in sequence', () {
      final names = {
        'زينب علي': '3',
        'أحمد كريم': '1',
        'باقر حسن': '2',
        'إبراهيم سعد': '9', // transferred later, higher ID
      };
      final sorted = names.entries.map((e) => ArabicText.sortKey(e.key, e.value)).toList()..sort();
      expect(sorted.map((k) => k.split('|').last), ['9', '1', '2', '3']);
    });
  });

  group('StageRef', () {
    test('has eight stages with ids level-shift', () {
      expect(StageRef.all, hasLength(8));
      expect(StageRef.all.first.id, '1-morning');
      expect(StageRef.all.last.id, '4-evening');
    });

    test('parses valid ids only', () {
      expect(StageRef.tryParse('3-evening'), const StageRef(3, Shift.evening));
      expect(StageRef.tryParse('5-morning'), isNull);
      expect(StageRef.tryParse('3-night'), isNull);
      expect(StageRef.tryParse(null), isNull);
      expect(() => StageRef.parse('x'), throwsFormatException);
    });
  });

  group('DocIds (mirrored in firestore.rules)', () {
    test('user ids are lower-cased e-mails', () {
      expect(DocIds.user('  Ali.H@UoBasrah.edu.IQ '), 'ali.h@uobasrah.edu.iq');
    });

    test('university ids are normalized', () {
      expect(DocIds.normalizeUniversityId(' ٢٠٢٦ ٠٠١ '), '2026001');
      expect(DocIds.normalizeUniversityId('2026001.0'), '2026001');
      expect(DocIds.normalizeUniversityId('CS/2026/1'), 'CS-2026-1');
    });

    test('course, group, assignment, session and stat ids', () {
      final course = DocIds.course('cs 301', '3-morning');
      expect(course, 'CS301_3-morning');
      expect(DocIds.group(course, 'A'), 'CS301_3-morning__A');
      expect(
        DocIds.assignment(courseId: course, type: 'practical', target: 'A', teacherId: 'T@x.iq'),
        'CS301_3-morning__practical__A__t@x.iq',
      );
      expect(
        DocIds.session(courseId: course, type: 'theory', target: 'all', date: DateTime(2026, 10, 4, 15), lectureNo: 2),
        'CS301_3-morning__theory__all__20261004__2',
      );
      expect(DocIds.stat(course, '2026001'), 'CS301_3-morning__2026001');
    });
  });
}
