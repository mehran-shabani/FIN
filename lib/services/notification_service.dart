import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import 'settings_service.dart';
import 'api_service.dart';
import '../data/models/common_dto.dart';

class NotificationService {
  static NotificationService? _instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static FirebaseMessaging? _firebaseMessaging;
  static StreamSubscription<RemoteMessage>? _messageSubscription;

  NotificationService._();

  static Future<NotificationService> getInstance() async {
    _instance ??= NotificationService._();
    await _instance!._initialize();
    return _instance!;
  }

  Future<void> _initialize() async {
    await _initializeLocalNotifications();

    if (!kIsWeb && SettingsService.pushEnabled) {
      await _initializeFirebaseMessaging();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotifications!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (kIsWeb) return;

    try {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await _firebaseMessaging!.getToken();
        if (token != null) {
          final settingsService = await SettingsService.getInstance();
          await settingsService.setFcmToken(token);

          // Register with backend if sync is enabled
          if (settingsService.isSyncEnabled() &&
              SettingsService.backendApiKey != null) {
            await _registerWithBackend(token);
          }
        }

        // Listen to token refresh
        _firebaseMessaging!.onTokenRefresh.listen((newToken) async {
          final settingsService = await SettingsService.getInstance();
          await settingsService.setFcmToken(newToken);

          if (settingsService.isSyncEnabled() &&
              SettingsService.backendApiKey != null) {
            await _registerWithBackend(newToken);
          }
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      }
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  Future<void> _registerWithBackend(String token) async {
    try {
      final settingsService = await SettingsService.getInstance();
      final apiService = ApiService(apiKey: SettingsService.backendApiKey);

      final request = PushRegisterRequest(
        deviceId: settingsService.getDeviceId(),
        platform: kIsWeb ? 'web' : 'android',
        token: token,
      );

      await apiService.registerPush(request);
    } catch (e) {
      debugPrint('Failed to register push token with backend: $e');
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
    // Handle background message
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showNotification(
        id: message.hashCode,
        title: notification.title ?? 'FinSnap',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap
  }

  // Public methods
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final result = await _localNotifications!
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finsnap_default',
      'Default Notifications',
      channelDescription: 'Default notification channel for FinSnap',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications!.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleReceiptReminder() async {
    final settingsService = await SettingsService.getInstance();

    if (!settingsService.isReceiptReminderEnabled()) return;

    final hour = settingsService.getReceiptReminderHour();

    await _localNotifications!.zonedSchedule(
      1001, // Receipt reminder ID
      'یادآوری بارگذاری رسید',
      'فراموش نکنید که رسیدهای امروز را بارگذاری کنید',
      _nextInstanceOfTime(hour, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'receipt_reminder',
          'Receipt Reminders',
          channelDescription: 'Daily reminders to upload receipts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReceiptReminder() async {
    await _localNotifications!.cancel(1001);
  }

  Future<void> showDailyEvaluationReady() async {
    await showNotification(
      id: 2001,
      title: 'ارزیابی روزانه آماده شد',
      body: 'گزارش مالی امروز شما آماده است. برای مشاهده ضربه بزنید.',
      payload: 'daily_evaluation',
    );
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
