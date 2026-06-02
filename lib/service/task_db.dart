import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/data.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();

  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdAt  DEFAULT CURRENT_TIMESTAMP,
        taskName TEXT NOT NULL,
        priority INTEGER NOT NULL,
        habit INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE metadata(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks RENAME TO tasks_old');
      await db.execute('''
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          createdAt  DEFAULT CURRENT_TIMESTAMP,
          taskName TEXT NOT NULL,
          priority INTEGER NOT NULL,
          habit INTEGER NOT NULL,
          completed INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        INSERT INTO tasks (id, taskName, priority, habit, completed)
        SELECT
          id,
          taskName,
          CASE
            WHEN priority = 'high' THEN 3
            WHEN priority = 'medium' THEN 2
            WHEN priority = 'low' THEN 1
            ELSE COALESCE(CAST(priority AS INTEGER), 1)
          END,
          habit,
          completed
        FROM tasks_old
      ''');
      await db.execute('DROP TABLE tasks_old');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS metadata(
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return Task(
      id,
      task.taskName,
      task.priority,
      task.habit,
      isCompleted: task.isCompleted,
    );
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'id DESC');
    return result.map(Task.fromMap).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetDailyTasks() async {
    final db = await database;
    await db.update('tasks', {'completed': 0}, where: 'habit = ?', whereArgs: [1]);
    await db.delete('tasks', where: 'habit = ?', whereArgs: [0]);
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final rows = await db.query('metadata', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'metadata',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
