import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class OcrEvent extends Equatable {
  const OcrEvent();

  @override
  List<Object?> get props => [];
}

class ProcessReceiptImage extends OcrEvent {
  final Uint8List imageBytes;
  final String? hints;

  const ProcessReceiptImage({required this.imageBytes, this.hints});

  @override
  List<Object?> get props => [imageBytes, hints];
}

class ClearOcrResult extends OcrEvent {
  const ClearOcrResult();
}

class RetryOcrProcessing extends OcrEvent {
  const RetryOcrProcessing();
}
