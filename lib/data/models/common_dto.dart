import 'package:json_annotation/json_annotation.dart';

part 'common_dto.g.dart';

@JsonSerializable()
class HealthResponse {
  final String status;
  final String time;

  const HealthResponse({required this.status, required this.time});

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}

@JsonSerializable()
class AppConfigResponse {
  @JsonKey(name: 'min_app_version')
  final String minAppVersion;
  final Map<String, dynamic> features;
  @JsonKey(name: 'ocr_allowed')
  final bool ocrAllowed;

  const AppConfigResponse({
    required this.minAppVersion,
    required this.features,
    required this.ocrAllowed,
  });

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$AppConfigResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigResponseToJson(this);
}

@JsonSerializable()
class SummaryResponse {
  @JsonKey(name: 'total_income')
  final double totalIncome;
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @JsonKey(name: 'by_category')
  final Map<String, double> byCategory;

  const SummaryResponse({
    required this.totalIncome,
    required this.totalExpense,
    required this.byCategory,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryResponseToJson(this);
}

@JsonSerializable()
class PushRegisterRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  final String platform; // 'android' or 'web'
  final String token;

  const PushRegisterRequest({
    required this.deviceId,
    required this.platform,
    required this.token,
  });

  factory PushRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$PushRegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PushRegisterRequestToJson(this);
}

@JsonSerializable()
class PushRegisterResponse {
  final bool registered;

  const PushRegisterResponse({required this.registered});

  factory PushRegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$PushRegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushRegisterResponseToJson(this);
}

@JsonSerializable()
class DailyEvalRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  final String date; // YYYY-MM-DD format

  const DailyEvalRequest({required this.deviceId, required this.date});

  factory DailyEvalRequest.fromJson(Map<String, dynamic> json) =>
      _$DailyEvalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DailyEvalRequestToJson(this);
}

@JsonSerializable()
class DailyEvalResponse {
  final bool ready;
  final String? summary;
  final Map<String, double>? totals;

  const DailyEvalResponse({required this.ready, this.summary, this.totals});

  factory DailyEvalResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyEvalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DailyEvalResponseToJson(this);
}

@JsonSerializable()
class ReceiptReminderRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;
  @JsonKey(name: 'hour_local')
  final int hourLocal;
  final bool enabled;

  const ReceiptReminderRequest({
    required this.deviceId,
    required this.hourLocal,
    required this.enabled,
  });

  factory ReceiptReminderRequest.fromJson(Map<String, dynamic> json) =>
      _$ReceiptReminderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptReminderRequestToJson(this);
}

@JsonSerializable()
class ApiResponse {
  final bool ok;

  const ApiResponse({required this.ok});

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}
