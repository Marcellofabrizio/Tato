import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/web.dart';
import 'package:tato/main.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('pomodoro');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        log('aquiii');
      },
    );

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: notificationResponseHandler);
  }

  notificationResponseHandler(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      Logger().i("não é null");
    } else {
      Logger().i("é null");
    }

    chaveDeNavegacao.currentState?.pushNamed('/', arguments: "veio");
  }

  notificationDetails() {
    return const NotificationDetails(android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max), iOS: DarwinNotificationDetails());
  }

  Future showNotification({int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(id, title, body, await notificationDetails());
  }
}
