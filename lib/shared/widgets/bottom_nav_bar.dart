import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class ShopEasyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ShopEasyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallPhone;
    final isVerySmall = context.isVerySmallPhone;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: EdgeInsets.fromLTRB(
          isVerySmall ? 8 : (isSmall ? 12 : 16),
          0,
          isVerySmall ? 8 : (isSmall ? 12 : 16),
          bottomInset > 0 ? (bottomInset + 4) : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.38),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.68),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmall ? 4 : 8,
                vertical: isSmall ? 6 : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_rounded, 'Home'),
                  _buildNavItem(context, 1, Icons.trending_up_rounded, 'Demand'),
                  _buildNavItem(context, 2, Icons.inventory_2_rounded, 'Products'),
                  _buildNavItem(context, 3, Icons.assignment_outlined, 'Orders'),
                  _buildNavItem(context, 4, Icons.grid_view_rounded, 'More'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final isSmall = context.isSmallPhone;
    final isVerySmall = context.isVerySmallPhone;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(24),
      splashColor: AppColors.primaryOrange.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? EdgeInsets.symmetric(
                horizontal: isVerySmall ? 8 : (isSmall ? 11 : 16),
                vertical: isSmall ? 6 : 8,
              )
            : EdgeInsets.symmetric(
                horizontal: isVerySmall ? 4 : (isSmall ? 7 : 10),
                vertical: isSmall ? 6 : 8,
              ),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFFE0CC).withOpacity(0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isVerySmall ? 19 : (isSmall ? 21 : 23),
              color: isSelected
                  ? AppColors.primaryOrange
                  : const Color(0xFF64748B),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: isVerySmall ? 9.5 : (isSmall ? 10.5 : 11),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : const Color(0xFF64748B),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: isSmall ? 12 : 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ] else ...[
              const SizedBox(height: 5.5),
            ],
          ],
        ),
      ),
    );
  }
}
