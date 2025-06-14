import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marketplace_app_v0/core/config/routes.dart';
import 'package:marketplace_app_v0/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://mlkmrsvvyycqnlvqqkpg.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sa21yc3Z2eXljcW5sdnFxa3BnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0MDU0ODUsImV4cCI6MjA2NDk4MTQ4NX0.PiAsSkKEUJo3evyzU6VqljwMGooxWp_V0gDAm2Jc3C4',
      debug: true,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
  }
  // Comment out for testing: HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zauro',
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.onboarding,
      routes: AppRoutes.getRoutes(),
    );
  }
}
