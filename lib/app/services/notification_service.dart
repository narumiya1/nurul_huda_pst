import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:epesantren_mob/app/helpers/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request Permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // 2. Get FCM Token and Store it
    String? token = await messaging.getToken();
    if (token != null) {
      await LocalStorage.write('fcm_token', token);
      debugPrint("FCM Token: $token");
    }

    // 3. Setup Local Notifications for Foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _navigateToRoute(details.payload!);
        }
      },
    );

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        String? url = message.data['url'];

        _notificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: url,
        );
      }
    });

    // 5. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String? url = message.data['url'];
      if (url != null) {
        _navigateToRoute(url);
      }
    });

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      String? url = initialMessage.data['url'];
      if (url != null) {
        // Wait a bit for app to fully initialize
        Future.delayed(const Duration(seconds: 1), () => _navigateToRoute(url));
      }
    }
  }

  static void _navigateToRoute(String url) {
    if (url.startsWith('/')) {
      // Map Laravel style URLs to Flutter Routes if needed
      // Persuratan URL in Laravel: /persuratan/arsip
      // Finance URL in Laravel: /tagihan

      if (url.contains('tagihan')) {
        Get.toNamed('/keuangan');
      } else if (url.contains('persuratan')) {
        Get.toNamed(
            '/administrasi'); // Or wherever persuratan is located in mobile
      } else if (url.contains('akademik-pondok')) {
        Get.toNamed('/akademik-pondok');
      } else if (url.contains('absensi')) {
        // Attendance report is inside AkademikPondokView, we can navigate there or to a specific index
        Get.toNamed('/akademik-pondok');
      }
    }
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    debugPrint("Handling a background message: ${message.messageId}");
  }
}
