// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeDto _$IncomeDtoFromJson(Map<String, dynamic> json) => IncomeDto(
      clientId: json['client_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: json['date'] as String,
      source: json['source'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$IncomeDtoToJson(IncomeDto instance) => <String, dynamic>{
      'client_id': instance.clientId,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date,
      'source': instance.source,
      'note': instance.note,
    };

IncomeResponseDto _$IncomeResponseDtoFromJson(Map<String, dynamic> json) =>
    IncomeResponseDto(
      serverId: json['server_id'] as String,
      syncedAt: json['synced_at'] as String,
    );

Map<String, dynamic> _$IncomeResponseDtoToJson(IncomeResponseDto instance) =>
    <String, dynamic>{
      'server_id': instance.serverId,
      'synced_at': instance.syncedAt,
    };
