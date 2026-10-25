import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_components.dart';

class SupplierManagementScreen extends ConsumerStatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  ConsumerState<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends ConsumerState<SupplierManagementScreen> {
  int _selectedTopTab = 0; // 0: Suppliers, 1: Reports & Analytics, 2: Settings
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _topTabs = ['Suppliers', 'Reports & Analytics', 'Settings'];
  final List<String> _categories = ['All', 'Grains & Pulses', 'Edible Oils & Spices', 'Packaged Staples & Sugar'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSupplierDialog([Supplier? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final contactCtrl = TextEditingController(text: existing?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final amountCtrl = TextEditingController(text: existing != null ? existing.totalPurchases.toStringAsFixed(0) : '');
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
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter supplier name' : null,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Contact Person *',
                  hint: 'e.g. Arun Bhatia',
                  controller: contactCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact person' : null,
                ),
                const SizedBox(height: 12),
                GlassInputField(
                  label: 'Phone Number *',
                  hint: 'e.g. +91 98110 54321',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid phone number' : null,
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
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid purchase figure' : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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
                      items: _categories.where((c) => c != 'All').map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          category = val;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  text: isEditing ? 'Save Changes' : 'Add Supplier',
                  icon: isEditing ? Icons.check : Icons.add,
                  width: double.infinity,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (isEditing) {
                        final updated = existing.copyWith(
                          name: nameCtrl.text.trim(),
                          contactPerson: contactCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          category: category,
                          totalPurchases: amount,
                        );
                        ref.read(suppliersProvider.notifier).updateSupplier(updated);
                      } else {
                        final newSup = Supplier(
                          id: 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          name: nameCtrl.text.trim(),
                          contactPerson: contactCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          category: category,
                          totalPurchases: amount,
                          status: 'Active',
                          address: 'Commercial Complex, Sector 4',
                          lastPurchaseDate: 'Today',
                        );
                        ref.read(suppliersProvider.notifier).addSupplier(newSup);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1E293B),
                          content: Text(isEditing ? 'Supplier updated successfully' : 'Supplier added successfully'),
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(supplier.category, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                GlassStatusBadge(status: supplier.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person_outline, 'Contact Person', supplier.contactPerson),
            _buildDetailRow(Icons.phone_outlined, 'Phone', supplier.phone),
            _buildDetailRow(Icons.email_outlined, 'Email', supplier.email),
            _buildDetailRow(Icons.location_on_outlined, 'Address', supplier.address),
            _buildDetailRow(Icons.calendar_today_outlined, 'Last Purchase', supplier.lastPurchaseDate),
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
                    text: supplier.status == 'Active' ? 'Deactivate' : 'Activate',
                    isPrimary: false,
                    onPressed: () {
                      ref.read(suppliersProvider.notifier).toggleStatus(supplier.id);
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

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isHighlight ? AppColors.primaryOrange : Colors.white60),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
                          child: Text(
                            'ShopEasy',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
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

                // Top Tabs matching Reference: Suppliers | Reports & Analytics | Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassTabBar(
                    tabs: _topTabs,
                    selectedIndex: _selectedTopTab,
                    onTabSelected: (idx) {
                      setState(() => _selectedTopTab = idx);
                      if (idx == 1) {
                        context.push('/reports');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedTopTab == 0) ...[
                  // Header Row: "Supplier Management" heading + "+ Add Supplier" Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Supplier Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showAddSupplierDialog(),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Add Supplier',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search & Category Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassSearchBar(
                      hintText: 'Search suppliers by name...',
                      controller: _searchController,
                      onChanged: (q) => ref.read(suppliersProvider.notifier).search(q),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              ref.read(suppliersProvider.notifier).setCategoryFilter(cat);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: isSel ? GlassTheme.activeChipDecoration : GlassTheme.inactiveChipDecoration,
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Supplier List matching demo data:
                  // ABC Foods Ltd. — ₹2,50,000 — Active
                  // Sunrise FMCG — ₹1,65,000 — Active
                  // Global Partners — ₹1,20,000 — Active
                  Expanded(
                    child: suppliers.isEmpty
                        ? GlassEmptyState(
                            title: 'No Suppliers Found',
                            message: 'Add a new supplier to start tracking purchases.',
                            icon: Icons.business_outlined,
                            actionText: 'Add Supplier',
                            onAction: () => _showAddSupplierDialog(),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: suppliers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final sup = suppliers[idx];
                              return _buildSupplierCard(context, sup);
                            },
                          ),
                  ),

                  // Key Reports Shortcut Cards (Stock Report, Sales Report, Purchase Report, Profit & Loss)
                  _buildKeyReportsSection(context),
                  const SizedBox(height: 12),
                ] else if (_selectedTopTab == 2) ...[
                  // Settings tab
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Supplier Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 14),
                            SwitchListTile(
                              value: true,
                              onChanged: (_) {},
                              title: const Text('Auto Purchase Requisitions', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: const Text('Automatically generate RFQs for low stock items', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              activeColor: AppColors.primaryOrange,
                            ),
                            SwitchListTile(
                              value: true,
                              onChanged: (_) {},
                              title: const Text('Supplier Payment Reminders', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: const Text('Notify 2 days before payment due dates', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              activeColor: AppColors.primaryOrange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Supplier sup) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      onTap: () => _showSupplierDetails(sup),
      child: Row(
        children: [
          // Supplier Avatar / Initial
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange.withOpacity(0.4),
                  AppColors.primaryOrangeLight.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                sup.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sup.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sup.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 5),
                // Total Purchases
                Row(
                  children: [
                    const Text('Purchases: ', style: TextStyle(fontSize: 12, color: Colors.white60)),
                    const Text('₹', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryOrange)),
                    Text(
                      ' ${sup.totalPurchases.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status & Chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GlassStatusBadge(status: sup.status),
              const SizedBox(height: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyReportsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Key Reports',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: () => context.push('/reports'),
                child: const Text(
                  'View All Reports ->',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrangeLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildReportMiniCard(context, 'Stock Report', Icons.inventory_2_outlined, '48 SKUs', () => context.push('/reports?tab=0')),
              const SizedBox(width: 8),
              _buildReportMiniCard(context, 'Sales Report', Icons.trending_up_rounded, '₹ 12.85L', () => context.push('/reports?tab=1')),
              const SizedBox(width: 8),
              _buildReportMiniCard(context, 'Purchase Report', Icons.receipt_long_rounded, '₹ 9.40L', () => context.push('/reports?tab=2')),
              const SizedBox(width: 8),
              _buildReportMiniCard(context, 'Profit & Loss', Icons.account_balance_wallet_outlined, '₹ 2.60L', () => context.push('/reports?tab=3')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportMiniCard(BuildContext context, String title, IconData icon, String subtitle, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryOrangeLight),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
