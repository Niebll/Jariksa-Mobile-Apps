import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_value.dart';
import 'app_typography.dart';

class AppThemeData {
  static ThemeData getThemeLight() {
    Color mainPrimaryColor = ColorValue.primary500;
    
    final MaterialColor primaryMaterialColor = MaterialColor(
      mainPrimaryColor.toARGB32(),
      const <int, Color>{
        50: ColorValue.primary50,
        100: ColorValue.primary100,
        200: ColorValue.primary200,
        300: ColorValue.primary300,
        400: ColorValue.primary400,
        500: ColorValue.primary500,
        600: ColorValue.primary600,
        700: ColorValue.primary700,
        800: ColorValue.primary800,
        900: ColorValue.primary900,
      },
    );

    return ThemeData(
      primaryColor: mainPrimaryColor,
      primarySwatch: primaryMaterialColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ColorValue.neutral50,

      // Konfigurasi bawaan jika terpaksa pakai native AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: ColorValue.primary300,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          backgroundColor: mainPrimaryColor,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: AppTypography.body02.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      
      // Memetakan beberapa tipe default Flutter ke custom kita agar aman
      textTheme: TextTheme(
        bodyMedium: AppTypography.body02.copyWith(color: ColorValue.neutral900),
        titleMedium: AppTypography.body01.copyWith(color: ColorValue.neutral900),
      ),
      
      // =========================================
      // KONFIGURASI TEXT FIELD
      // =========================================
      inputDecorationTheme: InputDecorationTheme(
        // Padding semua sisi 12
        contentPadding: EdgeInsets.all(12.w),
        
        // Style untuk Hint Text (Placeholder) -> neutral400, Body 02 Medium
        hintStyle: AppTypography.body02.copyWith(
          color: ColorValue.neutral400,
          fontWeight: FontWeight.w500,
        ),
        
        // Label style saat nge-float (opsional, jika pakai labelText)
        floatingLabelStyle: AppTypography.body02.copyWith(
          color: ColorValue.primary500,
          fontWeight: FontWeight.w600,
        ),

        // Border default (belum dipencet) -> neutral200
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorValue.neutral200, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        
        // Border saat difokuskan (dipencet) -> primary400
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorValue.primary400, width: 1.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorValue.neutral200),
          borderRadius: BorderRadius.circular(8.r),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorValue.neutral200),
          borderRadius: BorderRadius.circular(8.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}