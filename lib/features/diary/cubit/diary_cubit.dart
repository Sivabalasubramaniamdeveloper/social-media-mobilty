import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../models/diary_entry_model.dart';
import '../repositories/diary_repository.dart';
import 'diary_state.dart';

class DiaryCubit extends Cubit<DiaryState> {
  final DiaryRepository _repository;

  DiaryCubit({required DiaryRepository repository})
    : _repository = repository,
      super(DiaryInitial());

  Future<void> loadDashboard({
    required String userId,
    DateTime? targetDate,
    String period = 'This Week',
  }) async {
    final activeDate = targetDate ?? DateTime.now();
    final monthYear = DateFormat('yyyy-MM').format(activeDate);
    final dateStr = DateFormat('yyyy-MM-dd').format(activeDate);

    try {
      final entries = await _repository.getEntriesForMonth(userId, monthYear);
      final selected = entries.where((e) => e.date == dateStr).firstOrNull;

      final (scores, labels) = _calculateChart(entries, activeDate, period);
      final quotes = AppStrings.dailyQuotes;
      final quote = quotes[activeDate.day % quotes.length];

      emit(
        DiaryLoaded(
          monthEntries: entries,
          selectedDate: activeDate,
          selectedEntry: selected,
          chartScores: scores,
          chartLabels: labels,
          period: period,
          dailyQuote: quote,
        ),
      );
    } catch (e) {
      emit(DiaryError(e.toString()));
    }
  }

  void selectDate(DateTime date, String userId) {
    if (state is DiaryLoaded) {
      final cur = state as DiaryLoaded;
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final entry = cur.monthEntries
          .where((e) => e.date == dateStr)
          .firstOrNull;

      final (scores, labels) = _calculateChart(
        cur.monthEntries,
        date,
        cur.period,
      );

      emit(
        cur.copyWith(
          selectedDate: date,
          selectedEntry: entry,
          chartScores: scores,
          chartLabels: labels,
        ),
      );
    }
  }

  void switchPeriod(String period, String userId) {
    if (state is DiaryLoaded) {
      final cur = state as DiaryLoaded;
      final (scores, labels) = _calculateChart(
        cur.monthEntries,
        cur.selectedDate,
        period,
      );
      emit(
        cur.copyWith(period: period, chartScores: scores, chartLabels: labels),
      );
    }
  }

  Future<void> saveEntry(DiaryEntryModel entry) async {
    try {
      await _repository.saveEntry(entry);
      final parsedDate = DateTime.parse(entry.date);
      await loadDashboard(userId: entry.userId, targetDate: parsedDate);
    } catch (e) {
      emit(DiaryError(e.toString()));
    }
  }

  Future<void> syncToCloud(String userId) async {
    try {
      final count = await _repository.syncToSupabase(userId);
      emit(DiarySyncSuccess(count));
      await loadDashboard(userId: userId);
    } catch (e) {
      emit(DiaryError(e.toString()));
    }
  }

  (List<double>, List<String>) _calculateChart(
    List<DiaryEntryModel> entries,
    DateTime referenceDate,
    String period,
  ) {
    if (period == 'This Week') {
      final weekStart = referenceDate.subtract(
        Duration(days: referenceDate.weekday - 1),
      );
      final scores = List<double>.filled(7, 3.0);
      final labels = AppStrings.weekDaysShort;

      for (int i = 0; i < 7; i++) {
        final dStr = DateFormat(
          'yyyy-MM-dd',
        ).format(weekStart.add(Duration(days: i)));
        final entry = entries.where((e) => e.date == dStr).firstOrNull;
        if (entry != null) {
          scores[i] = entry.moodScore.toDouble();
        }
      }
      return (scores, labels);
    } else {
      final scores = entries.isEmpty
          ? [3.0, 3.0, 3.0, 3.0]
          : entries.map((e) => e.moodScore.toDouble()).toList();
      return (scores, ['W1', 'W2', 'W3', 'W4']);
    }
  }
}
