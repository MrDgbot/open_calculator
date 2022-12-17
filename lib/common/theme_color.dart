import 'package:flutter/material.dart';

/// 主题配色
class ThemeColor {
  ThemeColor._();

  static ThemeData darkTheme = ThemeData().copyWith(
    primaryColor: const Color.fromARGB(255, 98, 101, 151),
    backgroundColor: const Color.fromARGB(255, 98, 101, 151),
    scaffoldBackgroundColor: const Color.fromARGB(255, 98, 101, 151),
    textTheme: const TextTheme(
      headline1: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      headline2: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      headline3: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      headline4: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      headline5: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
      bodyText1: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      subtitle1: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      subtitle2: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      button: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      caption: TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
      overline: TextStyle(
        color: Colors.white,
        fontSize: 8,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
      textTheme: ButtonTextTheme.primary,
    ),
    textButtonTheme:  TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: const Color.fromARGB(255, 98, 101, 151)),
  );
}
