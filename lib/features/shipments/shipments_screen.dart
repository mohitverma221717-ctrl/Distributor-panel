import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class ShipmentsScreen extends ConsumerWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipments = ref.watch(shipmentsProvider);
    final shipmentsNotifier = ref.read(shipmentsProvider.notifier);

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

                // Search Bar for AWB / Order ID
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.7)),
                    ),
                    child: TextField(
                      onChanged: (q) => shipmentsNotifier.searchAwb(q),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'Search by AWB (e.g. SE-AWB-98402) or Shop...',
                        hintStyle: TextStyle(fontSize: 13, color: const Color(0xFF475569).withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF475569)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Shipments List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      return _buildShipmentCard(context, shipment);
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

  Widget _buildShipmentCard(BuildContext context, Shipment shipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassPanel(
        borderRadius: 22,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.awbNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    Text(
                      'Order: ${shipment.orderId} • ${shipment.shopName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                StatusBadge(
                  text: shipment.status,
                  type: shipment.status == 'Delivered'
                      ? BadgeType.delivered
                      : (shipment.status == 'Out for Delivery' ? BadgeType.processing : BadgeType.pending),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Payload: ${shipment.productSummary}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${shipment.lastUpdate}',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF0284C7)),
            ),
            const Divider(height: 20),

            // Tracking Timeline
            const Text(
              'Live Tracking Journey',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            ...List.generate(shipment.trackingSteps.length, (idx) {
              final step = shipment.trackingSteps[idx];
              final isLast = idx == shipment.trackingSteps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isCompleted ? const Color(0xFF16A34A) : Colors.grey.shade300,
                        ),
                        child: Icon(
                          step.isCompleted ? Icons.check : Icons.circle,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 34,
                          color: step.isCompleted ? const Color(0xFF16A34A) : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: step.isCompleted ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                step.time,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.description,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
