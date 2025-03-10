import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    fontFamily: 'TTHoves',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        // Размер шрифта текста
        textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 16.0)),
        // Цвет текста и иконок (белый)
        foregroundColor: WidgetStateProperty.all(Colors.white),
        // Цвет фона кнопки
        backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey.shade400; // Цвет кнопки когда она отключена
          }
          return Colors.blue; // Цвет кнопки когда она активна
        }),
        // Форма кнопки (скругленные углы)
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        // Padding внутри кнопки
        padding: WidgetStateProperty.all(
          const EdgeInsets.all(16.0), // Padding 8.0 со всех сторон
        ),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSurface: Colors.grey,
      error: Colors.grey,
      onError: Colors.grey,
      primary: Colors.blue,
      onSecondary: Colors.black,
      surface: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(foregroundColor: Colors.black),
    brightness: Brightness.dark,
  );

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}
