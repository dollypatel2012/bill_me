import 'package:mysql1/mysql1.dart';

class MysqlService {
  static final MysqlService _instance = MysqlService._internal();
  factory MysqlService() => _instance;
  MysqlService._internal();

  MySqlConnection? _connection;

  Future<MySqlConnection> get connection async {
    // If we have an open connection, return it
    if (_connection != null) {
      try {
        // Try a simple query to check if connection is still alive
        await _connection!.query('SELECT 1');
        return _connection!;
      } catch (e) {
        // Connection is dead, close and reconnect
        await _closeQuietly();
      }
    }
    // Create a new connection
    _connection = await _connect();
    return _connection!;
  }

  Future<MySqlConnection> _connect() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',           // your MySQL username
      password: 'password', // your MySQL password
      db: 'bill_me_db',
    );
    try {
      return await MySqlConnection.connect(settings);
    } catch (e) {
      print('Connection error: $e');
      rethrow;
    }
  }

  Future<void> _closeQuietly() async {
    try {
      await _connection?.close();
    } catch (_) {}
    _connection = null;
  }

  Future<void> close() async {
    await _closeQuietly();
  }
}