// Source of web/drift_worker.js (Drift's web worker), compiled by
// tool/build_drift_web.sh so it always matches the pinned drift version.
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
