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

  // Insert user row if it doesn't exist
  Future<void> insertUserIfNotExists(String userId, String email) async {
    final db = await database;
    final result = await db.query(
      'Users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) {
      await db.insert("Users", {
        'id': userId,
        'firstName': '',
        'lastName': '',
        'email': email,
        'profile_picture': null,
      });
      log("Inserted new user $userId into SQLite");
    }
  }

  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = '${getDirectory.path}/users.db';
    log("DB Path: $path");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users(
        id TEXT PRIMARY KEY,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        profile_picture TEXT
      )
    ''');
    log('TABLE CREATED');
  }

  // Insert or replace user
  Future<void> insertOrUpdateUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      "Users",
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update only profile picture
  Future<void> updateProfilePicture(String userId, String imagePath) async {
    final db = await database;
    await db.update(
      'Users',
      {'profile_picture': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
    log('Profile picture updated for $userId');
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final result =
    await db.query('Users', where: 'id = ?', whereArgs: [userId], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }
}