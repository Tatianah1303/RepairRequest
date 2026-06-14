import 'package:flutter/material.dart';
import 'infrastructure/services.dart';
import 'presentation/pages/ConnexionPage.dart';
import 'presentation/pages/AcceuilPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Services.loadSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        Services.authToken != null && Services.authToken!.isNotEmpty;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REPARREQUEST',
      theme: ThemeData(
        primaryColor: const Color(0xFF6A1B9A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          primary: const Color(0xFF6A1B9A),
          secondary: const Color(0xFFF57C00),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: isLoggedIn ? const AccueilPage() : const ConnexionPage(),
    );
  }
}
