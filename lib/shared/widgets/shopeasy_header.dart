import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum HeaderRightAction { none, slogan, profileAndNotification, menuAndNotification, moreMenu }

class ShopEasyHeader extends StatelessWidget {
  final HeaderRightAction rightAction;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;
  final bool hasNotification;
  final bool isInGlassCard;
  final bool showSubtitle;

  const ShopEasyHeader({
    super.key,
    this.rightAction = HeaderRightAction.profileAndNotification,
    this.onNotificationTap,
    this.onProfileTap,
    this.onMenuTap,
    this.hasNotification = true,
    this.isInGlassCard = true,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoAndBrand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D ShopEasy Shopping Bag Logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/shopeasy_bag_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (showSubtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ShopEasy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your Local Shop, Our Priority',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.88),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'ShopEasy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
      ],
    );

    Widget rightWidget = const SizedBox.shrink();

    switch (rightAction) {
      case HeaderRightAction.slogan:
        rightWidget = Transform.rotate(
          angle: -0.06,
          child: Text(
            'Stronger\nSupply Chains\nfor Local\nCommunities',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.92),
              height: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        );
        break;

      case HeaderRightAction.profileAndNotification:
        rightWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationBell(),
            const SizedBox(width: 10),
            _buildProfileAvatar(),
          ],
        );
        break;

      case HeaderRightAction.menuAndNotification:
        rightWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationBell(),
            const SizedBox(width: 10),
            _buildMenuButton(),
          ],
        );
        break;

      case HeaderRightAction.moreMenu:
        rightWidget = _buildMoreMenu();
        break;

      case HeaderRightAction.none:
        rightWidget = const SizedBox.shrink();
        break;
    }

    if (!isInGlassCard) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: logoAndBrand),
          const SizedBox(width: 8),
          rightWidget,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: logoAndBrand),
              const SizedBox(width: 8),
              rightWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return InkWell(
      onTap: onNotificationTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.32),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 21,
            ),
            if (hasNotification)
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.75),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/user_avatar.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primaryOrange,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: onMenuTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.menu_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildMoreMenu() {
    return InkWell(
      onTap: onMenuTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.55),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
