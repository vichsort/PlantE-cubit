import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF66BB6A);

  // Tema Claro (Light Theme)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(elevation: 0),
    cardTheme: CardThemeData(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _seedColor,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _seedColor.withAlpha(
        200,
      ),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? const TextStyle(fontWeight: FontWeight.bold)
            : const TextStyle(),
      ),
    ),
  );

  // Tema Escuro (Dark Theme)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(),
    cardTheme: CardThemeData(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _seedColor, // Mantém a cor semente no FAB escuro
      foregroundColor: Colors.black87, // Ícone escuro no FAB verde
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _seedColor.withAlpha(300),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? const TextStyle(fontWeight: FontWeight.bold)
            : const TextStyle(),
      ),
    ),

    // fontFamily: 'Roboto',
    // textTheme: const TextTheme( ... ), // Pode definir cores de texto diferentes se necessário
  );
}
