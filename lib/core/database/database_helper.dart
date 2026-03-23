import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taminotchi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0 for false, 1 for true

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        parentId $nullableTextType,
        data $textType
      )
    ''');

    // Groups Table
    await db.execute('''
      CREATE TABLE chat_groups (
        id $idType,
        categoryId $textType,
        data $textType
      )
    ''');

    // Posts Table
    await db.execute('''
      CREATE TABLE posts (
        id $idType,
        categoryId $nullableTextType,
        data $textType,
        createdAt $textType
      )
    ''');

    // Cached Images Table
    await db.execute('''
      CREATE TABLE cached_images (
        url $idType,
        localPath $textType,
        downloadedAt $textType,
        expiresAt $textType
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
