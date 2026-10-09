#!/usr/bin/env bash
# Prepares Drift's web runtime files in web/ (both git-ignored):
#   * web/drift_worker.js — compiled here from tool/drift_worker.dart.
#   * web/sqlite3.wasm    — downloaded from the sqlite3.dart GitHub release that
#                           matches the resolved `sqlite3` package version.
# Only needed if the local database is used on the web (phase 2+); the admin
# web panel works without it.
set -euo pipefail
cd "$(dirname "$0")/.."
dart compile js -O4 -o web/drift_worker.js tool/drift_worker.dart
rm -f web/drift_worker.js.deps web/drift_worker.js.map
version=$(awk '/^  sqlite3:$/{f=1} f && /version:/{gsub(/[" ]|version:/, ""); print; exit}' pubspec.lock)
url="https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-${version}/sqlite3.wasm"
echo "Downloading $url"
if ! curl -fSL -o web/sqlite3.wasm "$url"; then
  echo "Could not download sqlite3.wasm (github.com may be blocked here)." >&2
  echo "Download it manually from $url into web/sqlite3.wasm" >&2
  exit 1
fi
