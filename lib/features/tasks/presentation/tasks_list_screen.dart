import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/toast_helper.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/cards/credits_tracker_card.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/tasks/models/task_model.dart';
import 'package:mineai/features/tasks/services/task_database_service.dart';
import 'package:mineai/features/tasks/services/task_service.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TaskService _taskService = TaskService();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final userId = await UserHelper.getCurrentUserId();
    final tasks = await TaskDatabaseService.instance.getTasks(userId);
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete(TaskModel task) async {
    if (task.id == null) return;
    await TaskDatabaseService.instance.toggleTaskCompleted(
      task.id!,
      !task.isCompleted,
    );
    await _loadTasks();
  }

  Future<void> _deleteTask(TaskModel task) async {
    if (task.id == null) return;
    await TaskDatabaseService.instance.deleteTask(task.id!);
    await _loadTasks();
    showToast('Task removed');
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
                  title: 'Saved Tasks',
                  centerTitle: true,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          children: [
                            const CreditsTrackerCard(compact: true),
                            const SizedBox(height: 16),
                            if (_tasks.isEmpty)
                              _buildEmptyState(scheme, isLight)
                            else
                              ..._tasks.map((task) => _buildTaskItem(task, scheme, isLight)),
                          ],
                        ),
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
        label: const Text(
          'New Voice Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, bool isLight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 64,
              color: isLight
                  ? Colors.black26
                  : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks saved yet',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the AI Voice Assistant to speak or type tasks, send email confirmations, and sync with your calendar.',
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
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, ColorScheme scheme, bool isLight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? (isLight ? Colors.black12 : Colors.white10)
              : scheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.greenAccent : scheme.primary,
                  size: 22,
                ),
                onPressed: () => _toggleComplete(task),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted
                        ? (isLight ? Colors.black38 : Colors.white38)
                        : scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                '${task.dateDisplay} at ${task.timeDisplay}',
                style: TextStyle(
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
                tooltip: 'Open in Calendar',
                onPressed: () => _taskService.openInCalendar(task),
              ),
              IconButton(
                icon: Icon(
                  Icons.mail_outline_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
                tooltip: 'Send Email Reminder',
                onPressed: () async {
                  await _taskService.notifyTaskEmail(task);
                  showToast('Task email reminder sent!');
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _deleteTask(task),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
