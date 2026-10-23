import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/email_helper_model.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';

class EmailHelperDatabaseService {
  static final EmailHelperDatabaseService instance =
      EmailHelperDatabaseService._();
  EmailHelperDatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mineai_saved_emails.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_emails (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            label TEXT NOT NULL,
            subject TEXT NOT NULL,
            body TEXT NOT NULL,
            tone TEXT NOT NULL,
            recipient TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Returns max allowed saved emails per subscription plan tier:
  /// Basic: 5, Pro: 20, Premium: 50
  int getMaxLimitForTier(PlanTier tier) {
    switch (tier) {
      case PlanTier.pro:
        return 20;
      case PlanTier.premium:
        return 50;
      case PlanTier.basic:
        return 5;
    }
  }

  Future<int> getSavedEmailCount(String userId) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as count FROM saved_emails WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<bool> canSaveMore(String userId, PlanTier tier) async {
    final count = await getSavedEmailCount(userId);
    final limit = getMaxLimitForTier(tier);
    return count < limit;
  }

  Future<int> insertEmail(SavedEmailModel email) async {
    final db = await database;
    return await db.insert('saved_emails', email.toMap());
  }

  Future<List<SavedEmailModel>> getSavedEmails(String userId) async {
    final db = await database;
    final maps = await db.query(
      'saved_emails',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SavedEmailModel.fromMap(m)).toList();
  }

  Future<int> deleteEmail(int id) async {
    final db = await database;
    return await db.delete('saved_emails', where: 'id = ?', whereArgs: [id]);
  }
}
