import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F5FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F5FF),
          foregroundColor: Color(0xFF1A1A2E),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFC9C4F0),
            disabledForegroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6C5CE7),
            minimumSize: const Size(100, 54),
            side: const BorderSide(color: Color(0xFFD8D4F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF6C5CE7),
          selectionColor: Color(0x336C5CE7),
          selectionHandleColor: Color(0xFF6C5CE7),
        ),
      ),
      home: const FormPage(),
    );
  }
}