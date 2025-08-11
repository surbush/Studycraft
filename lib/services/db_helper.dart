import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _dbName = 'studycraft.db';
  static const _dbVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE units (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unit_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        min_marks REAL,
        max_marks REAL,
        difficulty INTEGER,
        FOREIGN KEY (unit_id) REFERENCES units(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        importance INTEGER DEFAULT 2,
        FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
      )
    ''');
  }

  // Subjects CRUD
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return db.query('subjects', orderBy: 'name');
  }

  Future<int> insertSubject(String name) async {
    final db = await database;
    return db.insert('subjects', {'name': name});
  }

  Future<int> updateSubject(int id, String name) async {
    final db = await database;
    return db.update('subjects', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // Units CRUD
  Future<List<Map<String, dynamic>>> getUnits(int subjectId) async {
    final db = await database;
    return db.query('units', where: 'subject_id = ?', whereArgs: [subjectId], orderBy: 'name');
  }

  Future<int> insertUnit(int subjectId, String name) async {
    final db = await database;
    return db.insert('units', {'subject_id': subjectId, 'name': name});
  }

  Future<int> updateUnit(int id, String name) async {
    final db = await database;
    return db.update('units', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUnit(int id) async {
    final db = await database;
    return db.delete('units', where: 'id = ?', whereArgs: [id]);
  }

  // Chapters CRUD
  Future<List<Map<String, dynamic>>> getChapters(int unitId) async {
    final db = await database;
    return db.query('chapters', where: 'unit_id = ?', whereArgs: [unitId], orderBy: 'name');
  }

  Future<int> insertChapter(int unitId, String name, double? minMarks, double? maxMarks, int difficulty) async {
    final db = await database;
    return db.insert('chapters', {
      'unit_id': unitId,
      'name': name,
      'min_marks': minMarks,
      'max_marks': maxMarks,
      'difficulty': difficulty,
    });
  }

  Future<int> updateChapter(int id, String name, double? minMarks, double? maxMarks, int difficulty) async {
    final db = await database;
    return db.update('chapters', {
      'name': name,
      'min_marks': minMarks,
      'max_marks': maxMarks,
      'difficulty': difficulty,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteChapter(int id) async {
    final db = await database;
    return db.delete('chapters', where: 'id = ?', whereArgs: [id]);
  }

  // Topics CRUD
  Future<List<Map<String, dynamic>>> getTopics(int chapterId) async {
    final db = await database;
    return db.query('topics', where: 'chapter_id = ?', whereArgs: [chapterId], orderBy: 'name');
  }

  Future<int> insertTopic(int chapterId, String name, {int completed = 0, int importance = 2}) async {
    final db = await database;
    return db.insert('topics', {
      'chapter_id': chapterId,
      'name': name,
      'completed': completed,
      'importance': importance,
    });
  }

  Future<int> updateTopic(int id, String name, int completed, int importance) async {
    final db = await database;
    return db.update('topics', {
      'name': name,
      'completed': completed,
      'importance': importance,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTopic(int id) async {
    final db = await database;
    return db.delete('topics', where: 'id = ?', whereArgs: [id]);
  }
}
