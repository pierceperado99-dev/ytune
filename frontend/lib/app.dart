import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTune',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      home: const HomePage(),
    );
  }

  ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF6C63FF),
      onPrimary: Colors.white,
      secondary: Color(0xFF03DAC6),
      onSecondary: Colors.black,
      surface: Color(0xFF181818),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      canvasColor: const Color(0xFF0A0A0A),
      cardColor: const Color(0xFF1A1A1A),
      dividerColor: Colors.white.withAlpha(12),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              headlineLarge: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: GoogleFonts.inter(color: Colors.white),
              bodyMedium: GoogleFonts.inter(color: Colors.grey[300]),
              bodySmall: GoogleFonts.inter(color: Colors.grey[500]),
            ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
