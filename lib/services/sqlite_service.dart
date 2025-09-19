import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteService {
  static final SQLiteService _sqLiteService = SQLiteService._internal();
  factory SQLiteService() => _sqLiteService;
  SQLiteService._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = '${getDirectory.path}/users.db';
    log(path);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // Create table here
    // Example
    // 'CREATE TABLE Users(id TEXT PRIMARY KEY, name TEXT, email TEXT)'
    await db.execute('''
      
    ''');
    log('TABLE CREATED');
  }

  //CRUD here
}