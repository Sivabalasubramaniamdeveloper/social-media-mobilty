import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import '../models/vault_item_model.dart';

class VaultDatabaseService {
  static final VaultDatabaseService instance = VaultDatabaseService._();
  VaultDatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mineai_private_vault.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vault_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            account_username TEXT,
            website_url TEXT,
            notes TEXT,
            file_name TEXT,
            file_size INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  int getMaxPhotos(PlanTier tier) {
    switch (tier) {
      case PlanTier.premium:
        return 20;
      case PlanTier.pro:
        return 10;
      case PlanTier.basic:
        return 0; // Free plan cannot save photos
    }
  }

  int getMaxDocuments(PlanTier tier) {
    switch (tier) {
      case PlanTier.premium:
        return 30;
      case PlanTier.pro:
        return 10;
      case PlanTier.basic:
        return 0; // Free plan cannot save documents
    }
  }

  Future<int> getItemCount(String userId, String type) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vault_items WHERE user_id = ? AND type = ?',
      [userId, type],
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<bool> canAddItem(String userId, String type, PlanTier tier) async {
    if (type == 'password') return true; // Passwords allowed on all plans

    final count = await getItemCount(userId, type);
    if (type == 'photo') {
      return count < getMaxPhotos(tier);
    } else if (type == 'document') {
      return count < getMaxDocuments(tier);
    }
    return false;
  }

  Future<int> insertItem(VaultItemModel item) async {
    final db = await database;
    return await db.insert('vault_items', item.toMap());
  }

  Future<List<VaultItemModel>> getItems(String userId, {String? type}) async {
    final db = await database;
    if (type != null && type.isNotEmpty && type != 'all') {
      final res = await db.query(
        'vault_items',
        where: 'user_id = ? AND type = ?',
        whereArgs: [userId, type],
        orderBy: 'id DESC',
      );
      return res.map((m) => VaultItemModel.fromMap(m)).toList();
    } else {
      final res = await db.query(
        'vault_items',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );
      return res.map((m) => VaultItemModel.fromMap(m)).toList();
    }
  }

  Future<void> deleteItem(VaultItemModel item) async {
    final db = await database;
    if (item.id != null) {
      await db.delete('vault_items', where: 'id = ?', whereArgs: [item.id]);
    }
    // Delete local cached media if exists
    if ((item.type == 'photo' || item.type == 'document') &&
        item.content.isNotEmpty) {
      try {
        final f = File(item.content);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {}
    }
  }
}
