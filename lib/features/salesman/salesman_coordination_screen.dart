import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/glass_components.dart';

/// Screen reproducing the ShopEasy Salesman Coordination UI with pixel accuracy
class SalesmanCoordinationScreen extends ConsumerStatefulWidget {
  const SalesmanCoordinationScreen({super.key});

  @override
  ConsumerState<SalesmanCoordinationScreen> createState() =>
      _SalesmanCoordinationScreenState();
}

class _SalesmanCoordinationScreenState
    extends ConsumerState<SalesmanCoordinationScreen> {
  int _selectedTab = 0; // 0: Today's Visits, 1: Visit History

  void _showVisitActionSheet(SalesmanVisit visit) {
    final notesCtrl = TextEditingController(text: visit.visitNotes ?? '');
    final amountCtrl = TextEditingController(
      text: visit.collectedDemandAmount != null
          ? visit.collectedDemandAmount!.toStringAsFixed(0)
          : '',
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Scheduled: ${visit.scheduledTime}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
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
                  prefixIcon: const Icon(
                    Icons.currency_rupee,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
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
                            ref
                                .read(salesmanProvider.notifier)
                                .markPending(visit.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Visit marked as Pending'),
                              ),
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
                            final amt =
                                double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                            ref
                                .read(salesmanProvider.notifier)
                                .completeVisit(
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
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.successGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Visit to ${visit.shopName} recorded successfully!',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primaryOrange.withOpacity(0.35)
                          : Colors.white.withOpacity(0.1),
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
                            fontWeight: isSel
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSel ? Colors.white : Colors.white70,
                          ),
                        ),
                        if (isSel)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryOrangeLight,
                            size: 20,
                          ),
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

    return Scaffold(
      body: Stack(
        children: [
          // 1. Ambient Frosted Glass Background
          const _SalesmanAtmosphericBackground(),

          // 2. Main Scrollable Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header with ShopEasy Branding
                        _buildShopEasyHeader(),

                        // Section 1: Salesman Coordination Title & Tabs Card
                        _buildTitleCard(),

                        const SizedBox(height: 12),

                        // Section 2: Salesman Profile Card
                        _buildProfileCard(profile),

                        const SizedBox(height: 12),

                        // Section 3: Today's Schedule Panel
                        _buildSchedulePanel(visits),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Navigation Dock (Home Selected)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ShopEasyBottomNav(
              currentIndex: 0, // Home tab selected as shown in reference
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/demand');
                    break;
                  case 2:
                    context.go('/orders');
                    break;
                  case 3:
                    context.go('/inventory');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Top Brand Header reproducing the ShopEasy 3D orange bag and brand typography
  Widget _buildShopEasyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: [
          // ShopEasy Shopping Bag Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6A00).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/shopeasy_bag_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF9533), Color(0xFFFF5500)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'ShopEasy',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Title Card with "Salesman Coordination" heading and segmented tab controls
  Widget _buildTitleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Salesman Coordination',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Segmented Tab Bar container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSegmentedTab(
                          index: 0,
                          title: "Today's Visits",
                        ),
                      ),
                      Expanded(
                        child: _buildSegmentedTab(
                          index: 1,
                          title: "Visit History",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTab({required int index, required String title}) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFFF7A00)
                    : const Color(0xFF5A7596),
              ),
            ),
            const SizedBox(height: 3),
            if (isSelected)
              Container(
                height: 2.8,
                width: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7A00).withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 2.8),
          ],
        ),
      ),
    );
  }

  /// Salesman Profile Card matching Rohit Kumar reference
  Widget _buildProfileCard(SalesmanProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.68), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Circular Profile Image with white circular border
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.95),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/rohit_kumar_avatar.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/user_avatar.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1E3A8A),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Salesman Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF162544),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.role,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A7596),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Assigned Shops: ${profile.assignedShopsCount}  |  ${profile.routeDistanceKm.toStringAsFixed(0)} km',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A7596),
                        ),
                      ),
                    ],
                  ),
                ),
                // Green On Route Status Badge with Location Pin
                InkWell(
                  onTap: _showChangeStatusDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4F7DF).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF86EFAC).withOpacity(0.7),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.status,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Large Today's Schedule panel containing the four reference rows
  Widget _buildSchedulePanel(List<SalesmanVisit> visits) {
    final displayedVisits = _selectedTab == 0
        ? visits
        : visits.where((v) => v.isVisited).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTab == 0 ? "Today's Schedule" : "Visit History",
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),
                if (displayedVisits.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 40,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Completed Visits Yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Visits marked as Visited will appear here.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...displayedVisits.map(
                    (visit) => GlassScheduleRow(
                      visit: visit,
                      onTap: () => _showVisitActionSheet(visit),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Schedule Row matching the screenshot with Shop Icon, Name, Visited/Pending Badge, and Scheduled Time
class GlassScheduleRow extends StatelessWidget {
  final SalesmanVisit visit;
  final VoidCallback onTap;

  const GlassScheduleRow({super.key, required this.visit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isVisited = visit.isVisited;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor:
              (isVisited ? const Color(0xFF22C55E) : const Color(0xFFFF7A00))
                  .withOpacity(0.12),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                // Circular shop icon (Green for visited, Orange for pending)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isVisited
                          ? const [Color(0xFF34D399), Color(0xFF10B981)]
                          : const [Color(0xFFFDBA74), Color(0xFFFF7A00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isVisited
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFFF7A00))
                                .withOpacity(0.28),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Shop Name
                Expanded(
                  flex: 3,
                  child: Text(
                    visit.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF162544),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge (Green checkmark for Visited, Orange diamond for Pending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isVisited
                        ? const Color(0xFFD4F7DF).withOpacity(0.75)
                        : const Color(0xFFFFEDD5).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isVisited
                          ? const Color(0xFF86EFAC).withOpacity(0.5)
                          : const Color(0xFFFDBA74).withOpacity(0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isVisited) ...[
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Visited',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ] else ...[
                        Transform.rotate(
                          angle: 0.785, // 45 degrees for diamond
                          child: Container(
                            width: 7.5,
                            height: 7.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Scheduled Time
                Text(
                  visit.scheduledTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A7596),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Atmospheric blue, peach, orange, and light-blue gradient background matching screenshot
class _SalesmanAtmosphericBackground extends StatelessWidget {
  const _SalesmanAtmosphericBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base linear gradient: sky blue on left, warm peach/orange highlights
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6), // Vibrant sky blue
                  Color(0xFF60A5FA), // Light blue
                  Color(0xFFFFB088), // Warm peach
                  Color(0xFFFFA07A), // Light coral orange
                  Color(0xFF93C5FD), // Soft blue
                ],
                stops: [0.0, 0.35, 0.65, 0.85, 1.0],
              ),
            ),
          ),
        ),

        // Warm Peach / Orange Ambient Glow on Top Right
        Positioned(
          top: -40,
          right: -40,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF9E66).withOpacity(0.8),
                  const Color(0xFFFFB894).withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Deep Sky Blue Orb on Center Left
        Positioned(
          top: 220,
          left: -80,
          width: 300,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2563EB).withOpacity(0.65),
                  const Color(0xFF60A5FA).withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Soft Peach Glow on Bottom Right
        Positioned(
          bottom: 30,
          right: -50,
          width: 280,
          height: 280,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFED7AA).withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Ambient Frosted Blur Overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: Colors.white.withOpacity(0.04)),
          ),
        ),
      ],
    );
  }
}
