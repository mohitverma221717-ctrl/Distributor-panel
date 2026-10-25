import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/bottom_nav_bar.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShellScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/demand');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ShopEasyBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => _onTabSelected(context, index),
            ),
          ),
        ],
      ),
    );
  }
}
