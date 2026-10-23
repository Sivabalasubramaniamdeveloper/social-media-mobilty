import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/diary/widgets/diary_mood_hype_dialog.dart';
import 'package:mineai/features/diary/widgets/emotions_tracker_card.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/diary_cubit.dart';
import '../cubit/diary_state.dart';
import '../widgets/mood_chart_widget.dart';
import 'diary_entry_editor_screen.dart';

class DiaryDashboardScreen extends StatefulWidget {
  final String userId;
  const DiaryDashboardScreen({super.key, required this.userId});

  @override
  State<DiaryDashboardScreen> createState() => _DiaryDashboardScreenState();
}

class _DiaryDashboardScreenState extends State<DiaryDashboardScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<DiaryCubit>().loadDashboard(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.personalDiary,
          style:
              theme.appBarTheme.titleTextStyle ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_upload_outlined, color: scheme.primary),
            tooltip: AppStrings.syncToCloud,
            onPressed: () =>
                context.read<DiaryCubit>().syncToCloud(widget.userId),
          ),
        ],
      ),
      body: BlocConsumer<DiaryCubit, DiaryState>(
        listener: (context, state) {
          if (state is DiarySyncSuccess) {
            SnackBarHelper.showSuccess(
              context,
              AppStrings.syncSuccess(state.syncedCount),
            );
          } else if (state is DiaryError) {
            SnackBarHelper.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is DiaryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! DiaryLoaded) {
            return const SizedBox.shrink();
          }

          final selectedDay = state.selectedDate;
          final dayEntry = state.selectedEntry;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Motivation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: scheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.dailyMotivation,
                              style: TextStyle(
                                color: scheme.primary,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.dailyQuote,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Calendar View
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: scheme.onSurface.withOpacity(0.08),
                    ),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    currentDay: DateTime.now(),
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: scheme.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: scheme.primary,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(
                        color: scheme.onSurface.withOpacity(0.85),
                      ),
                      weekendTextStyle: TextStyle(color: scheme.error),
                      selectedDecoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        border: Border.all(color: scheme.primary, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onDaySelected: (selDay, focDay) {
                      setState(() => _focusedDay = focDay);
                      context.read<DiaryCubit>().selectDate(
                        selDay,
                        widget.userId,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Selected Day Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.onSurface.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primary.withOpacity(0.15),
                        child: Icon(
                          dayEntry != null
                              ? Icons.book_rounded
                              : Icons.edit_calendar_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(selectedDay),
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              dayEntry != null
                                  ? '${dayEntry.mood.toUpperCase()} • "${dayEntry.title}"'
                                  : AppStrings.noMemoryRecorded,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<DiaryCubit>(),
                                child: DiaryEntryEditorScreen(
                                  userId: widget.userId,
                                  selectedDate: selectedDay,
                                  existingEntry: dayEntry,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          dayEntry != null
                              ? AppStrings.viewEdit
                              : AppStrings.write,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dayEntry != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Share Today\'s Mood Vibe 🔥',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        final profileState =
                            context.read<UserProfileCubit>().state;
                        final userName = profileState is UserProfileLoaded
                            ? profileState.profile.fullName
                            : 'MineAI User';
                        DiaryMoodHypeDialog.show(
                          context,
                          entry: dayEntry,
                          userName: userName,
                          dailyQuote: state.dailyQuote,
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                EmotionsTrackerCard(userId: widget.userId),
                const SizedBox(height: 12),
                // Analytics Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.moodAndVibeAnalytics,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: scheme.surface,
                        value: state.period,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [AppStrings.thisWeek, AppStrings.thisMonth].map((
                          val,
                        ) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<DiaryCubit>().switchPeriod(
                              val,
                              widget.userId,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                MoodChartWidget(
                  scores: state.chartScores,
                  labels: state.chartLabels,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
