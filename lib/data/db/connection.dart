import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Abre o banco real: SQLite nativo no Android; sqlite3.wasm + IndexedDB na Web.
QueryExecutor openAppConnection() => driftDatabase(
      name: 'finance_hub',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
