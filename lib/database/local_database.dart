// 640510612 Natchanon Jina
// 640510675 Poomiputh Boonma

import 'database.dart';

/// Singleton sqlite database class for storing user data locally using Drift package.
class LocalDatabase {
  final AppDatabase _database = AppDatabase();

  static final LocalDatabase _instance = LocalDatabase._internal();

  factory LocalDatabase() {
    return _instance;
  }

  AppDatabase get database => _database;

  LocalDatabase._internal();
}
