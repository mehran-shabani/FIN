import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsService {
  static SettingsService? _instance;
  static SharedPreferences? _prefs;

  SettingsService._();

  static Future<SettingsService> getInstance() async {
    _instance ??= SettingsService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Keys
  static const String _deviceIdKey = 'device_id';
  static const String _languageKey = 'language';
  static const String _syncEnabledKey = 'sync_enabled';
  static const String _receiptUploadConsentKey = 'receipt_upload_consent';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _receiptReminderEnabledKey = 'receipt_reminder_enabled';
  static const String _receiptReminderHourKey = 'receipt_reminder_hour';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _firstLaunchKey = 'first_launch';
  static const String _currencyKey = 'currency';

  // Device ID
  String getDeviceId() {
    String? deviceId = _prefs!.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      _prefs!.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  // Language
  String getLanguage() {
    return _prefs!.getString(_languageKey) ?? 'fa';
  }

  Future<void> setLanguage(String language) async {
    await _prefs!.setString(_languageKey, language);
  }

  // Sync
  bool isSyncEnabled() {
    return _prefs!.getBool(_syncEnabledKey) ?? false;
  }

  Future<void> setSyncEnabled(bool enabled) async {
    await _prefs!.setBool(_syncEnabledKey, enabled);
  }

  // Receipt upload consent
  bool hasReceiptUploadConsent() {
    return _prefs!.getBool(_receiptUploadConsentKey) ?? false;
  }

  Future<void> setReceiptUploadConsent(bool consent) async {
    await _prefs!.setBool(_receiptUploadConsentKey, consent);
  }

  // Notifications
  bool areNotificationsEnabled() {
    return _prefs!.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs!.setBool(_notificationsEnabledKey, enabled);
  }

  // Receipt reminder
  bool isReceiptReminderEnabled() {
    return _prefs!.getBool(_receiptReminderEnabledKey) ?? true;
  }

  Future<void> setReceiptReminderEnabled(bool enabled) async {
    await _prefs!.setBool(_receiptReminderEnabledKey, enabled);
  }

  int getReceiptReminderHour() {
    return _prefs!.getInt(_receiptReminderHourKey) ?? 21; // 9 PM default
  }

  Future<void> setReceiptReminderHour(int hour) async {
    await _prefs!.setInt(_receiptReminderHourKey, hour);
  }

  // FCM Token
  String? getFcmToken() {
    return _prefs!.getString(_fcmTokenKey);
  }

  Future<void> setFcmToken(String token) async {
    await _prefs!.setString(_fcmTokenKey, token);
  }

  // First launch
  bool isFirstLaunch() {
    return _prefs!.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchCompleted() async {
    await _prefs!.setBool(_firstLaunchKey, false);
  }

  // Currency
  String getCurrency() {
    return _prefs!.getString(_currencyKey) ?? 'IRR';
  }

  Future<void> setCurrency(String currency) async {
    await _prefs!.setString(_currencyKey, currency);
  }

  // Environment variables
  static String get apiBaseUrl {
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://golddrop.ir',
    );
  }

  static String? get backendApiKey {
    return const String.fromEnvironment('BACKEND_API_KEY');
  }

  static String get appName {
    return const String.fromEnvironment('APP_NAME', defaultValue: 'FinSnap');
  }

  static bool get sendReceiptsToCloud {
    return const bool.fromEnvironment(
      'SEND_RECEIPTS_TO_CLOUD',
      defaultValue: true,
    );
  }

  static String get defaultCurrency {
    return const String.fromEnvironment(
      'DEFAULT_CURRENCY',
      defaultValue: 'IRR',
    );
  }

  static String? get fcmWebVapidKey {
    return const String.fromEnvironment('FCM_WEB_VAPID_KEY');
  }

  static bool get pushEnabled {
    return const bool.fromEnvironment('PUSH_ENABLED', defaultValue: true);
  }

  // Complex settings
  Map<String, dynamic> getAppSettings() {
    return {
      'device_id': getDeviceId(),
      'language': getLanguage(),
      'sync_enabled': isSyncEnabled(),
      'receipt_upload_consent': hasReceiptUploadConsent(),
      'notifications_enabled': areNotificationsEnabled(),
      'receipt_reminder_enabled': isReceiptReminderEnabled(),
      'receipt_reminder_hour': getReceiptReminderHour(),
      'currency': getCurrency(),
      'first_launch': isFirstLaunch(),
    };
  }

  Future<void> resetAllSettings() async {
    await _prefs!.clear();
  }
}
