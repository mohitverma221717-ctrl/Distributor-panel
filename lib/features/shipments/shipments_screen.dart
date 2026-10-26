import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

/// Pixel-accurate ShopEasy Shipment Tracking Module
/// Exact recreation of the reference screenshot with glassmorphism,
/// warm bokeh backdrop, search field, filter button, 4 reference shipments,
/// status badges with colored indicators, interactive Shipment Details modal,
/// and 5-item bottom navigation dock.
class ShipmentsScreen extends ConsumerStatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ConsumerState<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shipments = ref.watch(shipmentsProvider);
    final shipmentsNotifier = ref.read(shipmentsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFE2C4A2),
      body: Stack(
        children: [
          // 1. Warm Bokeh Photographic Blurred Backdrop
          Positioned.fill(
            child: Image.asset(
              'assets/images/warehouse_backdrop.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE0C19E),
                      Color(0xFFCF8E56),
                      Color(0xFF8F5128),
                      Color(0xFF5A3018),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Translucent Ambient Vignette
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.06)),
          ),

          // 3. Main Scrollable Content Viewport
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Section 4: Frosted Glass Header
                        _buildShopEasyHeader(context),

                        const SizedBox(height: 16),

                        // Section 5, 6, 7: Large Translucent Panel containing Title, Subtitle, Search Field & Filter Button
                        _buildTrackingHeaderPanel(context, shipmentsNotifier),

                        const SizedBox(height: 16),

                        // Section 8: Vertical List of Shipment Cards
                        if (shipments.isEmpty)
                          _buildEmptyState(context, shipmentsNotifier)
                        else
                          ...shipments.map(
                            (s) => _buildShipmentCard(context, s),
                          ),

                        const SizedBox(
                          height: 110,
                        ), // Padding above bottom dock
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Section 14: Shared Floating Bottom Navigation Dock (Orders tab selected by default)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ShopEasyBottomNav(
              currentIndex:
                  2, // Orders tab index selected as shown in reference
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

  // Section 4: Header reproducing ShopEasy logo, name, tagline, notification button with red indicator & avatar
  Widget _buildShopEasyHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(28),
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
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // ShopEasy Orange 3D Bag Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF9533), Color(0xFFFF5500)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B00).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 7,
                        child: Container(
                          width: 16,
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Brand Name & Tagline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ShopEasy',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your Local Shop, Our Priority',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification Bell with Red Badge Dot
                InkWell(
                  onTap: () => context.push('/notifications'),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.65),
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          top: 10,
                          right: 11,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3B30)
                                      .withOpacity(0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Profile Avatar Icon
                InkWell(
                  onTap: () => context.push('/profile'),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.65),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 26,
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

  // Section 5, 6, 7: Large Translucent Panel containing Title, Subtitle, Search Field & Filter Button
  Widget _buildTrackingHeaderPanel(
    BuildContext context,
    ShipmentsNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(26),
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
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 5: Title & Subtitle
                const Text(
                  'Shipment Tracking',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Track your orders in real-time',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Section 6 & 7: Search Field and Separate Filter Button Row
                Row(
                  children: [
                    // Wide Rounded Translucent Search Field
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => notifier.searchAwb(val),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by AWB / Order ID...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      notifier.searchAwb('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Section 7: Separate Rounded Glass Filter Button
                    InkWell(
                      onTap: () => _showFilterModal(context, notifier),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 1.1,
                          ),
                        ),
                        child: const Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section 8: Reusable Shipment Card Widget
  Widget _buildShipmentCard(BuildContext context, Shipment shipment) {
    final statusStyle = _getShipmentStatusStyle(shipment.status);
    final iconGradient = _getTruckIconGradient(shipment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.68), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            onTap: () => _showShipmentDetailsModal(context, shipment),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Circular Delivery / Truck Icon with Gradient
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: iconGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. AWB Number, Product • Quantity, and Shop Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AWB Number
                        Text(
                          shipment.awbNumber,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Product • Quantity
                        Text(
                          '${shipment.productName}  •  ${shipment.quantity} units',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Shop Name
                        Text(
                          shipment.shopName,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 3. Status Badge, Timestamp & Right Chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Pill Badge with Dot
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: statusStyle.backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: statusStyle.borderColor,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusStyle.dotColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  shipment.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusStyle.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Timestamp
                      Text(
                        shipment.timestamp,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section 10: Centralized Status to Style Mapping
  _ShipmentStatusStyle _getShipmentStatusStyle(String status) {
    switch (status) {
      case 'Delivered':
        return _ShipmentStatusStyle(
          textColor: const Color(0xFF047857),
          dotColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFD1FAE5).withOpacity(0.85),
          borderColor: const Color(0xFF6EE7B7),
        );
      case 'In Transit':
        return _ShipmentStatusStyle(
          textColor: const Color(0xFF0369A1),
          dotColor: const Color(0xFF0284C7),
          backgroundColor: const Color(0xFFE0F2FE).withOpacity(0.85),
          borderColor: const Color(0xFF7DD3FC),
        );
      case 'Out for Delivery':
        return _ShipmentStatusStyle(
          textColor: const Color(0xFFC2410C),
          dotColor: const Color(0xFFF97316),
          backgroundColor: const Color(0xFFFFEDD5).withOpacity(0.85),
          borderColor: const Color(0xFFFDBA74),
        );
      case 'Scheduled':
      default:
        return _ShipmentStatusStyle(
          textColor: const Color(0xFF475569),
          dotColor: const Color(0xFF94A3B8),
          backgroundColor: const Color(0xFFF1F5F9).withOpacity(0.85),
          borderColor: const Color(0xFFCBD5E1),
        );
    }
  }

  // Section 9: Truck Icon Gradients matching screenshot
  Gradient _getTruckIconGradient(String status) {
    switch (status) {
      case 'Delivered':
      case 'In Transit':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        );
      case 'Out for Delivery':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA040), Color(0xFFFF6A00)],
        );
      case 'Scheduled':
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6584), Color(0xFFE11D48)],
        );
    }
  }

  // Empty State when search or filter returns 0 results
  Widget _buildEmptyState(BuildContext context, ShipmentsNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 44, color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'No Shipments Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or filter criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                notifier.clearFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Clear All Filters',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 7: Filter Bottom Sheet Modal
  void _showFilterModal(BuildContext context, ShipmentsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final currentFilter = notifier.statusFilter;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filter Shipments by Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'All',
                      'Scheduled',
                      'In Transit',
                      'Out for Delivery',
                      'Delivered',
                    ].map((f) {
                      final isSelected =
                          currentFilter.toLowerCase() == f.toLowerCase();
                      return ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        selectedColor: AppColors.primaryOrange,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) {
                          notifier.setStatusFilter(f);
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Section 12: Shipment Details Modal Sheet & Timeline
  void _showShipmentDetailsModal(
    BuildContext context,
    Shipment initialShipment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, modalRef, _) {
            final shipments = modalRef.watch(shipmentsProvider);
            final shipment = shipments.firstWhere(
              (s) => s.awbNumber == initialShipment.awbNumber,
              orElse: () => initialShipment,
            );

            final statusStyle = _getShipmentStatusStyle(shipment.status);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Pull Handle
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with AWB & Status Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Shipment Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                shipment.awbNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Order: ${shipment.orderId} • Shop: ${shipment.shopName}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusStyle.borderColor),
                          ),
                          child: Text(
                            shipment.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16),

                  // Scrollable Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Cargo & Delivery Destination Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF38BDF8),
                                      Color(0xFF0284C7),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_shipping_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${shipment.productName} (${shipment.quantity} units)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Delivery Address: ${shipment.deliveryAddress}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Driver: ${shipment.driverName} (${shipment.driverPhone}) • Van: ${shipment.vehicleNumber}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shipment Progress Timeline (Tracking Steps)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tracking Timeline & Milestones',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 14),
                              ...shipment.trackingSteps.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final step = entry.value;
                                final isLast =
                                    idx == shipment.trackingSteps.length - 1;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: step.isCompleted
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFE2E8F0),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            step.isCompleted
                                                ? Icons.check_rounded
                                                : Icons.circle,
                                            size: 14,
                                            color: step.isCompleted
                                                ? Colors.white
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 38,
                                            color: step.isCompleted
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step.title,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: step.isCompleted
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            step.time,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          Text(
                                            step.description,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Authorized Action Workflow
                        const Text(
                          'Action Workflow',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (shipment.status == 'Scheduled') ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(shipmentsProvider.notifier)
                                  .updateShipmentStatus(
                                    shipment.awbNumber,
                                    'In Transit',
                                    note: 'Truck loaded and departed for route delivery',
                                  );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${shipment.awbNumber} moved to In Transit',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.departure_board_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Dispatch (Mark In Transit)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ] else if (shipment.status == 'In Transit') ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(shipmentsProvider.notifier)
                                  .updateShipmentStatus(
                                    shipment.awbNumber,
                                    'Out for Delivery',
                                    note: 'Driver assigned to final shop approach',
                                  );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${shipment.awbNumber} marked Out for Delivery',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.near_me_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Mark Out for Delivery',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ] else if (shipment.status == 'Out for Delivery') ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(shipmentsProvider.notifier)
                                  .updateShipmentStatus(
                                    shipment.awbNumber,
                                    'Delivered',
                                    note:
                                        'Handed over and verified via Shop OTP',
                                  );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${shipment.awbNumber} marked as Delivered',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Confirm Handover (Delivered)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ShipmentStatusStyle {
  final Color textColor;
  final Color dotColor;
  final Color backgroundColor;
  final Color borderColor;

  const _ShipmentStatusStyle({
    required this.textColor,
    required this.dotColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
