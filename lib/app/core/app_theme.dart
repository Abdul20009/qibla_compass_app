import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/colors.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme:  ColorScheme.light(
    primary: primary,
    primaryContainer: greenAccent,
    secondaryContainer: Colors.black,
  ),
  primaryColor: primary,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: Color(0xff8f8f8f),
      ), // Border color when not focused
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        color: primary,
        width: 2.0,
      ), // Border color when focused
    ),
    hintStyle: TextStyle(
      height: 1,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: greenAccent,
      fontFamily: "Manrope",
      fontSize: 13,
    ),
  ),
  radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(primary)),
  checkboxTheme: CheckboxThemeData(side: BorderSide(color: primary)),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primary),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(
      height: 1,
      fontWeight: FontWeight.w400,
      color: grey,
      fontFamily: "Poppins",
      fontSize: 16,
    ),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: "Manrope",
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    ),
    displayMedium: TextStyle(
      fontFamily: "Manrope",
      fontSize: 18,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w800,
    ),
    displaySmall: TextStyle(
      fontSize: 14,
      fontFamily: "Manrope",
      fontWeight: FontWeight.w400,
      color: Colors.black,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontFamily: "Manrope",
      fontWeight: FontWeight.w800,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontFamily: "Manrope",
      fontSize: 14,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontFamily: "Manrope",
      fontSize: 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontFamily: "Manrope",
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    bodyMedium: TextStyle(
      fontSize: 10,
      fontFamily: "Manrope",
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontFamily: "Manrope",
      letterSpacing: -0.2,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(fontFamily: "Manrope"),
    labelMedium: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      fontFamily: "Manrope",
    ),
    labelSmall: TextStyle(
      fontFamily: "Manrope",
      fontSize: 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
    headlineLarge: TextStyle(fontFamily: "Manrope"),
    headlineMedium: TextStyle(fontFamily: "Manrope"),
    headlineSmall: TextStyle(
      fontFamily: "Manrope",
      fontSize: 10,
      letterSpacing: 0,
      fontWeight: FontWeight.w800,
      color: grey,
    ),
  ),
);

// ThemeData appDarkTheme = ThemeData(
//   colorScheme: const ColorScheme.dark(
//     primary: Colors.white,
//     primaryContainer: appColor,
//     secondaryContainer: Colors.black,
//   ),
//   primaryColor: appColor,
//   brightness: Brightness.dark,
//   inputDecorationTheme: InputDecorationTheme(
//     hintStyle: const TextStyle(
//       color: lightAppColor,
//     ),
//   ),
// );
