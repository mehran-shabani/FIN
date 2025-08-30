import 'package:json_annotation/json_annotation.dart';
import 'expense_dto.dart';

part 'ocr_dto.g.dart';

@JsonSerializable()
class OcrReceiptResponse {
  final double amount;
  final String currency;
  final String date; // YYYY-MM-DD format
  final String? merchant;
  final List<ExpenseItemDto> items;
  final double tax;
  final double tip;
  final String? notes;
  final String category;

  const OcrReceiptResponse({
    required this.amount,
    required this.currency,
    required this.date,
    this.merchant,
    required this.items,
    this.tax = 0,
    this.tip = 0,
    this.notes,
    required this.category,
  });

  factory OcrReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrReceiptResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OcrReceiptResponseToJson(this);
}

@JsonSerializable()
class CategoryRequest {
  final String? merchant;
  final List<ExpenseItemDto> items;
  final String? note;

  const CategoryRequest({this.merchant, required this.items, this.note});

  factory CategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryRequestToJson(this);
}

@JsonSerializable()
class CategoryResponse {
  final String category;

  const CategoryResponse({required this.category});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}
