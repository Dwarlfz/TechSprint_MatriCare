import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash/splash_page.dart';

class MatriCareApp extends StatelessWidget {
  final String initialLanguage;
  const MatriCareApp({super.key, required this.initialLanguage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatriCare',

      // Set user-preferred language
      locale: Locale(initialLanguage),

      // Supported languages
      supportedLocales: const [
        Locale("en"),
        Locale("hi"),
        Locale("kn"),
        Locale("ta"),
        Locale("te"),
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      home: const SplashPage(),

      // Route generator — must match your AppRoutes class
      onGenerateRoute: AppRoutes().onGenerateRoute,
    );
  }
}
