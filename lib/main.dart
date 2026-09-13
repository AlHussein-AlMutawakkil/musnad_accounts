import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'controllers/controllers.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'views/views.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusnadApp());
}

/// التطبيق الرئيسي (مُسند - للحسابات والديون)
class MusnadApp extends StatelessWidget {
  const MusnadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrencyController>(
          create: (_) => CurrencyController(),
        ),
        ChangeNotifierProvider<CategoryController>(
          create: (_) => CategoryController(),
        ),
        ChangeNotifierProvider<AccountController>(
          create: (_) => AccountController(),
        ),
        ChangeNotifierProvider<TransactionController>(
          create: (_) => TransactionController(),
        ),
        ChangeNotifierProvider<TransferController>(
          create: (_) => TransferController(),
        ),
      ],
      child: MaterialApp(
        title: 'مُسند - الحسابات والديون',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primaryLight,
            surface: AppColors.surface,
            background: AppColors.background,
            error: AppColors.debit,
            onPrimary: AppColors.textOnPrimary,
            onSurface: AppColors.textPrimary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: const CardTheme(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadius,
              side: BorderSide(color: AppColors.border, width: AppDimensions.borderWidth),
            ),
          ),
        ),
        locale: const Locale('ar', 'YE'),
        supportedLocales: const [
          Locale('ar', 'YE'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShellView(),
      ),
    );
  }
}
