import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/core/utils/user_helper.dart';
import '../services/task_database_service.dart';
import '../models/task_model.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskDatabaseService _dbService;

  TaskCubit({TaskDatabaseService? dbService})
    : _dbService = dbService ?? TaskDatabaseService.instance,
      super(const TaskInitial());

  Future<void> loadTasks({String period = 'week'}) async {
    emit(const TaskLoading());
    try {
      final userId = await UserHelper.getCurrentUserId();
      final allTasks = await _dbService.getTasks(userId);

      final now = DateTime.now();
      final filtered = allTasks.where((task) {
        final created = DateTime.tryParse(task.createdAt) ?? now;
        switch (period) {
          case 'day':
            return created.year == now.year &&
                created.month == now.month &&
                created.day == now.day;
          case 'week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final beginning = DateTime(
              startOfWeek.year,
              startOfWeek.month,
              startOfWeek.day,
            );
            return created.isAfter(
              beginning.subtract(const Duration(seconds: 1)),
            );
          case 'month':
            return created.year == now.year && created.month == now.month;
          case 'year':
            return created.year == now.year;
          default:
            return true;
        }
      }).toList();

      final total = filtered.length;
      final completed = filtered.where((t) => t.isCompleted).length;
      final percentage = total == 0 ? 0.0 : (completed / total) * 100;

      emit(
        TaskLoaded(
          allTasks: allTasks,
          filteredTasks: filtered,
          period: period,
          totalCount: total,
          completedCount: completed,
          completionPercentage: percentage,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> toggleCompleted(
    int taskId,
    bool newStatus,
    String currentPeriod,
  ) async {
    try {
      await _dbService.toggleTaskCompleted(taskId, newStatus);
      await loadTasks(period: currentPeriod);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> deleteTask(int taskId, String currentPeriod) async {
    try {
      await _dbService.deleteTask(taskId);
      await loadTasks(period: currentPeriod);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  /// Stores a spoken or typed task exactly as entered, without an AI request.
  Future<bool> saveRawTask(TaskModel task) async {
    try {
      await _dbService.insertTask(task);
      return true;
    } catch (e) {
      emit(TaskError(e.toString()));
      return false;
    }
  }
}
