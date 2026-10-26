import 'dart:math' as math;

import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Screen size categories
  bool get isVerySmallPhone => screenWidth < 350 || screenHeight < 640;
  bool get isSmallPhone => screenWidth < 380 || screenHeight < 720;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;

  // Responsive scale factors
  double get scaleFactor {
    if (screenWidth < 350) return 0.85;
    if (screenWidth < 380) return 0.92;
    if (screenWidth > 600) return 1.05;
    return 1.0;
  }

  // Adaptive font scaling
  double sp(double fontSize) {
    return (fontSize * scaleFactor).clamp(fontSize * 0.82, fontSize * 1.15);
  }

  // Adaptive vertical spacing
  double vSpace(double base) {
    if (screenHeight < 650) return math.max(4.0, base * 0.55);
    if (screenHeight < 720) return math.max(6.0, base * 0.75);
    return base;
  }

  // Adaptive horizontal padding
  double get horizontalPadding {
    if (isVerySmallPhone) return 12.0;
    if (isSmallPhone) return 14.0;
    if (isTablet) return 24.0;
    return 18.0;
  }
}

/// A responsive wrapper that automatically centers and constrains layouts
/// for mobile, tablet, and desktop viewing.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxMobileWidth;
  final bool enableScroll;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxMobileWidth = 460.0,
    this.enableScroll = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxMobileWidth),
        child: child,
      ),
    );

    if (enableScroll) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: content,
      );
    } else if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}
