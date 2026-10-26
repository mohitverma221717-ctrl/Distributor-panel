import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/shopeasy_header.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final totalUnits = inventoryNotifier.totalStockUnits;
    final lowStockCount = inventoryNotifier.lowStockItemCount;
    final formattedTotalStock = NumberFormat('#,###').format(totalUnits);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Photo-realistic Warehouse Backdrop matching reference screenshot
          Positioned.fill(
            child: Image.asset(
              'assets/images/warehouse_backdrop.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/warehouse_art.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.warmBackgroundGradient,
                  ),
                ),
              ),
            ),
          ),

          // 2. High-fidelity Frosted Backdrop Blur Layer with warm bokeh illumination
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.black.withOpacity(0.04),
                      const Color(0xFFFF9E40).withOpacity(0.06),
                      Colors.black.withOpacity(0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Scrollable Content Layer
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5.1 ShopEasy Reference Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    child: ShopEasyHeader(
                      isInGlassCard: false,
                      showSubtitle: true,
                      rightAction: HeaderRightAction.profileAndNotification,
                      onNotificationTap: () => context.push('/notifications'),
                      onProfileTap: () => context.push('/profile'),
                    ),
                  ),

                  // 5.2 Warehouse Inventory Heading & Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Warehouse Inventory',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Manage your stock, keep business moving',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.88),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5.3 & 5.4 Dual Summary Cards Row: Total Stock & Low Stock Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Card 1: Total Stock
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Total Stock',
                            value: formattedTotalStock,
                            unit: 'units',
                            icon: Icons.inventory_2_rounded,
                            iconGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                            ),
                            iconShadowColor: const Color(0xFF0284C7)
                                .withOpacity(0.4),
                            onTap: () => context.push('/reports?tab=0'),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: Low Stock Items
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Low Stock Items',
                            value: '$lowStockCount',
                            unit: 'items',
                            icon: Icons.warning_rounded,
                            iconGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                            ),
                            iconShadowColor: const Color(0xFFEF4444)
                                .withOpacity(0.4),
                            onTap: () {
                              if (inventoryNotifier.stockFilter ==
                                  'Low Stock') {
                                inventoryNotifier.setStockFilter('All');
                              } else {
                                inventoryNotifier.setStockFilter('Low Stock');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5.5 Glassmorphism Search Bar & Filter Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Search Bar Container
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.34),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.65),
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
                                  controller: _searchController,
                                  onChanged: (q) =>
                                      inventoryNotifier.setSearchQuery(q),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 22,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              inventoryNotifier.setSearchQuery(
                                                '',
                                              );
                                              setState(() {});
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
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Filter Button
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: InkWell(
                              onTap: () => _showFilterBottomSheet(context, ref),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color:
                                      inventoryNotifier.stockFilter != 'All' ||
                                          inventoryNotifier.selectedCategory !=
                                              'All'
                                      ? AppColors.primaryOrange.withOpacity(
                                          0.85,
                                        )
                                      : Colors.white.withOpacity(0.34),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.65),
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
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5.6 & 5.7 Reference Inventory Table Glass Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.34),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.68),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Table Header Row: [Product] [Stock] [Status]
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    // Blue Cube Icon + Product Label
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF38BDF8),
                                            Color(0xFF0284C7),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0284C7)
                                                .withOpacity(0.35),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Product',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.2,
                                      ),
                                    ),

                                    const Spacer(),

                                    // Stock Column Header
                                    const SizedBox(
                                      width: 52,
                                      child: Center(
                                        child: Text(
                                          'Stock',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Status Column Header
                                    const SizedBox(
                                      width: 88,
                                      child: Center(
                                        child: Text(
                                          'Status',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ), // Alignment padding for chevron
                                  ],
                                ),
                              ),

                              // Table Row Divider
                              Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.38),
                              ),

                              // Product Rows
                              if (inventory.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 44,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'No matching warehouse stock found',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Try adjusting your search query or filters',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.75),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      TextButton.icon(
                                        onPressed: () {
                                          _searchController.clear();
                                          inventoryNotifier.resetFilters();
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Reset Filters',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors
                                              .primaryOrange
                                              .withOpacity(0.8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: inventory.length,
                                  separatorBuilder: (context, index) =>
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        color: Colors.white.withOpacity(0.24),
                                      ),
                                  itemBuilder: (context, index) {
                                    final item = inventory[index];
                                    return _buildProductTableRow(
                                      context,
                                      item,
                                      ref,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5.3 & 5.4 Summary Card Builder
  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Gradient iconGradient,
    required Color iconShadowColor,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.36),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.68),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Glowing Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: iconGradient,
                    boxShadow: [
                      BoxShadow(
                        color: iconShadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),

                // Text Information: Title, Big Value, Unit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right-side Navigation Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5.6 Product Table Row Builder
  Widget _buildProductTableRow(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) {
    return InkWell(
      onTap: () => _showProductDetailModal(context, item, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Product 3D Asset Image
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: item.imageAsset != null
                  ? Image.asset(
                      item.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildFallbackIcon(item),
                    )
                  : _buildFallbackIcon(item),
            ),
            const SizedBox(width: 12),

            // Product Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sku,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Stock Count Value
            SizedBox(
              width: 52,
              child: Center(
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Status Pill Badge (Green In Stock vs Coral Low Stock)
            SizedBox(
              width: 82,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isLowStock
                        ? const Color(0xFFFFEDD5)
                              .withOpacity(0.9) // Soft salmon/peach
                        : const Color(0xFFDCFCE7)
                              .withOpacity(0.9), // Soft mint green
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isLowStock
                          ? const Color(0xFFFDBA74).withOpacity(0.6)
                          : const Color(0xFF86EFAC).withOpacity(0.6),
                      width: 0.8,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isLowStock
                                ? const Color(0xFFEA580C)
                                : const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.isLowStock ? 'Low Stock' : 'In Stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: item.isLowStock
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Right Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(InventoryItem item) {
    return Icon(
      item.isLowStock
          ? Icons.warning_amber_rounded
          : Icons.inventory_2_outlined,
      size: 20,
      color: item.isLowStock
          ? const Color(0xFFEA580C)
          : const Color(0xFF0284C7),
    );
  }

  // 5.8 Product Row Interactions: Full Detail, Stock Adjustment & Movement History Modal
  void _showProductDetailModal(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, modalRef, _) {
            // Watch current state of the item in case stock was adjusted
            final currentItems = modalRef.watch(inventoryProvider);
            final latestItem = currentItems.firstWhere(
              (i) => i.id == item.id,
              orElse: () => item,
            );
            final movements = modalRef
                .read(inventoryProvider.notifier)
                .getMovements(latestItem.id);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
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

                  // Header with Title & Close
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inventory Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Product Overview Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: latestItem.imageAsset != null
                                    ? Image.asset(
                                        latestItem.imageAsset!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.inventory_2_rounded,
                                              color: AppColors.primaryOrange,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppColors.primaryOrange,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      latestItem.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${latestItem.sku} • Location: ${latestItem.warehouseLocation}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Category: ${latestItem.category}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '₹${latestItem.pricePerUnit.toStringAsFixed(0)} / ${latestItem.unit}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Current Stock Status Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Stock & Threshold',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStockMetric(
                                    label: 'Current Quantity',
                                    value: '${latestItem.quantity}',
                                    unit: latestItem.unit,
                                    valueColor: latestItem.isLowStock
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF16A34A),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  _buildStockMetric(
                                    label: 'Reorder Threshold',
                                    value: '${latestItem.lowStockThreshold}',
                                    unit: latestItem.unit,
                                    valueColor: const Color(0xFF64748B),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  _buildStockMetric(
                                    label: 'Stock Status',
                                    value: latestItem.isLowStock
                                        ? 'Low Stock'
                                        : 'In Stock',
                                    unit: latestItem.isLowStock
                                        ? 'Reorder now'
                                        : 'Optimal',
                                    valueColor: latestItem.isLowStock
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF16A34A),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stock Operations Section (Authorized Adjustments)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fast Stock Adjustments',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Record inbound receipts or issue stock to maintain accurate counts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAdjustmentButton(
                                      label: '- 10',
                                      color: const Color(0xFFEF4444),
                                      onTap: () {
                                        ref
                                            .read(inventoryProvider.notifier)
                                            .adjustStock(
                                              latestItem.id,
                                              -10,
                                              reason: 'Manual Stock Reduction',
                                            );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildAdjustmentButton(
                                      label: '- 1',
                                      color: const Color(0xFFF97316),
                                      onTap: () {
                                        ref
                                            .read(inventoryProvider.notifier)
                                            .adjustStock(
                                              latestItem.id,
                                              -1,
                                              reason: 'Unit Stock Issue',
                                            );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildAdjustmentButton(
                                      label: '+ 1',
                                      color: const Color(0xFF10B981),
                                      onTap: () {
                                        ref
                                            .read(inventoryProvider.notifier)
                                            .adjustStock(
                                              latestItem.id,
                                              1,
                                              reason: 'Single Unit Return / Receipt',
                                            );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildAdjustmentButton(
                                      label: '+ 10',
                                      color: const Color(0xFF0284C7),
                                      onTap: () {
                                        ref
                                            .read(inventoryProvider.notifier)
                                            .adjustStock(
                                              latestItem.id,
                                              10,
                                              reason: 'Bulk Stock Inward Batch',
                                            );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showCustomAdjustmentDialog(
                                            context,
                                            latestItem,
                                            ref,
                                          ),
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Custom Adjustment'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.primaryOrange,
                                        side: const BorderSide(
                                          color: AppColors.primaryOrange,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showThresholdEditDialog(
                                        context,
                                        latestItem,
                                        ref,
                                      ),
                                      icon: const Icon(
                                        Icons.tune_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Edit Threshold',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0F172A,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Recent Inventory Movements
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Inventory Movements',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${movements.length} logs',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (movements.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'No recent stock movements recorded for this item.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                )
                              else
                                ...movements.map((m) => _buildMovementTile(m)),
                            ],
                          ),
                        ),
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

  Widget _buildStockMetric({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildAdjustmentButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementTile(StockMovement movement) {
    final isPositive = movement.quantityChange >= 0;
    final formattedDate = DateFormat('dd MMM, hh:mm a')
        .format(movement.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_rounded : Icons.remove_rounded,
              size: 14,
              color: isPositive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.reason,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '$formattedDate • by ${movement.performedBy}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${movement.quantityChange}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isPositive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomAdjustmentDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) {
    final qtyController = TextEditingController();
    final reasonController = TextEditingController(
      text: 'Manual inventory adjustment',
    );
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Adjust Stock: ${item.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Receipt (+) ')),
                      selected: isAddition,
                      selectedColor: const Color(0xFFDCFCE7),
                      onSelected: (val) => setDlgState(() => isAddition = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Issue (-) ')),
                      selected: !isAddition,
                      selectedColor: const Color(0xFFFFEDD5),
                      onSelected: (val) =>
                          setDlgState(() => isAddition = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (units)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason / Reference Note',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty > 0) {
                  final delta = isAddition ? qty : -qty;
                  ref
                      .read(inventoryProvider.notifier)
                      .adjustStock(
                        item.id,
                        delta,
                        reason: reasonController.text.trim(),
                      );
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Stock adjusted by ${delta > 0 ? '+$delta' : '$delta'} units',
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: const Text(
                'Save Adjustment',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThresholdEditDialog(
    BuildContext context,
    InventoryItem item,
    WidgetRef ref,
  ) {
    final thresholdController = TextEditingController(
      text: '${item.lowStockThreshold}',
    );

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Reorder Threshold: ${item.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the minimum stock level. When current stock falls below this quantity, the item is flagged as Low Stock.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: thresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Threshold Units',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newThresh =
                  int.tryParse(thresholdController.text) ??
                  item.lowStockThreshold;
              ref
                  .read(inventoryProvider.notifier)
                  .updateThreshold(item.id, newThresh);
              Navigator.pop(dlgCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reorder threshold set to $newThresh units'),
                  backgroundColor: const Color(0xFF0F172A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
            ),
            child: const Text(
              'Update Threshold',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 5.5 Comprehensive Filter Panel Bottom Sheet
  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(inventoryProvider.notifier);
    String tempCategory = notifier.selectedCategory;
    String tempStockFilter = notifier.stockFilter;
    String tempSortBy = notifier.sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      notifier.resetFilters();
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    child: const Text(
                      'Reset All',
                      style: TextStyle(color: AppColors.primaryOrange),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Stock Status Filters
              const Text(
                'Stock Status',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((
                  status,
                ) {
                  final isSel = tempStockFilter == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isSel,
                    selectedColor: AppColors.primaryOrange.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSel
                          ? AppColors.primaryOrange
                          : const Color(0xFF475569),
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    onSelected: (val) {
                      if (val) setSheetState(() => tempStockFilter = status);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Category Filter
              const Text(
                'Product Category',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                    [
                      'All',
                      'Grains',
                      'Oils',
                      'Flour',
                      'Sweeteners',
                      'Beverages',
                      'Pulses',
                      'Salt & Spices',
                      'Household',
                      'Personal Care',
                      'Snacks',
                    ].map((cat) {
                      final isSel = tempCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => tempCategory = cat);
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 14),

              // Sort By
              const Text(
                'Sort Order',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      'Default',
                      'Stock: High to Low',
                      'Stock: Low to High',
                      'Name: A-Z',
                    ].map((sort) {
                      final isSel = tempSortBy == sort;
                      return ChoiceChip(
                        label: Text(sort),
                        selected: isSel,
                        selectedColor: const Color(0xFFE2E8F0),
                        labelStyle: TextStyle(
                          color: isSel
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => tempSortBy = sort);
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.applyAdvancedFilters(
                          category: tempCategory,
                          stockFilter: tempStockFilter,
                          sortBy: tempSortBy,
                        );
                        Navigator.pop(ctx);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
