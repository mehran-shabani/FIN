import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../data/models/ocr_dto.dart';

abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object?> get props => [];
}

class OcrInitial extends OcrState {
  const OcrInitial();
}

class OcrProcessing extends OcrState {
  final Uint8List imageBytes;

  const OcrProcessing(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

class OcrSuccess extends OcrState {
  final Uint8List imageBytes;
  final OcrReceiptResponse result;

  const OcrSuccess({
    required this.imageBytes,
    required this.result,
  });

  @override
  List<Object?> get props => [imageBytes, result];
}

class OcrError extends OcrState {
  final String message;
  final Uint8List? imageBytes;

  const OcrError({
    required this.message,
    this.imageBytes,
  });

  @override
  List<Object?> get props => [message, imageBytes];
}