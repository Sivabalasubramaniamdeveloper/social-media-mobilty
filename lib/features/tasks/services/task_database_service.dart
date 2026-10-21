import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class TaskDatabaseService {
  static final TaskDatabaseService instance = TaskDatabaseService._();
  TaskDatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mineai_tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            date_display TEXT NOT NULL,
            date_iso TEXT,
            time_display TEXT NOT NULL,
            time_iso TEXT,
            location TEXT,
            details TEXT,
            is_completed INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    final db = await database;
    final res = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return res.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<void> toggleTaskCompleted(int id, bool completed) async {
    final db = await database;
    await db.update(
      'tasks',
      {'is_completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
