import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/expenses/models/expense_model.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mindai_expenses.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            time TEXT NOT NULL,
            update_time TEXT NOT NULL,
            note TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'time DESC');
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }
}
