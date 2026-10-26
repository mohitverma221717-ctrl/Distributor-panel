import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';
import '../../shared/widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopEasyHeader(
                  rightAction: HeaderRightAction.profileAndNotification,
                  onNotificationTap: () => context.push('/notifications'),
                  onProfileTap: () {},
                ),
                const SizedBox(height: 14),

                // Profile Summary Card
                GlassPanel(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/user_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user?.name ?? 'Ramesh Kumar',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const StatusBadge(
                                  text: 'Verified',
                                  type: BadgeType.active,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.businessName ?? 'Ramesh Distributors',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'GST: ${user?.gstNumber ?? "22AABCD1234F1ZS"}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Management Quick Links Panel
                GlassPanel(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Text(
                          'Operations & Distribution',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      _buildMenuTile(
                        icon: Icons.handshake_outlined,
                        title: 'Supplier Management',
                        subtitle:
                            'FMCG partners, purchase orders & ledger balances',
                        color: AppColors.primaryOrange,
                        onTap: () => context.push('/suppliers'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.two_wheeler_outlined,
                        title: 'Salesman Coordination (Feri Wala)',
                        subtitle:
                            'Field visits, salesman routes & demand collection',
                        color: const Color(0xFF0284C7),
                        onTap: () => context.push('/salesman'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.insights_outlined,
                        title: 'Key Reports & Financials',
                        subtitle:
                            'Stock valuation, sales revenue, P&L statements',
                        color: const Color(0xFF16A34A),
                        onTap: () => context.push('/reports'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.inventory_2_outlined,
                        title: 'Warehouse Inventory Stock',
                        subtitle:
                            'Track SKU levels, batch records & reorder alerts',
                        color: const Color(0xFF9333EA),
                        onTap: () => context.push('/inventory'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.storefront_outlined,
                        title: 'Shop Directory (43 Stores)',
                        subtitle: 'Retailer contacts, locations, order trends',
                        color: const Color(0xFFEAB308),
                        onTap: () => context.push('/shops'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.alt_route_rounded,
                        title: 'Dispatch Planning',
                        subtitle: 'Route scheduling, drivers, stop lists',
                        color: const Color(0xFF9333EA),
                        onTap: () => context.push('/dispatch'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Shipment Tracking',
                        subtitle: 'Live AWB and transit status tracking',
                        color: const Color(0xFF0284C7),
                        onTap: () => context.push('/shipments'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Settings & Support Panel
                GlassPanel(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Text(
                          'Account & Preferences',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      _buildMenuTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Alert Notifications',
                        subtitle: 'Demand surge and low stock thresholds',
                        color: const Color(0xFFEA580C),
                        onTap: () => context.push('/notifications'),
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.headset_mic_outlined,
                        title: 'ShopEasy Partner Support',
                        subtitle: 'Territory hotline: 1800-419-7000',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Dialing ShopEasy Distributor Desk: 1800-419-7000',
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'End session and clear credentials',
                        color: const Color(0xFFEF4444),
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // spacing for bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: Color(0xFF94A3B8),
      ),
      onTap: onTap,
    );
  }
}
