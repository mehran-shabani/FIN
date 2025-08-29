// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseDto _$ExpenseDtoFromJson(Map<String, dynamic> json) => ExpenseDto(
      clientId: json['client_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: json['date'] as String,
      merchant: json['merchant'] as String?,
      category: json['category'] as String,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
      source: json['source'] as String? ?? 'manual',
    );

Map<String, dynamic> _$ExpenseDtoToJson(ExpenseDto instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date,
      'merchant': instance.merchant,
      'category': instance.category,
      'tax': instance.tax,
      'tip': instance.tip,
      'note': instance.note,
      'source': instance.source,
    };

ExpenseResponseDto _$ExpenseResponseDtoFromJson(Map<String, dynamic> json) =>
    ExpenseResponseDto(
      serverId: json['server_id'] as String,
      syncedAt: json['synced_at'] as String,
    );

Map<String, dynamic> _$ExpenseResponseDtoToJson(ExpenseResponseDto instance) =>
    <String, dynamic>{
      'server_id': instance.serverId,
      'synced_at': instance.syncedAt,
    };

ExpenseItemDto _$ExpenseItemDtoFromJson(Map<String, dynamic> json) =>
    ExpenseItemDto(
      name: json['name'] as String,
      qty: (json['qty'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseItemDtoToJson(ExpenseItemDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'qty': instance.qty,
      'unit_price': instance.unitPrice,
    };
