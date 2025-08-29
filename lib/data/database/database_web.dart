import 'package:drift/drift.dart';
import 'package:drift/web.dart';

Future<QueryExecutor> createDatabaseConnection() async {
  return WebDatabase('finsnap_db');
}