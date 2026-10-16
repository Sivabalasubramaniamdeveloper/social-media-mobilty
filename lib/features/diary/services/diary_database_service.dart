import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diary_entry_model.dart';

class DiaryDatabaseService {
  static final DiaryDatabaseService instance = DiaryDatabaseService._internal();
  DiaryDatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diary_records.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_entries (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            date TEXT NOT NULL,
            title TEXT,
            content TEXT,
            mood TEXT NOT NULL,
            mood_score INTEGER NOT NULL,
            template_id TEXT NOT NULL,
            gender_preset TEXT,
            image_paths TEXT,
            audio_path TEXT,
            audio_duration INTEGER,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert or Update Entry
  Future<void> upsertEntry(DiaryEntryModel entry) async {
    final db = await database;
    await db.insert(
      'diary_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Entry by Date
  Future<DiaryEntryModel?> getEntryByDate(String userId, String date) async {
    final db = await database;
    final res = await db.query(
      'diary_entries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return DiaryEntryModel.fromMap(res.first);
    }
    return null;
  }

  // Fetch All Entries for a User (Ordered Latest First)
  Future<List<DiaryEntryModel>> getEntries(String userId) async {
    final db = await database;
    final res = await db.query(
      'diary_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return res.map((m) => DiaryEntryModel.fromMap(m)).toList();
  }

  // Fetch Entries within a Date Range (for Month & Week)
  Future<List<DiaryEntryModel>> getEntriesRange(
    String userId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final res = await db.query(
      'diary_entries',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return res.map((m) => DiaryEntryModel.fromMap(m)).toList();
  }

  // Delete an Entry Locally
  Future<int> deleteEntry(String entryId) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  // One-click Migration to Supabase
  Future<int> syncLocalEntriesToSupabase(String userId) async {
    final db = await database;
    final unsynced = await db.query(
      'diary_entries',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );

    int count = 0;
    for (final row in unsynced) {
      try {
        final entry = DiaryEntryModel.fromMap(row);
        await Supabase.instance.client.from('diary_entries').upsert({
          'id': entry.id,
          'user_id': entry.userId,
          'date': entry.date,
          'title': entry.title,
          'content': entry.content,
          'mood': entry.mood,
          'mood_score': entry.moodScore,
          'template_id': entry.templateId,
          'gender_preset': entry.genderPreset,
          'audio_duration': entry.audioDuration,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Mark as synced locally
        await db.update(
          'diary_entries',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [entry.id],
        );
        count++;
      } catch (e) {
        // Continue with the remaining items if one fails
      }
    }
    return count;
  }

  /// Calculates percentage distribution of the 4 core emotions from local SQLite
  Future<Map<String, double>> getCoreEmotionsDistribution(String userId) async {
    final entries = await getEntries(userId);
    if (entries.isEmpty) {
      return {'happy': 0.0, 'sad': 0.0, 'calm': 0.0, 'anxious': 0.0};
    }

    int happyCount = 0;
    int sadCount = 0;
    int calmCount = 0;
    int anxiousCount = 0;

    for (final entry in entries) {
      final mood = entry.mood.toLowerCase();
      if (mood.contains('happy')) {
        happyCount++;
      } else if (mood.contains('sad')) {
        sadCount++;
      } else if (mood.contains('calm')) {
        calmCount++;
      } else if (mood.contains('stressed') ||
          mood.contains('anxious') ||
          mood.contains('neutral')) {
        anxiousCount++;
      }
    }

    final int total = happyCount + sadCount + calmCount + anxiousCount;
    if (total == 0) {
      return {'happy': 0.25, 'sad': 0.25, 'calm': 0.25, 'anxious': 0.25};
    }

    return {
      'happy': happyCount / total,
      'sad': sadCount / total,
      'calm': calmCount / total,
      'anxious': anxiousCount / total,
    };
  }

  Future<int> getUploadedImagesCount(String userId, {String? monthYear}) async {
    final db = await database;
    String query = 'SELECT image_paths FROM diary_entries WHERE user_id = ?';
    List<dynamic> args = [userId];

    if (monthYear != null) {
      query += ' AND date LIKE ?';
      args.add('$monthYear%');
    }

    final res = await db.rawQuery(query, args);
    int count = 0;
    for (var row in res) {
      final raw = row['image_paths'];
      if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            count += decoded.length;
          }
        } catch (_) {}
      }
    }
    return count;
  }

  Future<void> saveDiaryEntryWithLimits({
    required DiaryEntryModel entry,
    required SubscriptionPlan plan,
    required List<String> newImagesToAdd,
  }) async {
    final db = await database;

    // 1. Calculate image quota usage
    final monthYear = entry.date.substring(0, 7); // Format: "YYYY-MM"
    final usedImages = plan.isMonthlyImageLimit
        ? await getUploadedImagesCount(entry.userId, monthYear: monthYear)
        : await getUploadedImagesCount(entry.userId); // Total for Basic

    if (usedImages + newImagesToAdd.length > plan.diaryImageLimit) {
      final scope = plan.isMonthlyImageLimit ? 'this month' : 'total';
      throw Exception(
        'Image limit exceeded! The ${plan.tier.name.toUpperCase()} plan allows up to ${plan.diaryImageLimit} images $scope.',
      );
    }

    // 2. Persist locally in SQLite
    await upsertEntry(entry);

    // 3. Auto-sync to Supabase for Pro and Premium
    if (plan.cloudSyncEnabled) {
      try {
        // If Supabase column 'image_paths' is JSONB / array:
        await Supabase.instance.client.from('diary_entries').upsert({
          'id': entry.id,
          'user_id': entry.userId,
          'date': entry.date,
          'title': entry.title,
          'content': entry.content,
          'mood': entry.mood,
          'mood_score': entry.moodScore,
          'template_id': entry.templateId,
          'gender_preset': entry.genderPreset,
          'image_paths': entry
              .imagePaths, // Already List<String>, do NOT call jsonDecode()
          'audio_path': entry.audioPath,
          'audio_duration': entry.audioDuration,
          'updated_at': DateTime.now().toIso8601String(),
        });

        await db.update(
          'diary_entries',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [entry.id],
        );
      } catch (e) {
        debugPrint('Cloud sync failed for diary entry: $e');
      }
    }
  }
}
