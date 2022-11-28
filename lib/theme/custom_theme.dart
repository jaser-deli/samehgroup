import 'package:flutter/material.dart';

class CustomTheme {
  static final Color occur = Color(0xffb38220);
  static final Color peach = Color(0xffe09c5f);
  static final Color skyBlue = Color(0xff639fdc);
  static final Color darkGreen = Color(0xff226e79);
  static final Color red = Color(0xfff8575e);
  static final Color purple = Color(0xff9f50bf);
  static final Color pink = Color(0xffd17b88);
  static final Color brown = Color(0xffbd631a);
  static final Color blue = Color(0xff1a71bd);
  static final Color green = Color(0xff068425);
  static final Color yellow = Color(0xfffff44f);
  static final Color orange = Color(0xffFFA500);

  final Color card,
      cardDark,
      border,
      borderDark,
      disabledColor,
      onDisabled,
      colorInfo,
      colorWarning,
      colorSuccess,
      colorError,
      shadowColor,
      onInfo,
      onWarning,
      onSuccess,
      onError,
      shimmerBaseColor,
      shimmerHighlightColor;

  final Color Primary, OnPrimary;

  final Color lightBlack, violet, indigo;

  final Color muviPrimary, muviOnPrimary;

  final Color fitnessPrimary,
      fitnessOnPrimary,
      magenta,
      oliveGreen,
      carolinaBlue;

  CustomTheme({
    this.border = const Color(0xffeeeeee),
    this.borderDark = const Color(0xffe6e6e6),
    this.card = const Color(0xfff0f0f0),
    this.cardDark = const Color(0xfffefefe),
    this.disabledColor = const Color(0xffdcc7ff),
    this.onDisabled = const Color(0xffffffff),
    this.colorWarning = const Color(0xffffc837),
    this.colorInfo = const Color(0xffff784b),
    this.colorSuccess = const Color(0xff3cd278),
    this.shadowColor = const Color(0xff1f1f1f),
    this.onInfo = const Color(0xffffffff),
    this.onWarning = const Color(0xffffffff),
    this.onSuccess = const Color(0xffffffff),
    this.colorError = const Color(0xfff0323c),
    this.onError = const Color(0xffffffff),
    this.shimmerBaseColor = const Color(0xFFF5F5F5),
    this.shimmerHighlightColor = const Color(0xFFE0E0E0),

    //
    this.Primary = const Color(0xfffe0000),
    this.OnPrimary = const Color(0xffffffff),

    //Color
    this.lightBlack = const Color(0xffa7a7a7),
    this.indigo = const Color(0xff4B0082),
    this.violet = const Color(0xff9400D3),

    //Muvi Color Scheme
    this.muviPrimary = const Color(0xff4B97C5),
    this.muviOnPrimary = const Color(0xffffffff),

    //Fitness Primary
    this.fitnessPrimary = const Color(0xff2D72F0),
    this.fitnessOnPrimary = const Color(0xffFAF9F9),
    this.magenta = const Color(0xff8B5587),
    this.oliveGreen = const Color(0xff4aa359),
    this.carolinaBlue = const Color(0xff069DEF),
  });

  //--------------------------------------  Custom App Theme ----------------------------------------//

  static final CustomTheme lightCustomTheme = CustomTheme(
      card: Color(0xfff6f6f6),
      cardDark: Color(0xfff0f0f0),
      disabledColor: Color(0xff636363),
      onDisabled: Color(0xffffffff),
      colorInfo: Color(0xffff784b),
      colorWarning: Color(0xffffc837),
      colorSuccess: Color(0xff3cd278),
      shadowColor: Color(0xffd9d9d9),
      onInfo: Color(0xffffffff),
      onSuccess: Color(0xffffffff),
      onWarning: Color(0xffffffff),
      colorError: Color(0xfff0323c),
      onError: Color(0xffffffff),
      shimmerBaseColor: Color(0xFFF5F5F5),
      shimmerHighlightColor: Color(0xFFE0E0E0));

  static final CustomTheme darkCustomTheme = CustomTheme(
      card: Color(0xff222327),
      cardDark: Color(0xff101010),
      border: Color(0xff303030),
      borderDark: Color(0xff363636),
      disabledColor: Color(0xffbababa),
      onDisabled: Color(0xff000000),
      colorInfo: Color(0xffff784b),
      colorWarning: Color(0xffffc837),
      colorSuccess: Color(0xff3cd278),
      shadowColor: Color(0xff202020),
      onInfo: Color(0xffffffff),
      onSuccess: Color(0xffffffff),
      onWarning: Color(0xffffffff),
      colorError: Color(0xfff0323c),
      onError: Color(0xffffffff),
      shimmerBaseColor: Color(0xFF1a1a1a),
      shimmerHighlightColor: Color(0xFF454545));
}
