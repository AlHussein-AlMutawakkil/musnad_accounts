import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// خط فاصل دقيق وموحد لكافة القوائم والبطاقات
class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  const AppDivider({
    super.key,
    this.height = AppDimensions.space8,
    this.thickness = AppDimensions.borderWidth,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.divider,
    );
  }
}
