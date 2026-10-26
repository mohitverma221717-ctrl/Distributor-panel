import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_alert_card.dart';
import '../../shared/widgets/glass_metric_card.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/glass_quick_action_tile.dart';
import '../../shared/widgets/shopeasy_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final inventory = ref.watch(inventoryProvider);
    final orders = ref.watch(ordersProvider);
    final dispatchRoutes = ref.watch(dispatchProvider);
    final notifications = ref.watch(notificationsProvider);

    // Dynamic metrics
    final totalStockUnits = inventory.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final formattedStock = NumberFormat('#,###')
        .format(totalStockUnits > 0 ? totalStockUnits : 8420);

    final pendingOrdersCount = orders
        .where((o) => o.status == 'Pending' || o.status == 'Processing')
        .length;
    final displayPendingOrders = pendingOrdersCount > 0
        ? pendingOrdersCount.toString()
        : '18';

    final pendingDispatchCount = dispatchRoutes
        .where((r) => r.status != 'Completed')
        .length;
    final displayPendingDispatch = pendingDispatchCount > 0
        ? pendingDispatchCount.toString()
        : '5';

    final unreadAlertsCount = notifications.where((n) => !n.isRead).length;

    // Latest alert
    final latestAlert = notifications.isNotEmpty ? notifications.first : null;
    final alertTitle =
        latestAlert?.title ?? 'High demand for Rice (50kg) in 3 shops';
    final alertTime = latestAlert?.timeAgo ?? '2 hours ago';

    final userName = user?.name ?? 'Ramesh Kumar';
    final userRole = user?.businessType.contains('Distributor') == true
        ? 'Distributor'
        : 'Distributor';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Logistics Warehouse Art Backdrop matching reference
          Positioned.fill(
            child: Image.asset(
              'assets/images/warehouse_art.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.warmBackgroundGradient,
                ),
              ),
            ),
          ),

          // Backdrop blur & subtle gradient tint to match the reference's frosted bokeh feel
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF60A5FA).withOpacity(0.08),
                      const Color(0xFFFF9E40).withOpacity(0.06),
                      Colors.black.withOpacity(0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primaryOrange,
              backgroundColor: Colors.white,
              onRefresh: () async {
                // Refresh data from repository
                ref.invalidate(inventoryProvider);
                ref.invalidate(ordersProvider);
                ref.invalidate(dispatchProvider);
                ref.invalidate(notificationsProvider);
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glass Top Header
                        ShopEasyHeader(
                          rightAction: HeaderRightAction.profileAndNotification,
                          hasNotification: unreadAlertsCount > 0,
                          onNotificationTap: () =>
                              context.push('/notifications'),
                          onProfileTap: () => context.push('/profile'),
                        ),
                        const SizedBox(height: 14),

                        // Welcome & 2x2 Metric Cards Glass Panel
                        GlassPanel(
                          borderRadius: 26,
                          blurSigma: 18,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, $userName',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          userRole,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => context.push('/salesman'),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange
                                            .withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primaryOrange
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.two_wheeler_outlined,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Salesman View',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 2x2 Grid of Metric Cards
                              Row(
                                children: [
                                  // Card 1: Total Demand
                                  Expanded(
                                    child: GlassMetricCard(
                                      title: 'Total Demand',
                                      value: '1,250',
                                      unit: 'orders',
                                      color: const Color(0xFF0284C7),
                                      glowColor: const Color(0xFF38BDF8),
                                      gradient: const [
                                        Color(0xFF38BDF8),
                                        Color(0xFF0284C7),
                                      ],
                                      customIcon: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(1.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () => context.go('/demand'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Card 2: Pending Ship Orders
                                  Expanded(
                                    child: GlassMetricCard(
                                      title: 'Pending Ship Orders',
                                      value: displayPendingOrders,
                                      unit: 'orders',
                                      color: const Color(0xFFEA580C),
                                      glowColor: const Color(0xFFFB923C),
                                      gradient: const [
                                        Color(0xFFFB923C),
                                        Color(0xFFEA580C),
                                      ],
                                      icon: Icons.shopping_bag_rounded,
                                      onTap: () => context.go('/orders'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Card 3: Warehouse Stock
                                  Expanded(
                                    child: GlassMetricCard(
                                      title: 'Warehouse Stock',
                                      value: formattedStock,
                                      unit: 'units',
                                      color: const Color(0xFF16A34A),
                                      glowColor: const Color(0xFF4ADE80),
                                      gradient: const [
                                        Color(0xFF4ADE80),
                                        Color(0xFF16A34A),
                                      ],
                                      icon: Icons.home_work_rounded,
                                      onTap: () => context.go('/inventory'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Card 4: Dispatch Pending
                                  Expanded(
                                    child: GlassMetricCard(
                                      title: 'Dispatch Pending',
                                      value: displayPendingDispatch,
                                      unit: 'orders',
                                      color: const Color(0xFF9333EA),
                                      glowColor: const Color(0xFFC084FC),
                                      gradient: const [
                                        Color(0xFFC084FC),
                                        Color(0xFF9333EA),
                                      ],
                                      icon: Icons.assignment_rounded,
                                      onTap: () => context.push('/dispatch'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Actions Panel
                        GlassPanel(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Quick Actions',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => _showAllQuickActions(context),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'View All',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 4 Quick Action Tiles in a Row
                              Row(
                                children: [
                                  Expanded(
                                    child: GlassQuickActionTile(
                                      icon: Icons.location_on_rounded,
                                      label: 'View\nDemand',
                                      gradient: const [
                                        Color(0xFFFF9E40),
                                        Color(0xFFFF6D00),
                                      ],
                                      glowColor: const Color(0xFFFF6D00),
                                      onTap: () => context.go('/demand'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GlassQuickActionTile(
                                      icon: Icons.inventory_2_rounded,
                                      label: 'Check\nInventory',
                                      gradient: const [
                                        Color(0xFFC084FC),
                                        Color(0xFF9333EA),
                                      ],
                                      glowColor: const Color(0xFF9333EA),
                                      onTap: () => context.go('/inventory'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GlassQuickActionTile(
                                      icon: Icons.storefront_rounded,
                                      label: 'Shop\nDirectory',
                                      gradient: const [
                                        Color(0xFFFACC15),
                                        Color(0xFFEAB308),
                                      ],
                                      glowColor: const Color(0xFFEAB308),
                                      onTap: () => context.push('/shops'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GlassQuickActionTile(
                                      icon: Icons.shopping_cart_rounded,
                                      label: 'New\nOrder',
                                      gradient: const [
                                        Color(0xFF4ADE80),
                                        Color(0xFF16A34A),
                                      ],
                                      glowColor: const Color(0xFF16A34A),
                                      onTap: () => context.push('/products'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Recent Alerts Panel
                        GlassPanel(
                          borderRadius: 24,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFB7185),
                                              Color(0xFFF43F5E),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFF43F5E)
                                                  .withOpacity(0.55),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.priority_high_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Recent Alerts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => context.push('/notifications'),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'View All',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Alert Item
                              GlassAlertCard(
                                title: alertTitle,
                                timeAgo: alertTime,
                                isUnread: true,
                                onTap: () => context.go('/demand'),
                              ),
                            ],
                          ),
                        ),

                        // Bottom spacing for bottom navigation bar
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Distributor Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFFF6D00),
                  ),
                ),
                title: const Text('View Demand & Forecast'),
                subtitle: const Text(
                  'Analyze aggregated shop demand across areas',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/demand');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9333EA).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF9333EA),
                  ),
                ),
                title: const Text('Warehouse Inventory'),
                subtitle: const Text(
                  'Check product stock levels and low-stock alerts',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/inventory');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFFEAB308),
                  ),
                ),
                title: const Text('Shop Directory'),
                subtitle: const Text(
                  'View connected retailer network and order history',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/shops');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Color(0xFF16A34A),
                  ),
                ),
                title: const Text('New Order & Catalogue'),
                subtitle: const Text(
                  'Browse product catalogue and place direct orders',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/products');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Color(0xFF0284C7),
                  ),
                ),
                title: const Text('Dispatch Planning'),
                subtitle: const Text(
                  'Review driver routes, stop sequence & loads',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/dispatch');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    color: AppColors.primaryOrange,
                  ),
                ),
                title: const Text('Supplier Management'),
                subtitle: const Text(
                  'Manage FMCG suppliers, purchase orders & balances',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/suppliers');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: Color(0xFF0284C7),
                  ),
                ),
                title: const Text('Salesman Coordination (Feri Wala)'),
                subtitle: const Text(
                  'Track salesman routes, visits and shop demands',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/salesman');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF16A34A),
                  ),
                ),
                title: const Text('Key Reports & Financials'),
                subtitle: const Text(
                  'Stock, sales, purchase and profit & loss statements',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/reports');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
