import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uob_attendance/core/theme/app_settings.dart';

Future<ProviderContainer> container([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('defaults: Arabic, system theme', () async {
    final s = (await container()).read(appSettingsProvider);
    expect(s.locale, const Locale('ar'));
    expect(s.themeMode, ThemeMode.system);
  });

  test('persists theme and language', () async {
    final c = await container();
    await c.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.dark);
    await c.read(appSettingsProvider.notifier).setLanguage('en');
    await c.read(appSettingsProvider.notifier).setLanguage('fr'); // ignored
    expect(c.read(appSettingsProvider).themeMode, ThemeMode.dark);
    expect(c.read(appSettingsProvider).locale, const Locale('en'));
    final prefs = c.read(sharedPreferencesProvider);
    expect(prefs.getString(AppSettingsController.themeKey), 'dark');
    expect(prefs.getString(AppSettingsController.localeKey), 'en');
  });

  test('restores saved values and ignores garbage', () async {
    final c = await container({AppSettingsController.themeKey: 'light', AppSettingsController.localeKey: 'xx'});
    expect(c.read(appSettingsProvider).themeMode, ThemeMode.light);
    expect(c.read(appSettingsProvider).locale, const Locale('ar'));
  });
}
