#!/usr/bin/env bash
# Everything CI should run: static analysis, Dart/Flutter tests, and the
# Firestore security-rules tests on the emulator.
set -euo pipefail
cd "$(dirname "$0")/.."
./tool/ensure_firebase_options.sh
flutter analyze
flutter test --timeout 120s
firebase emulators:exec --only firestore --project demo-uob-attendance "npm --prefix rules-tests test"
