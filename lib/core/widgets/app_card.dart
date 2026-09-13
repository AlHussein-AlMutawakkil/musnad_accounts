import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// بطاقة العرض الموحدة للمنظومة (Enterprise Flat Card)
/// تطبق قيود التصميم: زوايا 4px، حد 1px، بدون ظلال ثقيلة
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppDimensions.paddingCard,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = AppDimensions.borderWidth,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppDimensions.borderRadius;
    final effectiveBorderColor = borderColor ?? AppColors.border;
    final effectiveBgColor = backgroundColor ?? AppColors.surface;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
