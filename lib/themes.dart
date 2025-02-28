import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_lightTheme);

  static final _lightTheme = ThemeData(
    fontFamily: 'TTHoves',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all<TextStyle>(
          TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.blue),
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
      onSecondary: Colors.blue,
      surface: Colors.blue,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    ),
    scaffoldBackgroundColor: Colors.blue,
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
    ),
    brightness: Brightness.dark,
  );

  /// Toggles the current brightness between light and dark.
  void toggleTheme() {
    emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);
  }
}
