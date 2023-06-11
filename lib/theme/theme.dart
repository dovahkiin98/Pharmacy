import 'package:flutter/material.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  ),
);

const colorScheme = ColorScheme.dark();
