import 'package:flutter/rendering.dart';
import 'package:mineai/features/expenses/models/budget_model.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseDatabaseService {
  static final ExpenseDatabaseService instance = ExpenseDatabaseService._();
  ExpenseDatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mindai_finance_v2.db');
    debugPrint('Database pssath: $path');
    debugPrint('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category_id TEXT NOT NULL,
            time TEXT NOT NULL,
            update_time TEXT NOT NULL,
            note TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            icon TEXT,
            color INTEGER,
            is_custom INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            category_id TEXT NOT NULL,
            allocated_amount REAL NOT NULL,
            month_year TEXT NOT NULL,
            edit_count INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(user_id, category_id, month_year)
          )
        ''');

        await db.execute('''
          CREATE TABLE savings_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            month_year TEXT NOT NULL,
            target_amount REAL NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(user_id, month_year)
          )
        ''');

        await _seedDefaultCategories(db);
      },
    );
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final defaults = [
      // Expense Categories (Expanded)
      {'id': 'dining_and_drinks', 'name': 'Dining & Drinks', 'type': 'expense'},
      {'id': 'groceries', 'name': 'Groceries', 'type': 'expense'},
      {'id': 'transportation', 'name': 'Transportation', 'type': 'expense'},
      {'id': 'shopping', 'name': 'Shopping', 'type': 'expense'},
      {'id': 'entertainment', 'name': 'Entertainment', 'type': 'expense'},
      {
        'id': 'health_and_fitness',
        'name': 'Health & Fitness',
        'type': 'expense',
      },
      {'id': 'utilities', 'name': 'Utilities', 'type': 'expense'},
      {'id': 'education', 'name': 'Education', 'type': 'expense'},
      {'id': 'travel', 'name': 'Travel', 'type': 'expense'},
      {'id': 'personal_care', 'name': 'Personal Care', 'type': 'expense'},
      {'id': 'other_expense', 'name': 'Other', 'type': 'expense'},

      // Income Categories
      {'id': 'monthly_salary', 'name': 'Monthly Salary', 'type': 'income'},
      {'id': 'freelance', 'name': 'Freelance', 'type': 'income'},
      {'id': 'business', 'name': 'Business', 'type': 'income'},
      {'id': 'investments', 'name': 'Investments', 'type': 'income'},
      {'id': 'rental_income', 'name': 'Rental Income', 'type': 'income'},
      {'id': 'bonus', 'name': 'Bonus', 'type': 'income'},
      {'id': 'other_income', 'name': 'Other', 'type': 'income'},
    ];

    for (var cat in defaults) {
      await db.insert('categories', {
        'id': cat['id'],
        'user_id': null,
        'name': cat['name'],
        'type': cat['type'],
        'is_custom': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ==========================================
  // Transactions
  // ==========================================
  Future<int> insertTransaction(TransactionModel item) async {
    final db = await database;
    return await db.insert('transactions', item.toMap());
  }

  Future<int> deleteTransaction(int id, String userId) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final db = await database;
    final res = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time DESC',
    );
    return res.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTransactionsFiltered(
    String userId, {
    String? monthYear,
    String? year,
    String? type,
  }) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (monthYear != null && monthYear.isNotEmpty) {
      whereClause += ' AND time LIKE ?';
      whereArgs.add('$monthYear%');
    } else if (year != null && year.isNotEmpty) {
      whereClause += ' AND time LIKE ?';
      whereArgs.add('$year%');
    }

    if (type != null && type.isNotEmpty && type != 'all') {
      whereClause += ' AND type = ?';
      whereArgs.add(type);
    }

    final res = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'time DESC',
    );
    return res.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<String>> getDistinctYears(String userId) async {
    final db = await database;
    final res = await db.rawQuery(
      '''
      SELECT DISTINCT SUBSTR(time, 1, 4) as year FROM transactions
      WHERE user_id = ?
      ORDER BY year DESC
      ''',
      [userId],
    );
    final years = res
        .map((r) => r['year'] as String?)
        .where((y) => y != null && y.isNotEmpty)
        .cast<String>()
        .toList();
    final currentYear = DateTime.now().year.toString();
    if (!years.contains(currentYear)) {
      years.insert(0, currentYear);
    }
    return years;
  }

  Future<double> getCategorySpentAmount(
    String userId,
    String categoryId,
    String monthYear, // Format: "YYYY-MM" (e.g. "2026-10")
  ) async {
    final db = await database;

    // Uses LIKE so it matches both ISO "YYYY-MM-DDTHH:mm:ss" and standard "YYYY-MM-DD"
    final res = await db.rawQuery(
      '''
    SELECT SUM(amount) as total FROM transactions
    WHERE user_id = ? 
      AND (category_id = ? OR LOWER(category_id) = LOWER(?))
      AND type = 'expense' 
      AND time LIKE ?
    ''',
      [userId, categoryId, categoryId, '$monthYear%'],
    );

    final total = res.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }

  // ==========================================
  // Data Clearing & Management
  // ==========================================
  Future<void> clearAllTransactions(String userId) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAllBudgets(String userId, [String? monthYear]) async {
    final db = await database;
    if (monthYear != null) {
      await db.delete(
        'budgets',
        where: 'user_id = ? AND month_year = ?',
        whereArgs: [userId, monthYear],
      );
    } else {
      await db.delete(
        'budgets',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<void> clearAllExpenseData(String userId) async {
    final db = await database;
    await db.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('budgets', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('savings_goals', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('categories', where: 'user_id = ?', whereArgs: [userId]);
    await _seedDefaultCategories(db);
  }

  Future<void> resetToDefaultCategories(String userId) async {
    final db = await database;
    await db.delete('categories', where: 'user_id = ?', whereArgs: [userId]);
    await _seedDefaultCategories(db);
  }

  // ==========================================
  // Categories
  // ==========================================
  Future<List<CategoryModel>> getCategories(String userId, String type) async {
    final db = await database;
    final res = await db.query(
      'categories',
      where: '(user_id IS NULL OR user_id = ?) AND type = ?',
      whereArgs: [userId, type],
    );
    return res.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<void> insertCustomCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==========================================
  // Budgets
  // ==========================================
  Future<BudgetModel?> getBudget(
    String userId,
    String categoryId,
    String monthYear,
  ) async {
    final db = await database;
    final res = await db.query(
      'budgets',
      where: 'user_id = ? AND category_id = ? AND month_year = ?',
      whereArgs: [userId, categoryId, monthYear],
    );
    if (res.isNotEmpty) {
      return BudgetModel.fromMap(res.first);
    }
    return null;
  }

  Future<List<BudgetModel>> getAllBudgets(
    String userId,
    String monthYear,
  ) async {
    final db = await database;
    final res = await db.query(
      'budgets',
      where: 'user_id = ? AND month_year = ?',
      whereArgs: [userId, monthYear],
    );
    return res.map((m) => BudgetModel.fromMap(m)).toList();
  }

  Future<int> saveOrUpdateBudget(BudgetModel budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks whether budgets exist for [monthYear].
  /// If none exist and [isAutoRefresh] is true, checks the previous month or most recent month
  /// with budgets, and clones those allocations for [monthYear].
  Future<List<BudgetModel>> checkAndAutoRefreshBudgets(
    String userId,
    String monthYear, {
    bool isAutoRefresh = true,
  }) async {
    final currentBudgets = await getAllBudgets(userId, monthYear);
    if (currentBudgets.isNotEmpty || !isAutoRefresh) {
      return currentBudgets;
    }

    final db = await database;
    final pastRes = await db.rawQuery(
      '''
      SELECT month_year FROM budgets
      WHERE user_id = ? AND month_year < ?
      ORDER BY month_year DESC
      LIMIT 1
      ''',
      [userId, monthYear],
    );

    if (pastRes.isEmpty) {
      return [];
    }

    final prevMonthYear = pastRes.first['month_year'] as String;
    final prevBudgets = await getAllBudgets(userId, prevMonthYear);
    final now = DateTime.now();

    for (var pb in prevBudgets) {
      final newBudget = BudgetModel(
        userId: userId,
        categoryId: pb.categoryId,
        allocatedAmount: pb.allocatedAmount,
        monthYear: monthYear,
        editCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await saveOrUpdateBudget(newBudget);
    }

    debugPrint('Auto-refreshed ${prevBudgets.length} budgets from $prevMonthYear to $monthYear for user: $userId');
    return await getAllBudgets(userId, monthYear);
  }

  /// Manually copies budgets from the previous month to [targetMonthYear]
  Future<int> copyBudgetsFromPreviousMonth(
    String userId,
    String targetMonthYear,
  ) async {
    final db = await database;
    final pastRes = await db.rawQuery(
      '''
      SELECT month_year FROM budgets
      WHERE user_id = ? AND month_year < ?
      ORDER BY month_year DESC
      LIMIT 1
      ''',
      [userId, targetMonthYear],
    );

    if (pastRes.isEmpty) return 0;

    final prevMonthYear = pastRes.first['month_year'] as String;
    final prevBudgets = await getAllBudgets(userId, prevMonthYear);
    final now = DateTime.now();

    int copiedCount = 0;
    for (var pb in prevBudgets) {
      final newBudget = BudgetModel(
        userId: userId,
        categoryId: pb.categoryId,
        allocatedAmount: pb.allocatedAmount,
        monthYear: targetMonthYear,
        editCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      await saveOrUpdateBudget(newBudget);
      copiedCount++;
    }


    return copiedCount;
  }


  // ==========================================
  // Savings Goals (Optional)
  // ==========================================
  Future<double?> getSavingsGoal(String userId, String monthYear) async {
    final db = await database;
    final res = await db.query(
      'savings_goals',
      where: 'user_id = ? AND month_year = ?',
      whereArgs: [userId, monthYear],
    );
    if (res.isNotEmpty) {
      return (res.first['target_amount'] as num).toDouble();
    }
    return null;
  }

  Future<void> setSavingsGoal(
    String userId,
    String monthYear,
    double targetAmount,
  ) async {
    final db = await database;
    await db.insert('savings_goals', {
      'user_id': userId,
      'month_year': monthYear,
      'target_amount': targetAmount,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
