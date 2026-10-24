import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/cards/credits_tracker_card.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/tasks/cubit/task_cubit.dart';
import 'package:mineai/features/tasks/cubit/task_state.dart';
import 'package:mineai/features/tasks/models/task_model.dart';
import 'package:mineai/features/tasks/presentation/task_detail_screen.dart';
import 'package:mineai/features/tasks/presentation/widgets/task_hype_poster_dialog.dart';
import 'package:mineai/features/tasks/services/task_service.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TaskService _taskService = TaskService();
  String _selectedPeriod = 'week';

  final List<Map<String, String>> _periods = [
    {'id': 'day', 'label': 'Today'},
    {'id': 'week', 'label': 'This Week'},
    {'id': 'month', 'label': 'This Month'},
    {'id': 'year', 'label': 'This Year'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    context.read<TaskCubit>().loadTasks(period: _selectedPeriod);
  }

  Future<void> _toggleComplete(TaskModel task) async {
    if (task.id == null) return;
    await context
        .read<TaskCubit>()
        .toggleCompleted(task.id!, !task.isCompleted, _selectedPeriod);
  }

  Future<void> _deleteTask(TaskModel task) async {
    if (task.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.delete),
        content: Text(AppStrings.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TaskCubit>().deleteTask(task.id!, _selectedPeriod);
      if (mounted) SnackBarHelper.showSuccess(context, AppStrings.itemDeleted);
    }
  }

  void _showHypePoster({
    required int total,
    required int completed,
    required double percentage,
  }) {
    final profileState = context.read<UserProfileCubit>().state;
    final userName =
        profileState is UserProfileLoaded ? profileState.profile.fullName : 'MineAI User';

    TaskHypePosterDialog.show(
      context,
      periodName: _periods.firstWhere((p) => p['id'] == _selectedPeriod)['label']!,
      totalTasks: total,
      completedTasks: completed,
      percentage: percentage,
      userName: userName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: 'Task Tracker & Assistant',
                  centerTitle: true,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.dashboard);
                    }
                  },
                ),
              ),

              // Period Filter Chips (Day / Week / Month / Year)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((p) {
                      final isSelected = _selectedPeriod == p['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedPeriod = p['id']!);
                          _loadTasks();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary
                                : (isLight
                                    ? scheme.surfaceContainerHighest
                                    : const Color(0xFF1E1B38)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? scheme.primary : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            p['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : scheme.onSurface.withValues(alpha: 0.8),
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      );
                    }

                    List<TaskModel> tasks = [];
                    int total = 0;
                    int completed = 0;
                    double percentage = 0.0;

                    if (state is TaskLoaded) {
                      tasks = state.filteredTasks;
                      total = state.totalCount;
                      completed = state.completedCount;
                      percentage = state.completionPercentage;
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadTasks(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        children: [
                          const CreditsTrackerCard(compact: true),
                          const SizedBox(height: 14),

                          // Completion Status Progress Card
                          _buildCompletionStatusCard(
                            scheme,
                            isLight,
                            total: total,
                            completed: completed,
                            percentage: percentage,
                          ),
                          const SizedBox(height: 16),

                          if (tasks.isEmpty)
                            _buildEmptyState(scheme, isLight)
                          else
                            ...tasks.map(
                                (task) => _buildTaskItem(task, scheme, isLight)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: scheme.primary,
        onPressed: () => context.push(RouteNames.voiceTasks),
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: Text(
          AppStrings.speakNow,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCompletionStatusCard(
    ColorScheme scheme,
    bool isLight, {
    required int total,
    required int completed,
    required double percentage,
  }) {
    final periodLabel =
        _periods.firstWhere((p) => p['id'] == _selectedPeriod)['label']!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLight ? Colors.black12 : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$periodLabel Completion',
                    style: TextStyle(
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightSecondaryOnSurface
                          : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of $total Tasks Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? Colors.green.withValues(alpha: 0.15)
                      : scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: percentage >= 80 ? Colors.green : scheme.primary,
                  ),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80 ? Colors.green : scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (completed / total),
              minHeight: 8,
              backgroundColor: isLight ? Colors.black12 : Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80 ? Colors.green : scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Hyped Movie / District Style Share Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0055),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.local_fire_department_rounded,
                  color: Colors.white, size: 20),
              label: const Text(
                'Share Status to Social Media 🔥',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onPressed: total == 0
                  ? null
                  : () => _showHypePoster(
                        total: total,
                        completed: completed,
                        percentage: percentage,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? Colors.black12 : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 48,
            color: isLight ? Colors.black26 : Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.noTasksFound,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the microphone below to dictate meetings, reminders, or tasks using AI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight
                  ? AppColors.lightSecondaryOnSurface
                  : AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, ColorScheme scheme, bool isLight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : (isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white12),
          width: task.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: task.isCompleted
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
            );
            _loadTasks();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          task.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key: ValueKey(task.isCompleted),
                          color: task.isCompleted ? Colors.green : scheme.primary,
                          size: 24,
                        ),
                      ),
                      onPressed: () => _toggleComplete(task),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dateDisplay} • ${task.timeDisplay}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.details != null && task.details!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      task.details!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isLight
                            ? AppColors.lightSecondaryOnSurface
                            : AppColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isLight ? Colors.black12 : Colors.white12,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (task.location != null && task.location!.isNotEmpty) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isLight
                            ? AppColors.lightSecondaryOnSurface
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isLight
                                ? AppColors.lightSecondaryOnSurface
                                : AppColors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: scheme.primary,
                        size: 19,
                      ),
                      tooltip: 'Open in Calendar',
                      onPressed: () => _taskService.openInCalendar(task),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.mail_outline_rounded,
                        color: scheme.primary,
                        size: 19,
                      ),
                      tooltip: 'Send Email Reminder',
                      onPressed: () async {
                        try {
                          await _taskService.notifyTaskEmail(task);
                          if (mounted) {
                            SnackBarHelper.showSuccess(
                              context,
                              'Task email reminder sent! (Check Inbox & Spam folder)',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            SnackBarHelper.showError(context, 'Failed to send: $e');
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 19,
                      ),
                      onPressed: () => _deleteTask(task),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
