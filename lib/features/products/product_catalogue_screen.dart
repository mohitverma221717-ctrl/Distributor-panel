import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_components.dart';

class ProductCatalogueScreen extends ConsumerStatefulWidget {
  const ProductCatalogueScreen({super.key});

  @override
  ConsumerState<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends ConsumerState<ProductCatalogueScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc', 'demand'
  bool _inStockOnly = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': null},
    {'name': 'Grocery', 'icon': Icons.shopping_basket_outlined},
    {'name': 'Household', 'icon': Icons.home_outlined},
    {'name': 'Personal Care', 'icon': Icons.person_outline},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showGlassBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                const Text(
                  'Sort By Price',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('Price: Low to High', _sortBy == 'price_asc', () {
                      setSheetState(() => _sortBy = 'price_asc');
                      setState(() => _sortBy = 'price_asc');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Price: High to Low', _sortBy == 'price_desc', () {
                      setSheetState(() => _sortBy = 'price_desc');
                      setState(() => _sortBy = 'price_desc');
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Availability',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('In Stock Only', _inStockOnly, () {
                      setSheetState(() => _inStockOnly = !_inStockOnly);
                      setState(() => _inStockOnly = !_inStockOnly);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                GlassButton(
                  text: 'Apply Filters',
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showProductDetails(DemandProduct product) {
    int selectedQty = 1;
    showGlassBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: product.imageAsset != null
                          ? Image.asset(product.imageAsset!, fit: BoxFit.contain)
                          : const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('₹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryOrange)),
                              Text(
                                ' ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const GlassStatusBadge(status: 'In Stock'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Hub Stock:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('${product.totalDemand} ${product.unit}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Quantity:', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: selectedQty > 1 ? () => setModalState(() => selectedQty--) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$selectedQty',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setModalState(() => selectedQty++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(
                      '₹ ${(product.price * selectedQty).toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassButton(
                  text: 'Add $selectedQty to Order',
                  icon: Icons.shopping_cart_outlined,
                  width: double.infinity,
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product, qty: selectedQty);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1E293B),
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 20),
                            const SizedBox(width: 10),
                            Text('Added $selectedQty x ${product.name} to order'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCartSheet() {
    final cart = ref.watch(cartProvider);
    final totalCount = ref.watch(cartProvider.notifier).totalItemCount;
    final totalAmount = ref.watch(cartProvider.notifier).totalAmount;

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
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryOrange, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Order Requisition ($totalCount)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear', style: TextStyle(color: AppColors.alertPink, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cart.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('Your order requisition is empty', style: TextStyle(color: Colors.white60)),
                ),
              )
            else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cart.values.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 16),
                  itemBuilder: (context, idx) {
                    final item = cart.values.elementAt(idx);
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('₹ ${item.product.price.toStringAsFixed(0)} each', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 20),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryOrange, size: 20),
                              onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1),
                            ),
                            const SizedBox(width: 8),
                            Text('₹ ${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Estimated Amount:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('₹ ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primaryOrange, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 20),
              GlassButton(
                text: 'Confirm & Generate Requisition',
                width: double.infinity,
                onPressed: () {
                  ref.read(cartProvider.notifier).clear();
                  Navigator.pop(context);
                  showGlassDialog(
                    context: context,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.successGreen, size: 56),
                          const SizedBox(height: 16),
                          const Text('Requisition Created!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text(
                            'Your stock requisition has been submitted to the supplier dispatch desk.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          GlassButton(
                            text: 'Done',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(demandProvider).topProducts;
    final cart = ref.watch(cartProvider);
    final totalCartCount = ref.watch(cartProvider.notifier).totalItemCount;
    final totalCartAmount = ref.watch(cartProvider.notifier).totalAmount;

    // Filter by Category
    var filtered = allProducts;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();
    }

    // Filter by Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by In-Stock
    if (_inStockOnly) {
      filtered = filtered.where((p) => p.totalDemand > 0).toList();
    }

    // Sort
    if (_sortBy == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background - Warm blurred supermarket backdrop matching screenshot
          Positioned.fill(
            child: Image.asset(
              'assets/images/market_backdrop.jpg',
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
              color: Colors.black.withOpacity(0.06),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Frosted Glass Header matching reference
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        // ShopEasy Logo Bag (Orange square with white 'S')
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/shopeasy_bag_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.orangeGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'S',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Branding text
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ShopEasy',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your Local Shop, Our Priority',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Header Notification Icon with Red Badge Dot
                        GlassIconButton(
                          icon: Icons.notifications_none_rounded,
                          size: 38,
                          borderRadius: 12,
                          hasBadge: true,
                          onTap: () => context.push('/notifications'),
                        ),
                        const SizedBox(width: 8),
                        // Header Profile Avatar Icon
                        GlassIconButton(
                          icon: Icons.person_outline_rounded,
                          size: 38,
                          borderRadius: 12,
                          onTap: () => context.push('/profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar and Filter Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Glass Search Field
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (q) => setState(() => _searchQuery = q),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.65),
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 22,
                                color: Colors.white70,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Glass Filter Button with Funnel icon
                      GlassContainer(
                        width: 46,
                        height: 46,
                        borderRadius: 16,
                        onTap: _showFilterSheet,
                        child: const Center(
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips matching reference
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _categories.map((cat) {
                      final name = cat['name'] as String;
                      final icon = cat['icon'] as IconData?;
                      final isSelected = _selectedCategory == name;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = name),
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: isSelected
                                ? GlassTheme.activeChipDecoration
                                : GlassTheme.inactiveChipDecoration,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (icon != null) ...[
                                  Icon(
                                    icon,
                                    size: 16,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Products List matching Reference Cards
                Expanded(
                  child: filtered.isEmpty
                      ? const GlassEmptyState(
                          title: 'No Products Found',
                          message: 'Try searching for a different item or clear active filters.',
                          icon: Icons.inventory_2_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = filtered[index];
                            final qtyInCart = cart[product.id]?.quantity ?? 0;

                            return _buildProductCard(context, product, qtyInCart);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Floating Cart Checkout Pill if items added
          if (totalCartCount > 0)
            Positioned(
              left: 20,
              right: 20,
              bottom: 84,
              child: InkWell(
                onTap: _showCartSheet,
                borderRadius: BorderRadius.circular(24),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0F172A).withOpacity(0.82),
                  borderColor: AppColors.primaryOrangeLight.withOpacity(0.8),
                  borderWidth: 1.2,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalCartCount',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Order Requisition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('Estimated: ₹ ${totalCartAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primaryOrangeLight, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Exact replication of the Product Card from the reference screenshot
  Widget _buildProductCard(BuildContext context, DemandProduct product, int qtyInCart) {
    return GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(12),
      onTap: () => _showProductDetails(product),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image Container with Warm Glow Box
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageAsset != null
                  ? Image.asset(
                      product.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white70,
                        size: 36,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white70,
                      size: 36,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Price Row: Orange Rupee Symbol + White Digits
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.price.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Stock and Availability Line: Stock: 420 • In Stock
                Row(
                  children: [
                    Text(
                      'Stock: ${product.totalDemand}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'In Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Controls: Orange Gradient Add Button + Chevron
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vibrant Orange Gradient Add Button
              InkWell(
                onTap: () {
                  ref.read(cartProvider.notifier).addItem(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E293B),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 20),
                          const SizedBox(width: 10),
                          Text('Added ${product.name} to order'),
                        ],
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        qtyInCart > 0 ? 'Add ($qtyInCart)' : 'Add',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Detail Navigation Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.75),
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
