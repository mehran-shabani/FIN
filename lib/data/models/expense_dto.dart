import 'package:json_annotation/json_annotation.dart';

part 'expense_dto.g.dart';

@JsonSerializable()
class ExpenseDto {
  @JsonKey(name: 'client_id')
  final String clientId;
  final double amount;
  final String currency;
  final String date; // YYYY-MM-DD format
  final String? merchant;
  final String category;
  final double tax;
  final double tip;
  final String? note;
  final String source; // 'receipt' or 'manual'

  const ExpenseDto({
    required this.clientId,
    required this.amount,
    required this.currency,
    required this.date,
    this.merchant,
    required this.category,
    this.tax = 0,
    this.tip = 0,
    this.note,
    this.source = 'manual',
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseDtoToJson(this);
}

@JsonSerializable()
class ExpenseResponseDto {
  @JsonKey(name: 'server_id')
  final String serverId;
  @JsonKey(name: 'synced_at')
  final String syncedAt;

  const ExpenseResponseDto({required this.serverId, required this.syncedAt});

  factory ExpenseResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseResponseDtoToJson(this);
}

@JsonSerializable()
class ExpenseItemDto {
  final String name;
  final int qty;
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  const ExpenseItemDto({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  factory ExpenseItemDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseItemDtoToJson(this);
}
