import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Shorebird patches cannot change assets, and the MaterialIcons font is
/// tree-shaken to the icons the code uses: adding an icon *or dropping the
/// last use of one* changes the font, and `patch.yml` then refuses the patch
/// after a 15-minute build (happened with the home tiles). This catches it
/// in CI instead.
///
/// `tool/release_icons.txt` is the set in the release the patches target
/// (1.5.0+25, commit 35833cc; the same set as 1.4.0+18). After a new APK release, regenerate it:
/// `git grep -ohE "Icons\.[a-z_0-9]+" <release commit> -- lib | sort -u > tool/release_icons.txt`
void main() {
  test('lib/ uses exactly the icons of the release that patches target', () {
    final release = File('tool/release_icons.txt')
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toSet();
    final pattern = RegExp(r'Icons\.[a-z_0-9]+');
    final used = <String>{
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
        if (f.path.endsWith('.dart')) ...pattern.allMatches(f.readAsStringSync()).map((m) => m[0]!),
    };
    expect(used.difference(release), isEmpty, reason: 'icons the release lacks (they show blank in a patch)');
    expect(release.difference(used), isEmpty, reason: 'release icons no longer used (the font changes)');
  });
}
