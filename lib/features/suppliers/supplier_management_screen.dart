import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/glass_components.dart';

/// Screen reproducing the ShopEasy Supplier Management & Key Reports UI with pixel accuracy
class SupplierManagementScreen extends ConsumerStatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  ConsumerState<SupplierManagementScreen> createState() =>
      _SupplierManagementScreenState();
}

class _SupplierManagementScreenState
    extends ConsumerState<SupplierManagementScreen> {
  int _selectedTopTab = 0; // 0: Suppliers, 1: Reports & Analytics, 2: Settings

  final List<String> _topTabs = [
    'Suppliers',
    'Reports & Analytics',
    'Settings',
  ];

  void _showAddSupplierDialog([Supplier? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final contactCtrl = TextEditingController(
      text: existing?.contactPerson ?? '',
    );
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? existing.totalPurchases.toStringAsFixed(0) : '',
    );
    String category = existing?.category ?? 'Grains & Pulses';
    final formKey = GlobalKey<FormState>();

    showGlassDialog(
      context: context,
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Supplier' : 'Add New Supplier',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassInputField(
                  label: 'Company / Supplier Name *',
                  hint: 'e.g. ABC Foods Ltd.',
                  controller: nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter supplier name'
                      : null,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Contact Person *',
                  hint: 'e.g. Arun Bhatia',
                  controller: contactCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter contact person'
                      : null,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Phone Number *',
                  hint: 'e.g. +91 98110 54321',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Enter valid phone number'
                      : null,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Email Address',
                  hint: 'e.g. sales@abcfoods.com',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Total Purchases (₹) *',
                  hint: 'e.g. 250000',
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || double.tryParse(v) == null)
                      ? 'Enter valid purchase figure'
                      : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: category,
                      dropdownColor: const Color(0xFF1E293B),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Grains & Pulses',
                          child: Text('Grains & Pulses'),
                        ),
                        DropdownMenuItem(
                          value: 'Edible Oils & Spices',
                          child: Text('Edible Oils & Spices'),
                        ),
                        DropdownMenuItem(
                          value: 'Packaged Staples & Sugar',
                          child: Text('Packaged Staples & Sugar'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          category = val;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GlassButton(
                  text: isEditing ? 'Update Supplier' : 'Save Supplier',
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final purchases =
                          double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (isEditing) {
                        ref
                            .read(suppliersProvider.notifier)
                            .updateSupplier(
                              existing.copyWith(
                                name: nameCtrl.text.trim(),
                                contactPerson: contactCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                totalPurchases: purchases,
                                category: category,
                              ),
                            );
                      } else {
                        ref
                            .read(suppliersProvider.notifier)
                            .addSupplier(
                              Supplier(
                                id: 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                name: nameCtrl.text.trim(),
                                contactPerson: contactCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                totalPurchases: purchases,
                                category: category,
                                status: 'Active',
                                address: 'Industrial Area, Phase 2',
                                lastPurchaseDate: 'Today',
                              ),
                            );
                      }
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
                                  isEditing
                                      ? 'Supplier details updated!'
                                      : 'Supplier added successfully!',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupplierDetails(Supplier supplier) {
    showGlassBottomSheet(
      context: context,
      child: Padding(
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
                        supplier.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supplier.category,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassStatusBadge(status: supplier.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.person_outline,
              'Contact Person',
              supplier.contactPerson,
            ),
            _buildDetailRow(Icons.phone_outlined, 'Phone', supplier.phone),
            _buildDetailRow(Icons.email_outlined, 'Email', supplier.email),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Address',
              supplier.address,
            ),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Last Purchase',
              supplier.lastPurchaseDate,
            ),
            _buildDetailRow(
              Icons.currency_rupee_rounded,
              'Total Lifetime Purchases',
              '₹ ${supplier.totalPurchases.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
              isHighlight: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: supplier.status == 'Active'
                        ? 'Deactivate'
                        : 'Activate',
                    isPrimary: false,
                    onPressed: () {
                      ref
                          .read(suppliersProvider.notifier)
                          .toggleStatus(supplier.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    text: 'Edit Details',
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddSupplierDialog(supplier);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isHighlight ? AppColors.primaryOrange : Colors.white60,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlight ? AppColors.primaryOrange : Colors.white,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: isHighlight ? 15 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Ambient Frosted Glass Background
          const _SupplierAtmosphericBackground(),

          // 2. Main Scrollable Content Viewport
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

                        // Top Segmented Tabs: Suppliers | Reports & Analytics | Settings
                        _buildTopTabBar(),

                        const SizedBox(height: 14),

                        if (_selectedTopTab == 0) ...[
                          // Section 1: Supplier Management Frosted Card
                          _buildSupplierManagementCard(suppliers),

                          const SizedBox(height: 18),

                          // Section 2: Key Reports Section with 4 Frosted Tiles
                          _buildKeyReportsSection(),
                        ] else if (_selectedTopTab == 1) ...[
                          _buildReportsTabContent(),
                        ] else ...[
                          _buildSettingsTabContent(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Navigation Dock (More Selected at Index 4)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ShopEasyBottomNav(
              currentIndex: 4, // More tab selected as shown in reference
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
                    // Current More screen
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

  /// Top Segmented Tab Bar reproducing Suppliers | Reports & Analytics | Settings
  Widget _buildTopTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_topTabs.length, (index) {
          final isSelected = _selectedTopTab == index;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedTopTab = index);
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF851B), Color(0xFFFF5B00)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6A00).withOpacity(0.38),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: Text(
                  _topTabs[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF4A6585),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Large Supplier Management Panel containing heading, "+ Add Supplier" button, and 3 reference rows
  Widget _buildSupplierManagementCard(List<Supplier> suppliers) {
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
                // Header Row inside Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Supplier Management',
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF162544),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showAddSupplierDialog(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF9533), Color(0xFFFF5500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6A00).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Add Supplier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Reference Supplier Rows
                if (suppliers.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: Text(
                      'No suppliers found. Tap + Add Supplier to start.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13.5,
                      ),
                    ),
                  )
                else
                  ...suppliers.map(
                    (sup) => GlassSupplierRow(
                      supplier: sup,
                      onTap: () => _showSupplierDetails(sup),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section 2: Key Reports Panel containing 4 frosted glass tiles
  Widget _buildKeyReportsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Reports',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF162544),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 1. Stock Report (Orange)
              Expanded(
                child: _buildKeyReportTile(
                  title: 'Stock Report',
                  icon: Icons.description_rounded,
                  iconGradient: const [Color(0xFFFF9533), Color(0xFFFF5500)],
                  glowColor: const Color(0xFFFF6A00),
                  onTap: () => context.push('/reports?tab=0'),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Sales Report (Purple)
              Expanded(
                child: _buildKeyReportTile(
                  title: 'Sales Report',
                  icon: Icons.show_chart_rounded,
                  iconGradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                  glowColor: const Color(0xFFA855F7),
                  onTap: () => context.push('/reports?tab=1'),
                ),
              ),
              const SizedBox(width: 10),

              // 3. Purchase Report (Amber)
              Expanded(
                child: _buildKeyReportTile(
                  title: 'Purchase Report',
                  icon: Icons.inventory_2_rounded,
                  iconGradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                  glowColor: const Color(0xFFF59E0B),
                  onTap: () => context.push('/reports?tab=2'),
                ),
              ),
              const SizedBox(width: 10),

              // 4. Profit & Loss (Red / Pink)
              Expanded(
                child: _buildKeyReportTile(
                  title: 'Profit & Loss',
                  icon: Icons.receipt_long_rounded,
                  iconGradient: const [Color(0xFFF87171), Color(0xFFDC2626)],
                  glowColor: const Color(0xFFEF4444),
                  onTap: () => context.push('/reports?tab=3'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyReportTile({
    required String title,
    required IconData icon,
    required List<Color> iconGradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Icon Square Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: iconGradient,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.38),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Label: 2 Lines Centered
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF162544),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Reports & Analytics Tab Content
  Widget _buildReportsTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildKeyReportsSection(),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Report Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Access warehouse valuation, margin breakdown, procurement invoices, and gross profit by tapping on any Key Report above.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                GlassButton(
                  text: 'Open Full Reports Hub',
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => context.push('/reports'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Settings Tab Content
  Widget _buildSettingsTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Configuration',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text(
                'Auto Purchase Requisitions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Automatically generate RFQs for low stock items',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              activeColor: AppColors.primaryOrange,
            ),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text(
                'Supplier Payment Reminders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Notify 2 days before payment due dates',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              activeColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Schedule Row matching the screenshot with glowing orange avatar, name, amount, active pill, and chevron
class GlassSupplierRow extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const GlassSupplierRow({
    super.key,
    required this.supplier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount =
        '₹ ${supplier.totalPurchases.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';

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
          splashColor: const Color(0xFFFF7A00).withOpacity(0.12),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Glowing Orange Person Avatar Circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFA055), Color(0xFFFF7A00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7A00).withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Supplier Name
                Expanded(
                  flex: 3,
                  child: Text(
                    supplier.name,
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

                // Purchase Amount
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A7596),
                  ),
                ),
                const SizedBox(width: 10),

                // Status Badge (Active with green dot)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4F7DF).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF86EFAC).withOpacity(0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.status,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Trailing Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8B9EB5),
                  size: 20,
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
class _SupplierAtmosphericBackground extends StatelessWidget {
  const _SupplierAtmosphericBackground();

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
