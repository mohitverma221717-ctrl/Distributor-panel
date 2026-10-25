import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class DispatchScreen extends ConsumerWidget {
  const DispatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(dispatchProvider);
    final dispatchNotifier = ref.read(dispatchProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.6)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: ShopEasyHeader(
                          rightAction: HeaderRightAction.none,
                          isInGlassCard: false,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dispatch Planning Summary Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassPanel(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Pending Dispatch', '5 orders', Icons.local_shipping_outlined, AppColors.metricPurple),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.6)),
                        _buildSummaryItem('Active Routes', '3 routes', Icons.alt_route_rounded, AppColors.metricOrange),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.6)),
                        _buildSummaryItem('Drivers on Duty', '3 drivers', Icons.people_outline, AppColors.metricGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Assigned Delivery Routes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Routes List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return _buildRouteCard(context, route, dispatchNotifier);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildRouteCard(BuildContext context, DispatchRoute route, DispatchNotifier notifier) {
    final isInTransit = route.status == 'In Transit';
    final isCompleted = route.status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  route.routeName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                StatusBadge(
                  text: route.status,
                  type: isCompleted
                      ? BadgeType.delivered
                      : (isInTransit ? BadgeType.processing : BadgeType.pending),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_pin_circle_outlined, size: 16, color: AppColors.primaryOrange),
                const SizedBox(width: 4),
                Text(
                  'Driver: ${route.assignedDriver} (${route.driverPhone})',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${route.stopCount} stops  •  ${route.distanceKm} km  •  Est. ${route.estDuration}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Stops:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                  const SizedBox(height: 4),
                  ...route.shopNames.map((shop) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_right, size: 16, color: AppColors.primaryOrange),
                            Text(shop, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isInTransit && !isCompleted)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 15),
                    label: const Text('Confirm Dispatch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      notifier.markRouteInTransit(route.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${route.routeName} is now IN TRANSIT')),
                      );
                    },
                  ),
                if (isInTransit)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 15),
                    label: const Text('Complete Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      notifier.markRouteCompleted(route.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${route.routeName} delivery COMPLETED')),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
