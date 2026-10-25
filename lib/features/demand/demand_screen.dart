import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/demand_product_row.dart';
import '../../shared/widgets/glass_demand_metric_card.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/shopeasy_header.dart';

class DemandScreen extends ConsumerWidget {
  const DemandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandState = ref.watch(demandProvider);
    final demandNotifier = ref.read(demandProvider.notifier);
    final notifications = ref.watch(notificationsProvider);
    final unreadAlertsCount = notifications.where((n) => !n.isRead).length;

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
                ref.invalidate(demandProvider);
                await Future.delayed(const Duration(milliseconds: 350));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glass Top Header with Subtitle "Your Local Shop, Our Priority"
                        ShopEasyHeader(
                          rightAction: HeaderRightAction.profileAndNotification,
                          showSubtitle: true,
                          hasNotification: unreadAlertsCount > 0,
                          onNotificationTap: () => context.push('/notifications'),
                          onProfileTap: () => context.push('/profile'),
                        ),
                        const SizedBox(height: 14),

                        // Aggregated Demand Primary Glass Panel
                        GlassPanel(
                          borderRadius: 26,
                          blurSigma: 18,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Panel Header Row: Chart Icon, Title, and Date Filter
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.24),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.55),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.trending_up_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Aggregated Demand',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Date Range Filter Pill Button
                                  InkWell(
                                    onTap: () => _showDateRangePicker(context, demandState.timeRange, demandNotifier),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.22),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.6),
                                          width: 1.1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            demandState.timeRange,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // 4 Demand Metric Cards in a Single Row
                              Row(
                                children: [
                                  // Card A: Forecast
                                  Expanded(
                                    child: GlassDemandMetricCard(
                                      title: 'Forecast',
                                      value: '${demandState.forecastUnits}',
                                      unit: 'units',
                                      icon: Icons.view_in_ar_rounded,
                                      accentColor: const Color(0xFF0284C7),
                                      bgColor: const Color(0xFFE0F2FE).withOpacity(0.82),
                                      glowColor: const Color(0xFF38BDF8),
                                      iconGradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                                      onTap: () => _showMetricDetails(
                                        context,
                                        title: 'Demand Forecast',
                                        metric: '${demandState.forecastUnits} units',
                                        color: const Color(0xFF0284C7),
                                        description: 'AI & historical-based demand forecast for ${demandState.timeRange}. Anticipates peak order influx in Deoiganj and Civil Lines areas.',
                                        breakdown: const {
                                          'Forecast Confidence': '94.2%',
                                          'Historical Variance': '+12% vs last period',
                                          'Peak Demand Window': '08:00 AM - 12:30 PM',
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Card B: Requested
                                  Expanded(
                                    child: GlassDemandMetricCard(
                                      title: 'Requested',
                                      value: '${demandState.requestedUnits}',
                                      unit: 'units',
                                      icon: Icons.shopping_cart_outlined,
                                      accentColor: const Color(0xFFEA580C),
                                      bgColor: const Color(0xFFFFEDD5).withOpacity(0.82),
                                      glowColor: const Color(0xFFFB923C),
                                      iconGradient: const [Color(0xFFFB923C), Color(0xFFEA580C)],
                                      onTap: () => _showMetricDetails(
                                        context,
                                        title: 'Requested Demand',
                                        metric: '${demandState.requestedUnits} units',
                                        color: const Color(0xFFEA580C),
                                        description: 'Total quantities actively requested by local retail shopkeepers awaiting order confirmation.',
                                        breakdown: const {
                                          'Pending Shop Orders': '18 orders',
                                          'Active Store Requisitions': '6 stores',
                                          'Avg Items per Shop': '60 units',
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Card C: Confirmed
                                  Expanded(
                                    child: GlassDemandMetricCard(
                                      title: 'Confirmed',
                                      value: '${demandState.confirmedUnits}',
                                      unit: 'units',
                                      icon: Icons.check_rounded,
                                      accentColor: const Color(0xFF16A34A),
                                      bgColor: const Color(0xFFDCFCE7).withOpacity(0.82),
                                      glowColor: const Color(0xFF4ADE80),
                                      iconGradient: const [Color(0xFF4ADE80), Color(0xFF16A34A)],
                                      onTap: () => _showMetricDetails(
                                        context,
                                        title: 'Confirmed Demand',
                                        metric: '${demandState.confirmedUnits} units',
                                        color: const Color(0xFF16A34A),
                                        description: 'Requisitions validated with payment/credit terms and queued for fulfillment.',
                                        breakdown: const {
                                          'Credit Verified': '210 units',
                                          'Advance Paid': '70 units',
                                          'Ready for Staging': '100%',
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Card D: Allocated
                                  Expanded(
                                    child: GlassDemandMetricCard(
                                      title: 'Allocated',
                                      value: '${demandState.allocatedUnits}',
                                      unit: 'units',
                                      icon: Icons.access_time_rounded,
                                      accentColor: const Color(0xFF9333EA),
                                      bgColor: const Color(0xFFF3E8FF).withOpacity(0.82),
                                      glowColor: const Color(0xFFC084FC),
                                      iconGradient: const [Color(0xFFC084FC), Color(0xFF9333EA)],
                                      onTap: () => _showMetricDetails(
                                        context,
                                        title: 'Allocated Demand',
                                        metric: '${demandState.allocatedUnits} units',
                                        color: const Color(0xFF9333EA),
                                        description: 'Stock locked in staging bays and assigned to active delivery vehicles/dispatch routes.',
                                        breakdown: const {
                                          'Route A (Manoj Yadav)': '140 units',
                                          'Route B (Suresh Singh)': '100 units',
                                          'Dispatch Ready Status': 'In Progress',
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Top Products by Demand Glass Panel
                        GlassPanel(
                          borderRadius: 26,
                          blurSigma: 18,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Panel Header Row: Flame Icon, Title, and "View All >"
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFFA23A), Color(0xFFFF6D00)],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF6D00).withOpacity(0.45),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.local_fire_department_rounded,
                                              color: Colors.white,
                                              size: 19,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Top Products by Demand',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _showAllProductsModal(context, demandState.topProducts),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        children: [
                                          Text(
                                            'View All',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withOpacity(0.85),
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: Colors.white.withOpacity(0.85),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Column Subheaders matching reference screenshot
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Product',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                    Text(
                                      'Total Demand',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Top Products List: 4 Cards matching reference exactly
                              ...demandState.topProducts.take(4).map((prod) {
                                return DemandProductRow(
                                  product: prod,
                                  onTap: () => _showProductDemandDetail(context, prod, demandState),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Bottom spacing for floating bottom navigation bar
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

  void _showDateRangePicker(BuildContext context, String currentRange, DemandNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
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
                'Select Demand Time Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ...['Today', 'Last 7 Days', 'Last 30 Days', 'This Month'].map((range) {
                final isSelected = currentRange == range;
                return ListTile(
                  leading: Icon(
                    Icons.calendar_today_rounded,
                    color: isSelected ? AppColors.primaryOrange : const Color(0xFF64748B),
                  ),
                  title: Text(
                    range,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primaryOrange : const Color(0xFF1E293B),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryOrange)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryOrange.withOpacity(0.08),
                  onTap: () {
                    notifier.setTimeRange(range);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showMetricDetails(
    BuildContext context, {
    required String title,
    required String metric,
    required Color color,
    required String description,
    required Map<String, String> breakdown,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      metric,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...breakdown.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDemandDetail(BuildContext context, DemandProduct product, DemandState demandState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: product.imageAsset != null
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(product.imageAsset!, fit: BoxFit.contain),
                            )
                          : const Icon(Icons.inventory_2_outlined, color: AppColors.primaryOrange),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${product.category}  •  ₹${product.price.toStringAsFixed(0)} / ${product.unit}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Demand (${demandState.timeRange})', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${product.totalDemand} units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primaryOrange)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip('Forecast', '${(product.totalDemand * 1.05).round()}', const Color(0xFF0284C7)),
                        _buildStatChip('Requested', '${product.totalDemand}', const Color(0xFFEA580C)),
                        _buildStatChip('Confirmed', '${(product.totalDemand * 0.75).round()}', const Color(0xFF16A34A)),
                        _buildStatChip('Allocated', '${(product.totalDemand * 0.65).round()}', const Color(0xFF9333EA)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Top Requesting Retail Shops',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              _buildShopDemandItem('Sharma General Store', 'Deoiganj', '${(product.totalDemand * 0.38).round()} units'),
              _buildShopDemandItem('Gupta Kirana Store', 'Main Bazar', '${(product.totalDemand * 0.28).round()} units'),
              _buildShopDemandItem('Verma Provision Store', 'Kachhpura', '${(product.totalDemand * 0.20).round()} units'),
              _buildShopDemandItem('Singh Traders', 'Nawabganj', '${(product.totalDemand * 0.14).round()} units'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/dispatch');
                  },
                  icon: const Icon(Icons.local_shipping_outlined, color: Colors.white),
                  label: const Text('Allocate & Plan Dispatch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.85), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildShopDemandItem(String shopName, String area, String demand) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(shopName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(width: 4),
              Text('($area)', style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
            ],
          ),
          Text(demand, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  void _showAllProductsModal(BuildContext context, List<DemandProduct> products) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Demand Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final prod = products[index];
                    return DemandProductRow(
                      product: prod,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showProductDemandDetail(context, prod, const DemandState(topProducts: []));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
