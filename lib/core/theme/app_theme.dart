import 'package:flutter/material.dart';

class AppTheme {
  // Custom colors
  static const Color primaryBlue = Color(0xFF3D5AFE);
  static const Color deepPurple = Color(0xFF7C4DFF);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color spaceBlack = Color(0xFF0A0A0F);
  static const Color surfaceBlack = Color(0xFF121218);
  static const Color cardBlack = Color(0xFF1A1A23);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: deepPurple,
      tertiary: neonBlue,
      background: Colors.white,
      surface: Colors.white,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.black87,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        color: Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
        letterSpacing: 0.1,
      ),
      labelLarge: TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: spaceBlack,
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: deepPurple,
      tertiary: neonBlue,
      background: spaceBlack,
      surface: surfaceBlack,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        color: Colors.white70,
        fontSize: 16,
        letterSpacing: 0.1,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBlack,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: cardBlack,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
  );
}

class AppColors {
  static const lightGradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F0FE),
      Color(0xFFF0E7FF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const darkGradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0A0F),  // Space Black
      Color(0xFF1A1A2E),  // Deep Blue-Black
      Color(0xFF0F0F1A),  // Dark Purple-Black
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const darkDotGridBackground = BoxDecoration(
    gradient: darkGradientBackground,
    image: DecorationImage(
      image: AssetImage('assets/images/dot_grid_dark.png'),
      repeat: ImageRepeat.repeat,
      opacity: 0.15,
    ),
  );

  static const lightDotGridBackground = BoxDecoration(
    gradient: lightGradientBackground,
    image: DecorationImage(
      image: AssetImage('assets/images/dot_grid_light.png'),
      repeat: ImageRepeat.repeat,
      opacity: 0.1,
    ),
  );

  // Glassmorphism effect for cards in dark mode
  static BoxDecoration get darkGlassCard => BoxDecoration(
    color: AppTheme.cardBlack.withOpacity(0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: -5,
      ),
    ],
  );
}
