import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todoapp/models/todo.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'todo_notifications',
          channelName: 'Todo Reminders',
          channelDescription: 'Notifications for todo reminders',
          defaultColor: const Color(0xFF2196F3),
          ledColor: const Color(0xFF2196F3),
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.payload != null) {
      final todoKey = int.tryParse(receivedAction.payload!['todoKey'] ?? '');
      if (todoKey != null) {
        debugPrint('Notification clicked for todo: $todoKey');
      }
    }
  }

  Future<void> scheduleTodoNotification(Todo todo) async {
    final dueDateTime = todo.dueDateWithTime;
    if (dueDateTime == null) return;

    final notificationTime = dueDateTime.subtract(const Duration(minutes: 5));
    if (notificationTime.isBefore(DateTime.now())) return;

    final timeString = todo.dueTime != null 
        ? '${todo.dueTime!.hour.toString().padLeft(2, '0')}:${todo.dueTime!.minute.toString().padLeft(2, '0')}'
        : '';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: todo.key,
        channelKey: 'todo_notifications',
        title: 'Upcoming Task: ${todo.title}',
        body: 'Due in 5 minutes${timeString.isNotEmpty ? ' at $timeString' : ''}',
        notificationLayout: NotificationLayout.BigText,
        payload: {'todoKey': todo.key.toString()},
      ),
      schedule: NotificationCalendar.fromDate(
        date: notificationTime,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
} 