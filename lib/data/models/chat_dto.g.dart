// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

ChatSnapshot _$ChatSnapshotFromJson(Map<String, dynamic> json) => ChatSnapshot(
      month: json['month'] as String,
      byCategory: (json['by_category'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      topMerchants: (json['top_merchants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChatSnapshotToJson(ChatSnapshot instance) =>
    <String, dynamic>{
      'month': instance.month,
      'by_category': instance.byCategory,
      'top_merchants': instance.topMerchants,
    };

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) => ChatRequest(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      snapshot: ChatSnapshot.fromJson(json['snapshot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatRequestToJson(ChatRequest instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'snapshot': instance.snapshot,
    };

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
      text: json['text'] as String,
    );

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

InterpretRequest _$InterpretRequestFromJson(Map<String, dynamic> json) =>
    InterpretRequest(
      period: json['period'] as String,
      signals:
          (json['signals'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$InterpretRequestToJson(InterpretRequest instance) =>
    <String, dynamic>{
      'period': instance.period,
      'signals': instance.signals,
    };

InterpretResponse _$InterpretResponseFromJson(Map<String, dynamic> json) =>
    InterpretResponse(
      summary: json['summary'] as String,
      risks: (json['risks'] as List<dynamic>).map((e) => e as String).toList(),
      tips: (json['tips'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$InterpretResponseToJson(InterpretResponse instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'risks': instance.risks,
      'tips': instance.tips,
    };
