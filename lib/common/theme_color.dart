import 'package:flutter/material.dart';

/// 主题配色
class ThemeColor {
  ThemeColor._();

  static ThemeData darkTheme = ThemeData(fontFamily: 'mono').copyWith(
    primaryColor: const Color.fromARGB(255, 98, 101, 151),
    backgroundColor: const Color.fromARGB(255, 98, 101, 151),
    scaffoldBackgroundColor: const Color.fromARGB(255, 98, 101, 151),
    textTheme: const TextTheme(
      headline1:
          TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'mono'),
      headline2:
          TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'mono'),
      headline3:
          TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'mono'),
      headline4:
          TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'mono'),
      headline5:
          TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'mono'),
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
      bodyText1:
          TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'mono'),
      bodyText2:
          TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'mono'),
      subtitle1:
          TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'mono'),
      subtitle2:
          TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'mono'),
      button: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      caption: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'mono'),
      overline: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'mono'),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.white,
      textTheme: ButtonTextTheme.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: const Color.fromARGB(255, 98, 101, 151)),
  );
}
