import 'package:mineai/core/network/custom_api_call.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/instance/locator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task_model.dart';

class TaskService {
  final CustomApiCallService _apiService = getIt<CustomApiCallService>();
  final CustomSecureStorage _secureStorage = getIt<CustomSecureStorage>();

  Future<TaskModel> extractTaskFromPrompt(String prompt) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';
    final userId = await UserHelper.getCurrentUserId();

    final response = await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      // url: 'http://localhost:3000/api/v1/tasks/extract',
      url: '${UserHelper.baseUrl}/tasks/extract',
      data: {'prompt': prompt},
    );

    final responseData = response.data as Map<String, dynamic>;
    final taskData =
        responseData['data']?['task'] as Map<String, dynamic>? ?? {};
    return TaskModel.fromAiJson(taskData, userId);
  }

  Future<void> notifyTaskEmail(TaskModel task) async {
    final token = await _secureStorage.readSecureData('loginToken') ?? '';

    await _apiService.makeApiRequest(
      method: 'POST',
      token: token,
      url: '${UserHelper.baseUrl}/tasks/notify-email',
      // url: 'http://localhost:3000/api/v1/tasks/notify-email',
      data: {
        'task': {
          'title': task.title,
          'category': task.category,
          'date_display': task.dateDisplay,
          'date_iso': task.dateIso,
          'time_display': task.timeDisplay,
          'time_iso': task.timeIso,
          'location': task.location,
          'details': task.details,
        },
      },
    );
  }

  /// Opens Google Calendar / device calendar with the event pre-filled
  Future<bool> openInCalendar(TaskModel task) async {
    // Determine start and end date/time
    DateTime eventDate = DateTime.now().add(
      const Duration(days: 1),
    ); // Default tomorrow

    if (task.dateIso != null && task.dateIso!.isNotEmpty) {
      try {
        eventDate = DateTime.parse(task.dateIso!);
      } catch (_) {}
    } else if (task.dateDisplay.toLowerCase().contains('today')) {
      eventDate = DateTime.now();
    } else if (task.dateDisplay.toLowerCase().contains('tomorrow')) {
      eventDate = DateTime.now().add(const Duration(days: 1));
    }

    int hour = 10;
    int minute = 0;
    if (task.timeIso != null && task.timeIso!.contains(':')) {
      final parts = task.timeIso!.split(':');
      hour = int.tryParse(parts[0]) ?? 10;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    final startDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      hour,
      minute,
    );
    final endDateTime = startDateTime.add(const Duration(hours: 1));

    String formatUtc(DateTime dt) {
      final u = dt.toUtc();
      return '${u.year}${_twoDigits(u.month)}${_twoDigits(u.day)}T${_twoDigits(u.hour)}${_twoDigits(u.minute)}00Z';
    }

    final startIso = formatUtc(startDateTime);
    final endIso = formatUtc(endDateTime);

    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(task.title)}'
      '&dates=$startIso/$endIso'
      '&details=${Uri.encodeComponent(task.details ?? 'Scheduled via MineAI Assistant')}'
      '&location=${Uri.encodeComponent(task.location ?? '')}',
    );

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
}
