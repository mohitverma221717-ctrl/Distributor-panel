import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final ordersNotifier = ref.read(ordersProvider.notifier);

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            'assets/images/warehouse_backdrop.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: AppColors.warmBackgroundGradient,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.12)),
        ),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: ShopEasyHeader(
                  rightAction: HeaderRightAction.profileAndNotification,
                  onNotificationTap: () => context.push('/notifications'),
                  onProfileTap: () => context.push('/profile'),
                ),
              ),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['All', 'Pending', 'Processing', 'Delivered'].map((status) {
                    final isSelected = ordersNotifier.statusFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => ordersNotifier.setFilter(status),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isSelected ? AppColors.orangeGradient : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.4),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.65),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Order Cards
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders found for selected filter',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _buildOrderCard(context, order, ref);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, DistributorOrder order, WidgetRef ref) {
    BadgeType badgeType;
    switch (order.status) {
      case 'Pending':
        badgeType = BadgeType.pending;
        break;
      case 'Processing':
        badgeType = BadgeType.processing;
        break;
      case 'Delivered':
        badgeType = BadgeType.delivered;
        break;
      default:
        badgeType = BadgeType.active;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        borderRadius: 22,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                StatusBadge(text: order.status, type: badgeType),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.shopName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.itemCount} items  •  ${DateFormat('dd MMM, hh:mm a').format(order.date)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                Text(
                  '₹${order.orderAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'Pending')
                  ElevatedButton(
                    onPressed: () {
                      ref.read(ordersProvider.notifier).updateOrderStatus(order.id, 'Processing');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${order.id} marked as Processing')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Accept & Process', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                if (order.status == 'Processing')
                  ElevatedButton(
                    onPressed: () {
                      ref.read(ordersProvider.notifier).updateOrderStatus(order.id, 'Delivered');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${order.id} marked as Delivered')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Mark Delivered', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
