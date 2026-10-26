import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class GlassTheme {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
    border: Border.all(
      color: AppColors.glassBorder,
      width: AppDimensions.borderWidthStandard,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColors.glassWhiteInput,
    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    border: Border.all(
      color: AppColors.glassBorder,
      width: AppDimensions.borderWidthStandard,
    ),
  );

  static BoxDecoration get activeChipDecoration => BoxDecoration(
    gradient: AppColors.orangeGradient,
    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryOrange.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration get inactiveChipDecoration => BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    border: Border.all(
      color: AppColors.glassBorder,
      width: AppDimensions.borderWidthStandard,
    ),
  );

  static BoxDecoration get orangeButtonDecoration => BoxDecoration(
    gradient: AppColors.buttonGradient,
    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryOrange.withOpacity(0.45),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get iconButtonDecoration => BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    border: Border.all(
      color: AppColors.glassBorderLight,
      width: AppDimensions.borderWidthStandard,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
