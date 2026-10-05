#!/usr/bin/env bash
# Idempotent setup for Claude Code cloud sessions (and any fresh Linux box):
#   * installs the Flutter SDK into /opt/flutter-sdk (from storage.googleapis.com,
#     which is reachable from the cloud environment; github.com is not),
#   * fetches packages, creates the placeholder firebase_options.dart,
#   * installs the rules-test npm deps and the Firestore emulator.
# On a developer's Windows/macOS machine it only does the last three steps
# (Flutter must already be installed and on PATH).
# Usage:  source tool/cloud_setup.sh   (so PATH is exported to your shell)
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.6}"
if [[ "$(uname -s)" != Linux* ]] && ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not on PATH. This script installs it on Linux only;" \
    "install Flutter $FLUTTER_VERSION yourself, then run it again." >&2
  return 1 2>/dev/null || exit 1
fi
set -euo pipefail
SDK_DIR="/opt/flutter-sdk"
export PATH="$SDK_DIR/flutter/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  mkdir -p "$SDK_DIR"
  archive="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  curl -fSL -o "$SDK_DIR/$archive" \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$archive"
  tar -xf "$SDK_DIR/$archive" -C "$SDK_DIR"
  rm "$SDK_DIR/$archive"
  git config --global --add safe.directory "$SDK_DIR/flutter"
  flutter --disable-analytics >/dev/null 2>&1 || true
fi
flutter --version

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"
./tool/ensure_firebase_options.sh
flutter pub get
(cd rules-tests && npm install --no-audit --no-fund)
firebase setup:emulators:firestore >/dev/null 2>&1 || echo "warning: could not pre-download the Firestore emulator"
echo "Ready. PATH now includes $SDK_DIR/flutter/bin"
