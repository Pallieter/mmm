import 'package:mysql_client/mysql_client.dart';

class DatabaseService {
  final String host;
  final int port;
  final String user;
  final String password;
  final String database;

  MySQLConnectionPool? _pool;

  DatabaseService({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.database,
  });

  Future<void> connect() async {
    _pool = MySQLConnectionPool(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: database,
      maxConnections: 10,
    );
  }

  Future<void> close() async {
    await _pool?.close();
  }

  Future<IResultSet> execute(String sql, [Map<String, dynamic>? params]) async {
    if (_pool == null) throw Exception("Database not connected");
    return _pool!.execute(sql, params);
  }

  Future<void> initSchema() async {
    if (_pool == null) throw Exception("Database not connected");

    await _pool!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        display_name VARCHAR(255),
        role VARCHAR(50) NOT NULL
      )
    ''');

    await _pool!.execute('''
      CREATE TABLE IF NOT EXISTS task_nodes (
        id VARCHAR(255) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        parent_id VARCHAR(255),
        children_ids TEXT,
        context VARCHAR(50),
        priority VARCHAR(50),
        owner_id VARCHAR(255),
        access_level VARCHAR(50),
        specific_date DATETIME,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        sort_order INT DEFAULT 0,
        FOREIGN KEY (owner_id) REFERENCES users(id)
      )
    ''');
  }
}
