import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded in `main()` before `runApp` and injected with an override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

/// Per-device UI preferences (SPEC: الوضع الليلي، اللغة).
@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale = const Locale('ar')});

  final ThemeMode themeMode;

  /// Arabic by default, English optional.
  final Locale locale;

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) =>
      AppSettings(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale);
}

class AppSettingsController extends Notifier<AppSettings> {
  static const themeKey = 'settings.themeMode';
  static const localeKey = 'settings.locale';
  static const supportedLanguages = ['ar', 'en'];

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final theme = ThemeMode.values.asNameMap()[_prefs.getString(themeKey)] ?? ThemeMode.system;
    final lang = _prefs.getString(localeKey);
    return AppSettings(
      themeMode: theme,
      locale: Locale(supportedLanguages.contains(lang) ? lang! : 'ar'),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(themeKey, mode.name);
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) return;
    state = state.copyWith(locale: Locale(languageCode));
    await _prefs.setString(localeKey, languageCode);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);
