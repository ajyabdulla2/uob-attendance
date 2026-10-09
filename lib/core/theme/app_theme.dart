import 'package:flutter/material.dart';

import '../../features/attendance/domain/attendance_session.dart';
import '../../features/stats/domain/student_course_stat.dart';

/// Material 3 theme with the Cairo font, in light and dark variants.
abstract final class AppTheme {
  /// Deep university blue.
  static const seed = Color(0xFF0D3B66);
  static const fontFamily = 'Cairo';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final radius = BorderRadius.circular(12);
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: radius),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      extensions: [
        brightness == Brightness.light ? StatusPalette.light : StatusPalette.dark,
      ],
    );
  }
}

/// Colour + icon for every attendance status and warning level. Status is
/// never conveyed by colour alone (SPEC «رمز + لون»).
@immutable
class StatusPalette extends ThemeExtension<StatusPalette> {
  const StatusPalette({
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.alert,
    required this.warning,
    required this.dismissal,
  });

  final Color present;
  final Color absent;
  final Color late;
  final Color excused;
  final Color alert;
  final Color warning;
  final Color dismissal;

  static const light = StatusPalette(
    present: Color(0xFF1B7F3B),
    absent: Color(0xFFC62828),
    late: Color(0xFFB26A00),
    excused: Color(0xFF1565C0),
    alert: Color(0xFFF9A825),
    warning: Color(0xFFEF6C00),
    dismissal: Color(0xFFB71C1C),
  );

  static const dark = StatusPalette(
    present: Color(0xFF66BB6A),
    absent: Color(0xFFEF5350),
    late: Color(0xFFFFB74D),
    excused: Color(0xFF64B5F6),
    alert: Color(0xFFFFEE58),
    warning: Color(0xFFFFA726),
    dismissal: Color(0xFFFF8A80),
  );

  static StatusPalette of(BuildContext context) =>
      Theme.of(context).extension<StatusPalette>() ?? light;

  Color forStatus(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => present,
        AttendanceStatus.absent => absent,
        AttendanceStatus.late => late,
        AttendanceStatus.excused => excused,
      };

  static IconData iconForStatus(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => Icons.check_circle,
        AttendanceStatus.absent => Icons.cancel,
        AttendanceStatus.late => Icons.schedule,
        AttendanceStatus.excused => Icons.verified_user,
      };

  Color? forLevel(WarningLevel l) => switch (l) {
        WarningLevel.none => null,
        WarningLevel.alert => alert,
        WarningLevel.warning => warning,
        WarningLevel.dismissal => dismissal,
      };

  static IconData iconForLevel(WarningLevel l) => switch (l) {
        WarningLevel.none => Icons.check,
        WarningLevel.alert => Icons.info,
        WarningLevel.warning => Icons.warning_amber,
        WarningLevel.dismissal => Icons.block,
      };

  @override
  StatusPalette copyWith({
    Color? present,
    Color? absent,
    Color? late,
    Color? excused,
    Color? alert,
    Color? warning,
    Color? dismissal,
  }) =>
      StatusPalette(
        present: present ?? this.present,
        absent: absent ?? this.absent,
        late: late ?? this.late,
        excused: excused ?? this.excused,
        alert: alert ?? this.alert,
        warning: warning ?? this.warning,
        dismissal: dismissal ?? this.dismissal,
      );

  @override
  StatusPalette lerp(StatusPalette? other, double t) {
    if (other == null) return this;
    return StatusPalette(
      present: Color.lerp(present, other.present, t)!,
      absent: Color.lerp(absent, other.absent, t)!,
      late: Color.lerp(late, other.late, t)!,
      excused: Color.lerp(excused, other.excused, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      dismissal: Color.lerp(dismissal, other.dismissal, t)!,
    );
  }
}
