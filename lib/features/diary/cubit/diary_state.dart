import 'package:equatable/equatable.dart';
import '../models/diary_entry_model.dart';

abstract class DiaryState extends Equatable {
  const DiaryState();
  @override
  List<Object?> get props => [];
}

class DiaryInitial extends DiaryState {}

class DiaryLoading extends DiaryState {}

class DiaryLoaded extends DiaryState {
  final List<DiaryEntryModel> monthEntries;
  final DateTime selectedDate;
  final DiaryEntryModel? selectedEntry;
  final List<double> chartScores;
  final List<String> chartLabels;
  final String period; // 'This Week' | 'This Month'
  final String dailyQuote;

  const DiaryLoaded({
    required this.monthEntries,
    required this.selectedDate,
    this.selectedEntry,
    required this.chartScores,
    required this.chartLabels,
    required this.period,
    required this.dailyQuote,
  });

  DiaryLoaded copyWith({
    List<DiaryEntryModel>? monthEntries,
    DateTime? selectedDate,
    DiaryEntryModel? selectedEntry,
    List<double>? chartScores,
    List<String>? chartLabels,
    String? period,
    String? dailyQuote,
  }) {
    return DiaryLoaded(
      monthEntries: monthEntries ?? this.monthEntries,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedEntry: selectedEntry,
      chartScores: chartScores ?? this.chartScores,
      chartLabels: chartLabels ?? this.chartLabels,
      period: period ?? this.period,
      dailyQuote: dailyQuote ?? this.dailyQuote,
    );
  }

  @override
  List<Object?> get props => [
    monthEntries,
    selectedDate,
    selectedEntry,
    chartScores,
    chartLabels,
    period,
    dailyQuote,
  ];
}

class DiarySyncSuccess extends DiaryState {
  final int syncedCount;
  const DiarySyncSuccess(this.syncedCount);

  @override
  List<Object?> get props => [syncedCount];
}

class DiaryError extends DiaryState {
  final String message;
  const DiaryError(this.message);

  @override
  List<Object?> get props => [message];
}
