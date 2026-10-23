import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/profile/cubit/user_profile_cubit.dart';
import 'package:mineai/features/profile/cubit/user_profile_state.dart';
import 'package:mineai/features/tasks/models/task_model.dart';
import 'package:mineai/features/tasks/services/task_database_service.dart';
import 'package:mineai/features/tasks/services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  late TaskModel _task;
  bool _isSaving = false;
  bool _isEmailSending = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _saveTaskAndSync() async {
    setState(() => _isSaving = true);
    try {
      // 1. Save to SQLite database
      await TaskDatabaseService.instance.insertTask(_task);

      // 2. Send email notification
      try {
        await _taskService.notifyTaskEmail(_task);
      } catch (err) {
        debugPrint('Could not send email notification: $err');
      }

      // 3. Open in Calendar
      await _taskService.openInCalendar(_task);

      if (mounted) {
        setState(() => _isSaving = false);
        SnackBarHelper.showSuccess(context, 'Task saved, emailed & opened in Calendar! (Check Inbox & Spam folder)');
        // Navigate to the tasks list screen to view all saved tasks
        context.pushReplacement(RouteNames.tasksList);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackBarHelper.showError(context, 'Failed to save task: $e');
      }
    }
  }

  Future<void> _sendEmailOnly() async {
    final profileState = context.read<UserProfileCubit>().state;
    final userEmail = profileState is UserProfileLoaded ? profileState.profile.email : 'your registered email';

    setState(() => _isEmailSending = true);
    try {
      await _taskService.notifyTaskEmail(_task);
      if (mounted) {
        setState(() => _isEmailSending = false);
        SnackBarHelper.showSuccess(
          context,
          'Task details sent to $userEmail! (Please check your Inbox and Spam/Junk folder)',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isEmailSending = false);
        SnackBarHelper.showError(context, 'Could not send email: $e');
      }
    }
  }

  void _showEditDetailsModal() {
    final titleCtrl = TextEditingController(text: _task.title);
    final locationCtrl = TextEditingController(text: _task.location ?? '');
    final detailsCtrl = TextEditingController(text: _task.details ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B192E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Task Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Task Title',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: Color(0xFF262344),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Location / Room / Link',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: Color(0xFF262344),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailsCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Agenda / Details',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: Color(0xFF262344),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _task = TaskModel(
                      id: _task.id,
                      userId: _task.userId,
                      title: titleCtrl.text.trim().isNotEmpty
                          ? titleCtrl.text.trim()
                          : _task.title,
                      category: _task.category,
                      dateDisplay: _task.dateDisplay,
                      dateIso: _task.dateIso,
                      timeDisplay: _task.timeDisplay,
                      timeIso: _task.timeIso,
                      location: locationCtrl.text.trim().isNotEmpty
                          ? locationCtrl.text.trim()
                          : null,
                      details: detailsCtrl.text.trim().isNotEmpty
                          ? detailsCtrl.text.trim()
                          : null,
                      isCompleted: _task.isCompleted,
                      createdAt: _task.createdAt,
                    );
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Update Task', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
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
                  title: 'Task Overview',
                  centerTitle: true,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Extracted Task Card matching Image 2
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF161426),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AI EXTRACTED TASK',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: scheme.primary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.work_outline_rounded,
                                        color: scheme.primary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _task.category,
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _task.title,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Divider(
                              color: isLight ? Colors.black12 : Colors.white12,
                              height: 1,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: scheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'DATE',
                                            style: TextStyle(
                                              color: isLight
                                                  ? AppColors.lightSecondaryOnSurface
                                                  : Colors.white54,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _task.dateDisplay,
                                            style: TextStyle(
                                              color: scheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        color: scheme.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TIME',
                                            style: TextStyle(
                                              color: isLight
                                                  ? AppColors.lightSecondaryOnSurface
                                                  : Colors.white54,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _task.timeDisplay,
                                            style: TextStyle(
                                              color: scheme.onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_task.location != null || _task.details != null) ...[
                              const SizedBox(height: 14),
                              Divider(
                                color: isLight ? Colors.black12 : Colors.white12,
                                height: 1,
                              ),
                              const SizedBox(height: 10),
                              if (_task.location != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                        color: scheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Location: ${_task.location}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_task.details != null)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 15,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _task.details!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isLight
                                              ? AppColors.lightSecondaryOnSurface
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _showEditDetailsModal,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLight
                                        ? Colors.black26
                                        : Colors.white24,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '+ Edit Details or Location',
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions section
                      Text(
                        'ACTIONS',
                        style: TextStyle(
                          color: isLight
                              ? AppColors.lightSecondaryOnSurface
                              : AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Main button: Save Task & Sync Everywhere
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _isSaving ? null : _saveTaskAndSync,
                          child: _isSaving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Saving & Syncing...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Task & Sync with Calendar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: scheme.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.mail_outline_rounded,
                                  size: 18,
                                  color: scheme.primary,
                                ),
                                label: Text(
                                  'Send Email',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: _isEmailSending ? null : _sendEmailOnly,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: scheme.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: scheme.primary,
                                ),
                                label: Text(
                                  'Open Calendar',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: () => _taskService.openInCalendar(_task),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // View all saved tasks button
                      Center(
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                          label: Text(
                            'View All Saved Tasks in List →',
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => context.push(RouteNames.tasksList),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
