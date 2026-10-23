import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final String period; // 'day', 'week', 'month', 'year'
  final int totalCount;
  final int completedCount;
  final double completionPercentage;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.period,
    required this.totalCount,
    required this.completedCount,
    required this.completionPercentage,
  });

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        period,
        totalCount,
        completedCount,
        completionPercentage,
      ];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
