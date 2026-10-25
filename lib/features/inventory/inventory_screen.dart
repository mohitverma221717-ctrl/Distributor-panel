import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final totalUnits = inventory.fold(0, (sum, item) => sum + item.quantity);
    final lowStockCount = inventory.where((item) => item.isLowStock).length;

    return Stack(
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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: ShopEasyHeader(
                  rightAction: HeaderRightAction.profileAndNotification,
                  onNotificationTap: () => context.push('/notifications'),
                  onProfileTap: () => context.push('/profile'),
                ),
              ),

              // Warehouse Stock Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassPanel(
                  borderRadius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Warehouse Stock',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${totalUnits.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} units',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDA4AF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFBE123C)),
                            const SizedBox(width: 4),
                            Text(
                              '$lowStockCount Low Stock',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.42),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                  ),
                  child: TextField(
                    onChanged: (q) => inventoryNotifier.setSearchQuery(q),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Search warehouse products...',
                      hintStyle: TextStyle(fontSize: 13, color: const Color(0xFF475569).withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF475569)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Categories Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['All', 'Grains', 'Oils', 'Flour', 'Sweeteners', 'Pulses', 'Salt & Spices'].map((cat) {
                    final isSelected = inventoryNotifier.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => inventoryNotifier.setCategory(cat),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: isSelected ? AppColors.orangeGradient : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.4),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

              // Inventory Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return _buildInventoryCard(context, item, ref);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItem item, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.isLowStock
                    ? const Color(0xFFFFE4E6)
                    : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_outlined,
                color: item.isLowStock
                    ? const Color(0xFFBE123C)
                    : const Color(0xFF0284C7),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Category: ${item.category}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                      if (item.isLowStock)
                        const StatusBadge(text: 'Low Stock', type: BadgeType.lowStock),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: item.isLowStock
                              ? const Color(0xFFBE123C)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                      Text(
                        '₹${item.pricePerUnit.toStringAsFixed(0)} / ${item.unit}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryOrange),
              onPressed: () => _showAdjustStockDialog(context, item, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, InventoryItem item, WidgetRef ref) {
    int adjustment = 0;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final previewQty = (item.quantity + adjustment).clamp(0, 999999);
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Adjust Stock: ${item.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Stock: ${item.quantity} ${item.unit}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 28),
                        onPressed: () => setModalState(() => adjustment -= 10),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$previewQty',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF16A34A), size: 28),
                        onPressed: () => setModalState(() => adjustment += 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjustment: ${adjustment >= 0 ? "+$adjustment" : "$adjustment"} ${item.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: adjustment >= 0 ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(inventoryProvider.notifier).adjustStock(item.id, adjustment);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stock updated for ${item.name}')),
                    );
                  },
                  child: const Text('Save Stock'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
