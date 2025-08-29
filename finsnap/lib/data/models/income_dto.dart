import 'package:json_annotation/json_annotation.dart';

part 'income_dto.g.dart';

@JsonSerializable()
class IncomeDto {
  @JsonKey(name: 'client_id')
  final String clientId;
  final double amount;
  final String currency;
  final String date; // YYYY-MM-DD format
  final String? source;
  final String? note;

  const IncomeDto({
    required this.clientId,
    required this.amount,
    required this.currency,
    required this.date,
    this.source,
    this.note,
  });

  factory IncomeDto.fromJson(Map<String, dynamic> json) =>
      _$IncomeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeDtoToJson(this);
}

@JsonSerializable()
class IncomeResponseDto {
  @JsonKey(name: 'server_id')
  final String serverId;
  @JsonKey(name: 'synced_at')
  final String syncedAt;

  const IncomeResponseDto({
    required this.serverId,
    required this.syncedAt,
  });

  factory IncomeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$IncomeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeResponseDtoToJson(this);
}