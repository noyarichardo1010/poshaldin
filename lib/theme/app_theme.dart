import 'package:flutter/material.dart';
import 'package:poshaldin/assets.dart';
import 'package:poshaldin/theme/button_theme.dart';
import 'package:poshaldin/theme/input_decoration_theme.dart';

import 'package:poshaldin/theme/checkbox_themedata.dart';
import 'package:poshaldin/theme/theme_data.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: "Plus Jakarta",
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: blackColor40)),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }
}
