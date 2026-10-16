import '../models/diary_entry_model.dart';
import '../services/diary_database_service.dart';

abstract class DiaryRepository {
  Future<void> saveEntry(DiaryEntryModel entry);
  Future<DiaryEntryModel?> getEntryByDate(String userId, String date);
  Future<List<DiaryEntryModel>> getEntriesForMonth(
    String userId,
    String monthYear,
  );
  Future<int> syncToSupabase(String userId);
}

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryDatabaseService _dbService;

  DiaryRepositoryImpl({DiaryDatabaseService? dbService})
    : _dbService = dbService ?? DiaryDatabaseService.instance;

  @override
  Future<void> saveEntry(DiaryEntryModel entry) {
    return _dbService.upsertEntry(entry);
  }

  @override
  Future<DiaryEntryModel?> getEntryByDate(String userId, String date) {
    return _dbService.getEntryByDate(userId, date);
  }

  @override
  Future<List<DiaryEntryModel>> getEntriesForMonth(
    String userId,
    String monthYear,
  ) {
    final start = '$monthYear-01';
    final end = '$monthYear-31';
    return _dbService.getEntriesRange(userId, start, end);
  }

  @override
  Future<int> syncToSupabase(String userId) {
    return _dbService.syncLocalEntriesToSupabase(userId);
  }
}
