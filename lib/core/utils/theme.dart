import 'package:flutter/material.dart';
import 'package:taminotchi_app/core/utils/styles.dart';

import 'colors.dart';

class AppTheme {
  final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    fontFamily: 'Poppins',
    cardColor: AppColors.white,
    primaryColor: AppColors.mainBlue,
    iconTheme: const IconThemeData(color: AppColors.gray700),
    dividerColor: AppColors.gray200,
    hintColor: AppColors.gray400,
    textTheme: TextTheme(
      bodyMedium: AppStyles.bodyRegular.copyWith(color: AppColors.gray900),
      bodySmall: AppStyles.bodySmall.copyWith(color: AppColors.gray700),
      titleMedium: AppStyles.h5Bold.copyWith(color: AppColors.gray900),
    ),
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.mainBlue,
      titleTextStyle: AppStyles.h2Bold,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Poppins',
    cardColor: AppColors.darkCard,
    primaryColor: AppColors.mainBlue,
    iconTheme: const IconThemeData(color: AppColors.gray100),
    dividerColor: AppColors.gray700,
    hintColor: AppColors.gray400,
    textTheme: TextTheme(
      bodyMedium: AppStyles.bodyRegular.copyWith(color: AppColors.gray100),
      bodySmall: AppStyles.bodySmall.copyWith(color: AppColors.gray200),
      titleMedium: AppStyles.h5Bold.copyWith(color: AppColors.gray100),
    ),
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.darkBackground,
      titleTextStyle: AppStyles.h2Bold.copyWith(color: AppColors.gray100),
    ),
  );
}
