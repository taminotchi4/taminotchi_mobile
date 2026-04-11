import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routing/router.dart';
import '../routing/routes.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';

/// Background message handler — top-level funksiya bo'lishi SHART
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 [FCM] Background: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Repository DI yuklanganidan keyin set qilinadi
  NotificationRepositoryImpl? _repository;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'taminotchi_notifications',
    'Taminotchi Bildirishnomalar',
    description: 'Taminotchi ilovasidan kelgan bildirishnomalar',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// App ishga tushganda chaqiriladi (Firebase.initializeApp() DAN KEYIN)
  Future<void> initialize() async {
    // 1. Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Android notification kanalini yaratish
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Local notifications sozlamalari
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // 4. iOS foreground notification
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Ruxsat so'rash
    await _requestPermission();

    // 6. Foreground message listener
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Background/Terminated → Notification bosildi
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handlePushTap(msg.data);
    });

    // 8. App terminated holda push bilan ochilganmi?
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _handlePushTap(initial.data);
    }
  }

  /// Foydalanuvchi login bo'lgandan keyin repository va token bilan sozlash
  /// [userRole]: 'client' yoki 'market'
  Future<void> onUserLoggedIn({
    required NotificationRepositoryImpl repository,
    required String userRole,
  }) async {
    _repository = repository;
    await _setupFcmToken(userRole);
  }

  /// Logout vaqtida FCM tokenni o'chirish
  Future<void> onUserLoggedOut(String userRole) async {
    if (_repository == null) return;
    try {
      await _repository!.clearFcmToken(userRole);
      debugPrint('✅ [FCM] Token backenddan o\'chirildi');
    } catch (e) {
      debugPrint('❌ [FCM] Token o\'chirishda xato: $e');
    }
  }

  /// FCM tokenni olish va backendga yuborish
  Future<void> _setupFcmToken(String userRole) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToBackend(token, userRole);
      }

      // Token yangilanishini kuzatish
      _fcm.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken, userRole);
      });
    } catch (e) {
      debugPrint('❌ [FCM] Token olishda xato: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token, String userRole) async {
    if (_repository == null) return;
    try {
      final result = await _repository!.saveFcmToken(token, userRole);
      result.fold(
        (error) => debugPrint('❌ [FCM] Token backendga yuborishda xato: $error'),
        (_) => debugPrint('✅ [FCM] Token backendga yuborildi'),
      );
    } catch (e) {
      debugPrint('❌ [FCM] Token yuborishda exception: $e');
    }
  }

  /// Ruxsat so'rash (Android 13+ va iOS)
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint('🔔 [FCM] Ruxsat: ${settings.authorizationStatus.name}');
  }

  /// Foreground holatda kelgan push notification ni local notification sifatida ko'rsatish
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 [FCM] Foreground: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  /// Push notification bosilganda GoRouter orqali navigatsiya
  void _handlePushTap(Map<String, dynamic> data) {
    debugPrint('👆 [FCM] Push bosildi: $data');
    final referenceType = data['referenceType'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (referenceType == null || referenceId == null) return;

    _navigateTo(referenceType, referenceId);
  }

  /// Local notification bosilganda navigatsiya
  void _onLocalNotificationTapped(NotificationResponse response) {
    debugPrint('👆 [Local] Notification bosildi: ${response.payload}');
    if (response.payload == null) return;

    // payload format: "referenceType:referenceId"
    final parts = response.payload!.split(':');
    if (parts.length >= 2) {
      _navigateTo(parts[0], parts[1]);
    }
  }

  void _navigateTo(String referenceType, String referenceId) {
    switch (referenceType) {
      case 'private_chat':
        router.push(Routes.getPrivateChat(referenceId));
        break;
      case 'group':
        router.push(Routes.getGroupChat(referenceId));
        break;
      case 'comment':
        // TODO: comment sahifasiga navigatsiya
        router.push(Routes.notifications);
        break;
      default:
        router.push(Routes.notifications);
    }
  }

  String _buildPayload(Map<String, dynamic> data) {
    final type = data['referenceType'] ?? '';
    final id = data['referenceId'] ?? '';
    return '$type:$id';
  }

  /// Mavzuga obuna bo'lish (agar kerak bo'lsa)
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('✅ [FCM] Topic ga obuna: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  Future<String?> getToken() => _fcm.getToken();
}
