import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/api_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/rule_engine.dart';
import '../../../data/models/ocr_dto.dart';
import '../../../data/models/expense_dto.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final ApiService _apiService;
  final SettingsService _settingsService;
  Uint8List? _lastImageBytes;
  String? _lastHints;

  OcrBloc({
    required ApiService apiService,
    required SettingsService settingsService,
  })  : _apiService = apiService,
        _settingsService = settingsService,
        super(const OcrInitial()) {
    on<ProcessReceiptImage>(_onProcessReceiptImage);
    on<ClearOcrResult>(_onClearOcrResult);
    on<RetryOcrProcessing>(_onRetryOcrProcessing);
  }

  Future<void> _onProcessReceiptImage(
    ProcessReceiptImage event,
    Emitter<OcrState> emit,
  ) async {
    try {
      emit(OcrProcessing(event.imageBytes));
      
      _lastImageBytes = event.imageBytes;
      _lastHints = event.hints;

      // Check if user consented to upload receipts to cloud
      if (!_settingsService.hasReceiptUploadConsent() || !SettingsService.sendReceiptsToCloud) {
        // Use local rule engine only
        final result = _processReceiptLocally(event.imageBytes, event.hints);
        emit(OcrSuccess(
          imageBytes: event.imageBytes,
          result: result,
        ));
        return;
      }

      try {
        // Process with backend OCR
        final result = await _apiService.processReceipt(
          event.imageBytes,
          hints: event.hints,
        );

        emit(OcrSuccess(
          imageBytes: event.imageBytes,
          result: result,
        ));
      } catch (e) {
        // Fallback to local processing if backend fails
        print('Backend OCR failed, falling back to local: $e');
        final result = _processReceiptLocally(event.imageBytes, event.hints);
        emit(OcrSuccess(
          imageBytes: event.imageBytes,
          result: result,
        ));
      }
    } catch (e) {
      emit(OcrError(
        message: 'خطا در پردازش رسید: ${e.toString()}',
        imageBytes: event.imageBytes,
      ));
    }
  }

  Future<void> _onClearOcrResult(
    ClearOcrResult event,
    Emitter<OcrState> emit,
  ) async {
    _lastImageBytes = null;
    _lastHints = null;
    emit(const OcrInitial());
  }

  Future<void> _onRetryOcrProcessing(
    RetryOcrProcessing event,
    Emitter<OcrState> emit,
  ) async {
    if (_lastImageBytes != null) {
      add(ProcessReceiptImage(
        imageBytes: _lastImageBytes!,
        hints: _lastHints,
      ));
    }
  }

  OcrReceiptResponse _processReceiptLocally(Uint8List imageBytes, String? hints) {
    // Basic local processing - extract what we can from hints
    // In a real implementation, you might use a local OCR library like ML Kit
    
    final now = DateTime.now();
    final defaultCategory = 'other';
    
    // Try to parse hints for basic information
    double amount = 0;
    String merchant = '';
    String category = defaultCategory;
    
    if (hints != null && hints.isNotEmpty) {
      // Simple parsing - look for numbers and merchant names
      final numbers = RegExp(r'\d+\.?\d*').allMatches(hints);
      if (numbers.isNotEmpty) {
        final lastNumber = numbers.last.group(0);
        amount = double.tryParse(lastNumber ?? '0') ?? 0;
      }
      
      // Extract merchant name (first words that are not numbers)
      final words = hints.split(' ').where((word) => 
        word.isNotEmpty && !RegExp(r'^\d+\.?\d*$').hasMatch(word)
      ).toList();
      
      if (words.isNotEmpty) {
        merchant = words.take(3).join(' ');
        category = RuleEngine.categorizeExpense(merchant: merchant);
      }
    }

    return OcrReceiptResponse(
      amount: amount,
      currency: _settingsService.getCurrency(),
      date: _formatDate(now),
      merchant: merchant.isNotEmpty ? merchant : null,
      items: amount > 0 ? [
        ExpenseItemDto(
          name: merchant.isNotEmpty ? merchant : 'خرید',
          qty: 1,
          unitPrice: amount,
        )
      ] : [],
      tax: 0,
      tip: 0,
      notes: hints,
      category: category,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}