import 'package:flutter/material.dart';

/// الأبعاد والمسافات الموحدة لمنظومة التصميم (Enterprise / Dense)
/// مستندة إلى وثيقة docs/DESIGN_SYSTEM.md
class AppDimensions {
  AppDimensions._();

  // 1. استدارة الحواف (BorderRadius) - المنظومة تعتمد زوايا مستقيمة خفيفة = 4.0
  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0; // الأساسي والمعتمد في النظام
  static const double radiusLg = 8.0;

  static const BorderRadius borderRadiusNone = BorderRadius.zero;
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radiusMd)); // الافتراضي 4.0
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));

  // 2. سماكة الحدود (Borders) - حدود واضحة 1px
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // 3. المسافات القياسية (Spacing & Padding)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // 4. الحشوات الجاهزة للاستخدام السريع (EdgeInsets)
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAll4 = EdgeInsets.all(space4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(space12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);

  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(horizontal: space12);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: space16);

  static const EdgeInsets paddingVertical4 = EdgeInsets.symmetric(vertical: space4);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: space12);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: space16);

  /// حشوة البطاقات القياسية
  static const EdgeInsets paddingCard = EdgeInsets.all(space12);

  /// حشوة الشاشات العامة
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: space16, vertical: space12);

  /// حشوة مربعات الحوار والأوراق السفلية
  static const EdgeInsets paddingDialog = EdgeInsets.all(space20);

  /// حشوة عناصر القوائم
  static const EdgeInsets paddingListItem = EdgeInsets.symmetric(horizontal: space16, vertical: space10);

  // 5. ارتفاعات وأحجام المكونات (Component Sizes)
  static const double buttonHeight = 44.0;
  static const double buttonHeightSm = 36.0;
  static const double inputHeight = 44.0;
  static const double inputHeightSm = 38.0;
  static const double kpiCardMinHeight = 84.0;
  static const double appBarHeight = 56.0;
  static const double bottomBarHeight = 60.0;
  static const double fabSize = 56.0;

  // 6. أحجام الأيقونات (Icon Sizes)
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 26.0;
  static const double iconXl = 32.0;
}
