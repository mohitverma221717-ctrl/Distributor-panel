import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/distributor_models.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_components.dart';

class KeyReportsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const KeyReportsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<KeyReportsScreen> createState() => _KeyReportsScreenState();
}

class _KeyReportsScreenState extends ConsumerState<KeyReportsScreen> {
  late int _selectedTab;
  final List<String> _tabs = ['Stock Report', 'Sales Report', 'Purchase Report', 'Profit & Loss'];
  final List<String> _dateRanges = ['Today', 'This Week', 'This Month', 'FY 2026-27'];
  String _selectedRange = 'This Month';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 3);
  }

  void _exportReport(String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: AppColors.successGreen, size: 20),
            const SizedBox(width: 10),
            Text('$reportName exported to PDF & Excel successfully'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);

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
                // Header with back navigation and export button
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Financial & Operations Reports',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(
                                'Real-time verified metrics',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                          tooltip: 'Export Statement',
                          onPressed: () => _exportReport(_tabs[_selectedTab]),
                        ),
                      ],
                    ),
                  ),
                ),

                // Report Type Selector Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_tabs.length, (idx) {
                      final isSelected = _selectedTab == idx;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = idx),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: isSelected
                                ? GlassTheme.activeChipDecoration
                                : GlassTheme.inactiveChipDecoration,
                            child: Text(
                              _tabs[idx],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),

                // Date-Range Filter Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Period Filter:',
                        style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _dateRanges.map((range) {
                              final isSel = _selectedRange == range;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedRange = range),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSel ? AppColors.primaryOrange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSel ? AppColors.primaryOrange : Colors.white24,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      range,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                        color: isSel ? AppColors.primaryOrangeLight : Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Report Tab Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: _buildSelectedReport(reportsState),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedReport(ReportsState state) {
    switch (_selectedTab) {
      case 0:
        return _buildStockReport(state.stockReport);
      case 1:
        return _buildSalesReport(state.salesReport);
      case 2:
        return _buildPurchaseReport(state.purchaseReport);
      case 3:
      default:
        return _buildProfitLossReport(state.profitLossReport);
    }
  }

  // 1. Stock Report
  Widget _buildStockReport(StockReportSummary stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Warehouse Stock Valuation', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('₹', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryOrange)),
                  Text(
                    ' ${stock.totalValuation.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('Active SKUs', '${stock.totalSkus}', Icons.category_outlined, Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile('Low Stock Items', '${stock.lowStockCount}', Icons.warning_amber_rounded, AppColors.alertPink),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile('Stock Turnover', '${stock.turnoverRatio}x', Icons.autorenew_rounded, AppColors.successGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Valuation by Product Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stock.categoryBreakdown.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final cat = stock.categoryBreakdown[idx];
            final val = cat['value'] as double;
            final items = cat['items'] as int;
            final percent = (val / stock.totalValuation) * 100;

            return GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat['category'] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                      Text(
                        '₹ ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryOrangeLight, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$items Unique Products', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      Text('${percent.toStringAsFixed(1)}% of total', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Sales Report
  Widget _buildSalesReport(SalesReportSummary sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gross Distribution Sales', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('₹', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryOrange)),
                  Text(
                    ' ${sales.totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${sales.monthlyGrowthPercent}% vs last mo',
                      style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('Fulfilled Orders', '${sales.totalOrders}', Icons.local_shipping_outlined, Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile('Avg Order Value', '₹ ${sales.averageOrderValue.toStringAsFixed(0)}', Icons.receipt_outlined, AppColors.primaryOrangeLight),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Top Performing Products by Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sales.topProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final p = sales.topProducts[idx];
            final rev = p['revenue'] as double;
            final units = p['units'] as int;

            return GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('$units Units Dispatched', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Text(
                    '₹ ${rev.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 3. Purchase Report
  Widget _buildPurchaseReport(PurchaseReportSummary purchase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Supplier Purchases (YTD)', style: TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('₹', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryOrange)),
                  Text(
                    ' ${purchase.totalPurchases.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('Active Suppliers', '${purchase.activeSuppliersCount}', Icons.handshake_outlined, Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      'Outstanding Payables',
                      '₹ ${purchase.outstandingPayable.toStringAsFixed(0)}',
                      Icons.schedule_outlined,
                      AppColors.warningAmber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Purchases by Partner Supplier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: purchase.topSuppliers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final s = purchase.topSuppliers[idx];
            final amt = s['amount'] as double;

            return GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 3),
                        GlassStatusBadge(status: s['status'] as String),
                      ],
                    ),
                  ),
                  Text(
                    '₹ ${amt.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryOrangeLight, fontSize: 15),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 4. Profit & Loss Report
  Widget _buildProfitLossReport(ProfitLossSummary pl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Net Profit Hero Card
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Net Distribution Profit', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.successGreen.withOpacity(0.4)),
                    ),
                    child: Text(
                      'Net Margin: ${pl.netMarginPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('₹', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.successGreen)),
                  Text(
                    ' ${pl.netProfit.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Financial Breakdown Statement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 10),

        GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildAccountingRow('Gross Revenue (Sales)', pl.totalRevenue, isPositive: true),
              const Divider(color: Colors.white12, height: 20),
              _buildAccountingRow('Cost of Goods Sold (COGS)', pl.costOfGoodsSold, isNegative: true),
              const Divider(color: Colors.white12, height: 20),
              _buildAccountingRow('Gross Profit', pl.grossProfit, isBold: true, subtitle: 'Gross Margin: ${pl.grossMarginPercent.toStringAsFixed(1)}%'),
              const Divider(color: Colors.white12, height: 20),
              _buildAccountingRow('Operating & Logistics Expenses', pl.operatingExpenses, isNegative: true),
              const Divider(color: Colors.white24, height: 24, thickness: 1.5),
              _buildAccountingRow('Net Operating Profit', pl.netProfit, isBold: true, isNetProfit: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountingRow(
    String label,
    double amount, {
    bool isPositive = false,
    bool isNegative = false,
    bool isBold = false,
    bool isNetProfit = false,
    String? subtitle,
  }) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");
    final prefix = isNegative ? '- ₹ ' : '₹ ';
    final color = isNetProfit
        ? AppColors.successGreen
        : isNegative
            ? AppColors.alertPink
            : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isBold ? 14.5 : 13.5,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                  color: isNetProfit ? Colors.white : Colors.white.withOpacity(0.9),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$prefix$formatted',
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }
}
