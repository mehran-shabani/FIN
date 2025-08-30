import 'package:json_annotation/json_annotation.dart';

part 'chat_dto.g.dart';

@JsonSerializable()
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class ChatSnapshot {
  final String month; // YYYY-MM format
  @JsonKey(name: 'by_category')
  final Map<String, double> byCategory;
  @JsonKey(name: 'top_merchants')
  final List<String> topMerchants;

  const ChatSnapshot({
    required this.month,
    required this.byCategory,
    required this.topMerchants,
  });

  factory ChatSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ChatSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$ChatSnapshotToJson(this);
}

@JsonSerializable()
class ChatRequest {
  final List<ChatMessage> messages;
  final ChatSnapshot snapshot;

  const ChatRequest({required this.messages, required this.snapshot});

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}

@JsonSerializable()
class ChatResponse {
  final String text;

  const ChatResponse({required this.text});

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class InterpretRequest {
  final String period; // YYYY-MM format
  final List<String>? signals;

  const InterpretRequest({required this.period, this.signals});

  factory InterpretRequest.fromJson(Map<String, dynamic> json) =>
      _$InterpretRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretRequestToJson(this);
}

@JsonSerializable()
class InterpretResponse {
  final String summary;
  final List<String> risks;
  final List<String> tips;

  const InterpretResponse({
    required this.summary,
    required this.risks,
    required this.tips,
  });

  factory InterpretResponse.fromJson(Map<String, dynamic> json) =>
      _$InterpretResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretResponseToJson(this);
}
