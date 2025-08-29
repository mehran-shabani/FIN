import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/income_dto.dart';
import '../data/models/expense_dto.dart';
import '../data/models/ocr_dto.dart';
import '../data/models/chat_dto.dart';
import '../data/models/common_dto.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://golddrop.ir/api/finapp/v1';
  
  ApiService({String? apiKey}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'X-API-Key': apiKey,
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      logPrint: (object) {
        if (kDebugMode) print(object);
      },
    ));
  }

  void setHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Health and Config
  Future<HealthResponse> getHealth() async {
    final response = await _dio.get('/health');
    return HealthResponse.fromJson(response.data);
  }

  Future<AppConfigResponse> getAppConfig() async {
    final response = await _dio.get('/app/config');
    return AppConfigResponse.fromJson(response.data);
  }

  // Data sync endpoints
  Future<IncomeResponseDto> syncIncome(IncomeDto income) async {
    final response = await _dio.post('/data/incomes', data: income.toJson());
    return IncomeResponseDto.fromJson(response.data);
  }

  Future<ExpenseResponseDto> syncExpense(ExpenseDto expense) async {
    final response = await _dio.post('/data/expenses', data: expense.toJson());
    return ExpenseResponseDto.fromJson(response.data);
  }

  Future<ExpenseResponseDto> updateExpense(String serverId, ExpenseDto expense) async {
    final response = await _dio.put('/data/expenses/$serverId', data: expense.toJson());
    return ExpenseResponseDto.fromJson(response.data);
  }

  Future<void> deleteExpense(String serverId) async {
    await _dio.delete('/data/expenses/$serverId');
  }

  Future<SummaryResponse> getDataSummary({
    required String from,
    required String to,
  }) async {
    final response = await _dio.get('/data/summary', queryParameters: {
      'from': from,
      'to': to,
    });
    return SummaryResponse.fromJson(response.data);
  }

  // OCR and AI endpoints
  Future<OcrReceiptResponse> processReceipt(
    Uint8List imageBytes, {
    String? hints,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: 'receipt.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
      if (hints != null) 'hints': hints,
    });

    final response = await _dio.post(
      '/ai/receipt',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
    return OcrReceiptResponse.fromJson(response.data);
  }

  Future<CategoryResponse> categorizeExpense(CategoryRequest request) async {
    final response = await _dio.post('/ai/categorize', data: request.toJson());
    return CategoryResponse.fromJson(response.data);
  }

  Future<ChatResponse> chatWithAI(ChatRequest request) async {
    final response = await _dio.post('/ai/chat', data: request.toJson());
    return ChatResponse.fromJson(response.data);
  }

  Future<InterpretResponse> interpretData(InterpretRequest request) async {
    final response = await _dio.post('/ai/interpret', data: request.toJson());
    return InterpretResponse.fromJson(response.data);
  }

  // Push notifications
  Future<PushRegisterResponse> registerPush(PushRegisterRequest request) async {
    final response = await _dio.post('/push/register', data: request.toJson());
    return PushRegisterResponse.fromJson(response.data);
  }

  Future<void> unregisterPush(PushRegisterRequest request) async {
    await _dio.delete('/push/register', data: request.toJson());
  }

  // Daily evaluation
  Future<ApiResponse> triggerDailyEval(DailyEvalRequest request) async {
    final response = await _dio.post('/eval/daily/trigger', data: request.toJson());
    return ApiResponse.fromJson(response.data);
  }

  Future<DailyEvalResponse> getDailyEval(String date) async {
    final response = await _dio.get('/eval/daily/$date');
    return DailyEvalResponse.fromJson(response.data);
  }

  // Receipt reminders
  Future<ApiResponse> setReceiptReminder(ReceiptReminderRequest request) async {
    final response = await _dio.post('/reminders/receipt', data: request.toJson());
    return ApiResponse.fromJson(response.data);
  }

  // Excel export
  Future<Uint8List> exportExcelMonthly(String month) async {
    final response = await _dio.get(
      '/export/excel',
      queryParameters: {
        'period': 'monthly',
        'month': month,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as Uint8List;
  }

  Future<Uint8List> exportExcelAll() async {
    final response = await _dio.get(
      '/export/excel',
      queryParameters: {'period': 'all'},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as Uint8List;
  }
}