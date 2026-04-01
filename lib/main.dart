// ── main.dart ─────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VitBloodBankApp());
}

class VitBloodBankApp extends StatelessWidget {
  const VitBloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIT Blood Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB11226),
          primary: const Color(0xFFB11226),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB11226),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
