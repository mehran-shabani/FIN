import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> createDatabaseConnection() async {
Future<QueryExecutor> createDatabaseConnection() async {
  try {
    final result = await WasmDatabase.open(
      databaseName: 'finsnap_db',
      // relative paths => safe under subpaths
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  } catch (e) {
    // optionally hook into your logger instead of throwing a generic Exception
    throw Exception('Failed to init WasmDatabase: $e');
  }
}
}