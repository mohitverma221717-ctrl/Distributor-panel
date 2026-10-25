import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class ShopDirectoryScreen extends ConsumerWidget {
  const ShopDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(shopsProvider);
    final shopsNotifier = ref.read(shopsProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // Background Backdrop
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
            child: Container(
              color: Colors.black.withOpacity(0.12),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: ShopEasyHeader(
                    rightAction: HeaderRightAction.menuAndNotification,
                    onNotificationTap: () => context.push('/notifications'),
                    onMenuTap: () => context.push('/more'),
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (q) => shopsNotifier.setSearchQuery(q),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search Shops, area or salesman...',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: const Color(0xFF475569).withOpacity(0.75),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF475569),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Tabs: All (43), Nearby, Top Demands
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterPill(
                        context: context,
                        label: 'All (43)',
                        icon: Icons.grid_view_rounded,
                        isSelected: shopsNotifier.filter == ShopFilter.all,
                        onTap: () => shopsNotifier.setFilter(ShopFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context: context,
                        label: 'Nearby',
                        icon: Icons.location_on_rounded,
                        isSelected: shopsNotifier.filter == ShopFilter.nearby,
                        onTap: () => shopsNotifier.setFilter(ShopFilter.nearby),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context: context,
                        label: 'Top Demands',
                        icon: Icons.local_fire_department_rounded,
                        isSelected: shopsNotifier.filter == ShopFilter.topDemands,
                        onTap: () => shopsNotifier.setFilter(ShopFilter.topDemands),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Shop List
                Expanded(
                  child: shops.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: shops.length,
                          itemBuilder: (context, index) {
                            final shop = shops[index];
                            return _buildShopCard(context, shop);
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

  Widget _buildFilterPill({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isSelected ? AppColors.orangeGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.38),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.65),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        borderRadius: 24,
        padding: const EdgeInsets.all(14),
        child: InkWell(
          onTap: () => _showShopDetailsModal(context, shop),
          child: Row(
            children: [
              // Avatar with Initial
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9E40), Color(0xFFFF6D00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    shop.initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Shop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const StatusBadge(
                          text: 'Active',
                          type: BadgeType.active,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${shop.area}  •  ${shop.distanceKm} km',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Pending: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Text(
                          '${shop.pendingOrders}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        const Text(
                          '   |   Total: ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Text(
                          '${shop.totalOrders}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right chevron
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShopDetailsModal(BuildContext context, Shop shop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return GlassPanel(
          borderRadius: 28,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Owner: ${shop.ownerName}  •  ${shop.phone}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildModalRow('Address', shop.address),
                    const Divider(height: 14),
                    _buildModalRow('Distance from Hub', '${shop.distanceKm} km'),
                    const Divider(height: 14),
                    _buildModalRow('High Demand Items', shop.topDemand),
                    const Divider(height: 14),
                    _buildModalRow('Order Performance', '${shop.totalOrders} total delivered orders'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Retailer'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${shop.phone}...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('New Order'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/products');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 48, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 10),
          const Text(
            'No shops found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or filters',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
