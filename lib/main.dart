import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/database/database.dart';
import 'services/api_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/income/bloc/income_bloc.dart';
import 'features/expense/bloc/expense_bloc.dart';
import 'features/ocr/bloc/ocr_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final settingsService = await SettingsService.getInstance();
  final notificationService = await NotificationService.getInstance();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    FinSnapApp(
      settingsService: settingsService,
      notificationService: notificationService,
    ),
  );
}

class FinSnapApp extends StatelessWidget {
  final SettingsService settingsService;
  final NotificationService notificationService;

  const FinSnapApp({
    super.key,
    required this.settingsService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>(create: (context) => AppDatabase()),
        RepositoryProvider<ApiService>(
          create: (context) =>
              ApiService(apiKey: SettingsService.backendApiKey),
        ),
        RepositoryProvider<SettingsService>.value(value: settingsService),
        RepositoryProvider<NotificationService>.value(
          value: notificationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<IncomeBloc>(
            create: (context) => IncomeBloc(
              database: context.read<AppDatabase>(),
              apiService: context.read<ApiService>(),
              settingsService: context.read<SettingsService>(),
            ),
          ),
          BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(
              database: context.read<AppDatabase>(),
              apiService: context.read<ApiService>(),
              settingsService: context.read<SettingsService>(),
            ),
          ),
          BlocProvider<OcrBloc>(
            create: (context) => OcrBloc(
              apiService: context.read<ApiService>(),
              settingsService: context.read<SettingsService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: SettingsService.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light, // Force light theme for monochrome design
          // Localization
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
          locale: Locale(settingsService.getLanguage(), 'IR'),

          // RTL support
          builder: (context, child) {
            return Directionality(
              textDirection: settingsService.getLanguage() == 'fa'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },

          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
