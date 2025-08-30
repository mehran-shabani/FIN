// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      time: json['time'] as String,
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{'status': instance.status, 'time': instance.time};

AppConfigResponse _$AppConfigResponseFromJson(Map<String, dynamic> json) =>
    AppConfigResponse(
      minAppVersion: json['min_app_version'] as String,
      features: json['features'] as Map<String, dynamic>,
      ocrAllowed: json['ocr_allowed'] as bool,
    );

Map<String, dynamic> _$AppConfigResponseToJson(AppConfigResponse instance) =>
    <String, dynamic>{
      'min_app_version': instance.minAppVersion,
      'features': instance.features,
      'ocr_allowed': instance.ocrAllowed,
    };

SummaryResponse _$SummaryResponseFromJson(Map<String, dynamic> json) =>
    SummaryResponse(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      byCategory: (json['by_category'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$SummaryResponseToJson(SummaryResponse instance) =>
    <String, dynamic>{
      'total_income': instance.totalIncome,
      'total_expense': instance.totalExpense,
      'by_category': instance.byCategory,
    };

PushRegisterRequest _$PushRegisterRequestFromJson(Map<String, dynamic> json) =>
    PushRegisterRequest(
      deviceId: json['device_id'] as String,
      platform: json['platform'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$PushRegisterRequestToJson(
  PushRegisterRequest instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'platform': instance.platform,
  'token': instance.token,
};

PushRegisterResponse _$PushRegisterResponseFromJson(
  Map<String, dynamic> json,
) => PushRegisterResponse(registered: json['registered'] as bool);

Map<String, dynamic> _$PushRegisterResponseToJson(
  PushRegisterResponse instance,
) => <String, dynamic>{'registered': instance.registered};

DailyEvalRequest _$DailyEvalRequestFromJson(Map<String, dynamic> json) =>
    DailyEvalRequest(
      deviceId: json['device_id'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$DailyEvalRequestToJson(DailyEvalRequest instance) =>
    <String, dynamic>{'device_id': instance.deviceId, 'date': instance.date};

DailyEvalResponse _$DailyEvalResponseFromJson(Map<String, dynamic> json) =>
    DailyEvalResponse(
      ready: json['ready'] as bool,
      summary: json['summary'] as String?,
      totals: (json['totals'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$DailyEvalResponseToJson(DailyEvalResponse instance) =>
    <String, dynamic>{
      'ready': instance.ready,
      'summary': instance.summary,
      'totals': instance.totals,
    };

ReceiptReminderRequest _$ReceiptReminderRequestFromJson(
  Map<String, dynamic> json,
) => ReceiptReminderRequest(
  deviceId: json['device_id'] as String,
  hourLocal: (json['hour_local'] as num).toInt(),
  enabled: json['enabled'] as bool,
);

Map<String, dynamic> _$ReceiptReminderRequestToJson(
  ReceiptReminderRequest instance,
) => <String, dynamic>{
  'device_id': instance.deviceId,
  'hour_local': instance.hourLocal,
  'enabled': instance.enabled,
};

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) =>
    ApiResponse(ok: json['ok'] as bool);

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{'ok': instance.ok};
