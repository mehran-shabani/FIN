// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OcrReceiptResponse _$OcrReceiptResponseFromJson(Map<String, dynamic> json) =>
    OcrReceiptResponse(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: json['date'] as String,
      merchant: json['merchant'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => ExpenseItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      category: json['category'] as String,
    );

Map<String, dynamic> _$OcrReceiptResponseToJson(OcrReceiptResponse instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date,
      'merchant': instance.merchant,
      'items': instance.items,
      'tax': instance.tax,
      'tip': instance.tip,
      'notes': instance.notes,
      'category': instance.category,
    };

CategoryRequest _$CategoryRequestFromJson(Map<String, dynamic> json) =>
    CategoryRequest(
      merchant: json['merchant'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => ExpenseItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CategoryRequestToJson(CategoryRequest instance) =>
    <String, dynamic>{
      'merchant': instance.merchant,
      'items': instance.items,
      'note': instance.note,
    };

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(category: json['category'] as String);

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{'category': instance.category};
