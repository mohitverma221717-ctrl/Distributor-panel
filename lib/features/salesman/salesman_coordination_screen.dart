import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_components.dart';

class SalesmanCoordinationScreen extends ConsumerStatefulWidget {
  const SalesmanCoordinationScreen({super.key});

  @override
  ConsumerState<SalesmanCoordinationScreen> createState() => _SalesmanCoordinationScreenState();
}

class _SalesmanCoordinationScreenState extends ConsumerState<SalesmanCoordinationScreen> {
  int _selectedTab = 0; // 0: Today's Visits, 1: Visit History
  final List<String> _tabs = ["Today's Visits", "Visit History"];

  void _showVisitActionSheet(SalesmanVisit visit) {
    final notesCtrl = TextEditingController(text: visit.visitNotes ?? '');
    final amountCtrl = TextEditingController(
      text: visit.collectedDemandAmount != null ? visit.collectedDemandAmount!.toStringAsFixed(0) : '',
    );

    showGlassBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.shopName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text('Scheduled: ${visit.scheduledTime}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    GlassStatusBadge(status: visit.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),

                GlassInputField(
                  label: 'Demand / Order Amount Collected (₹)',
                  hint: 'e.g. 15000',
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryOrange, size: 20),
                ),
                const SizedBox(height: 14),

                GlassInputField(
                  label: 'Field Visit Notes / Inventory Observation',
                  hint: 'e.g. Verified rice stock. Placed urgent order for 10 bags.',
                  controller: notesCtrl,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    if (visit.isVisited)
                      Expanded(
                        child: GlassButton(
                          text: 'Mark as Pending',
                          isPrimary: false,
                          onPressed: () {
                            ref.read(salesmanProvider.notifier).markPending(visit.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Visit marked as Pending')),
                            );
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: GlassButton(
                          text: 'Complete Visit',
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                            ref.read(salesmanProvider.notifier).completeVisit(
                                  visit.id,
                                  notes: notesCtrl.text.trim(),
                                  orderAmount: amt > 0 ? amt : null,
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E293B),
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Visit to ${visit.shopName} recorded successfully!'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangeStatusDialog() {
    final salesman = ref.read(salesmanProvider).profile;
    final statuses = ['On Route', 'At Shop', 'Completed', 'Off Duty'];

    showGlassDialog(
      context: context,
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Field Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 14),
            ...statuses.map((status) {
              final isSel = salesman.status == status;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(salesmanProvider.notifier).updateStatus(status);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primaryOrange.withOpacity(0.35) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.primaryOrange : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            color: isSel ? Colors.white : Colors.white70,
                          ),
                        ),
                        if (isSel) const Icon(Icons.check_circle, color: AppColors.primaryOrangeLight, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesmanState = ref.watch(salesmanProvider);
    final profile = salesmanState.profile;
    final visits = salesmanState.visits;

    final todayVisits = visits;
    final visitedList = visits.where((v) => v.isVisited).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Background Backdrop
          Positioned.fill(
            child: Image.asset(
              'assets/images/clean_warehouse_backdrop.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: AppColors.warmBackgroundGradient),
              ),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.12))),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Branding
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/shopeasy_bag_logo.png', fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ShopEasy',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                'Feri Wala & Field Coordination',
                                style: TextStyle(fontSize: 10.5, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        GlassIconButton(
                          icon: Icons.notifications_none_rounded,
                          size: 38,
                          hasBadge: true,
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Heading matching prompt: Salesman Coordination
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Salesman Coordination',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Top Tabs: Today's Visits | Visit History
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassTabBar(
                    tabs: _tabs,
                    selectedIndex: _selectedTab,
                    onTabSelected: (idx) => setState(() => _selectedTab = idx),
                  ),
                ),
                const SizedBox(height: 12),

                // Salesman Profile Card matching prompt:
                // Salesman: Rohit Kumar | Role: Salesman | Assigned Shops: 5 | Route Distance: 22 km | On Route
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.35),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Role: ${profile.role} (Feri Wala)',
                                    style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: _showChangeStatusDialog,
                              child: GlassStatusBadge(status: profile.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildProfileStat('Assigned Shops', '${profile.assignedShopsCount}', Icons.storefront_outlined),
                            ),
                            Container(width: 1, height: 28, color: Colors.white12),
                            Expanded(
                              child: _buildProfileStat('Route Distance', '${profile.routeDistanceKm.toStringAsFixed(0)} km', Icons.route_outlined),
                            ),
                            Container(width: 1, height: 28, color: Colors.white12),
                            Expanded(
                              child: _buildProfileStat('Vehicle', profile.vehicleNumber, Icons.two_wheeler_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Today's Schedule Heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTab == 0 ? "Today's Schedule" : "Completed History",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _selectedTab == 0
                            ? '${todayVisits.where((v) => v.isVisited).length}/${todayVisits.length} Visited'
                            : '${visitedList.length} Completed',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryOrangeLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Visit List matching demo data:
                // Sharma Gen. Store — Visited — 9:30 AM
                // Gupta Kirana Store — Visited — 11:45 AM
                // Verma Provision Store — Pending — 2:00 PM
                // Singh Traders — Pending — 4:30 PM
                Expanded(
                  child: _selectedTab == 0
                      ? ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: todayVisits.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final visit = todayVisits[idx];
                            return _buildVisitCard(context, visit);
                          },
                        )
                      : visitedList.isEmpty
                          ? const GlassEmptyState(
                              title: 'No Completed Visits Yet',
                              message: 'Visits marked as completed will appear in this history tab.',
                              icon: Icons.history_rounded,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                              itemCount: visitedList.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final visit = visitedList[idx];
                                return _buildVisitCard(context, visit);
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

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryOrangeLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildVisitCard(BuildContext context, SalesmanVisit visit) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => _showVisitActionSheet(visit),
      child: Row(
        children: [
          // Time badge
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  visit.isVisited ? Icons.check_circle_outline : Icons.schedule,
                  size: 16,
                  color: visit.isVisited ? AppColors.successGreen : AppColors.primaryOrangeLight,
                ),
                const SizedBox(height: 4),
                Text(
                  visit.scheduledTime,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Shop details and visit notes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  visit.shopName,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                if (visit.visitNotes != null)
                  Text(
                    visit.visitNotes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                  )
                else
                  Text(
                    'Scheduled for delivery & demand check',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                if (visit.collectedDemandAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Collected: ₹ ${visit.collectedDemandAmount!.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryOrangeLight),
                  ),
                ],
              ],
            ),
          ),

          // Status & Action affordance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GlassStatusBadge(status: visit.status),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.6), size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
