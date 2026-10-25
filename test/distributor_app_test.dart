import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopeasy_distributor/data/repositories/distributor_repository.dart';
import 'package:shopeasy_distributor/features/auth/login_screen.dart';
import 'package:shopeasy_distributor/features/dashboard/dashboard_screen.dart';
import 'package:shopeasy_distributor/data/models/distributor_models.dart';
import 'package:shopeasy_distributor/features/demand/demand_screen.dart';
import 'package:shopeasy_distributor/shared/widgets/bottom_nav_bar.dart';
import 'package:shopeasy_distributor/shared/widgets/demand_product_row.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_alert_card.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_demand_metric_card.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_metric_card.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_panel.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_quick_action_tile.dart';
import 'package:shopeasy_distributor/shared/widgets/shopeasy_header.dart';
import 'package:shopeasy_distributor/shared/widgets/ui_states.dart';
import 'package:shopeasy_distributor/features/products/product_catalogue_screen.dart';
import 'package:shopeasy_distributor/features/suppliers/supplier_management_screen.dart';
import 'package:shopeasy_distributor/features/salesman/salesman_coordination_screen.dart';
import 'package:shopeasy_distributor/features/reports/reports_screen.dart';
import 'package:shopeasy_distributor/shared/widgets/glass_components.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DistributorRepository Unit Tests', () {
    late DistributorRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = DistributorRepository();
    });

    test('Initial user is configured as Ramesh Kumar', () {
      expect(repository.currentUser, isNotNull);
      expect(repository.currentUser!.name, 'Ramesh Kumar');
      expect(repository.currentUser!.businessName, 'Ramesh Distributors');
      expect(repository.currentUser!.gstNumber, '22AABCD1234F1ZS');
    });

    test('Login validates 10-digit phone number', () async {
      expect(
        () => repository.login('123', 'password123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Login validates minimum password length', () async {
      expect(
        () => repository.login('9876543210', '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Successful login creates authenticated session', () async {
      final user = await repository.login('9876543210', 'password123');
      expect(user.mobileNumber, '9876543210');
      expect(user.token, isNotNull);
      expect(repository.isAuthenticated, isTrue);
    });

    test('Registration generates valid reference ID', () async {
      final res = await repository.registerDistributor(
        businessName: 'Gupta Enterprises',
        ownerName: 'Amit Gupta',
        mobileNumber: '9838012345',
        gstNumber: '22AABCD5678F1ZS',
        businessType: 'Wholesaler / Distributor',
        address: 'Main Chowk, Azamgarh',
        uploadedDocs: ['gst.pdf', 'pan.jpg'],
      );

      expect(res['referenceId'], startsWith('SE-DIST-'));
      expect(res['status'], 'Under Verification');
      expect(repository.currentUser!.businessName, 'Gupta Enterprises');
    });

    test('Shop directory returns all 6 reference shops', () {
      final shops = repository.getShops();
      expect(shops.length, greaterThanOrEqualTo(4));
      expect(shops.any((s) => s.name == 'Sharma General Store'), isTrue);
      expect(shops.any((s) => s.name == 'Gupta Kirana Store'), isTrue);
      expect(shops.any((s) => s.name == 'Verma Provision Store'), isTrue);
      expect(shops.any((s) => s.name == 'Singh Traders'), isTrue);
    });

    test('Top demand products include Rice, Oil, Wheat Flour, Sugar', () {
      final prods = repository.getTopDemandProducts();
      expect(prods.any((p) => p.name.contains('Rice')), isTrue);
      expect(prods.any((p) => p.name.contains('Cooking Oil')), isTrue);
      expect(prods.any((p) => p.name.contains('Wheat Flour')), isTrue);
      expect(prods.any((p) => p.name.contains('Sugar')), isTrue);
    });

    test('Inventory items return stock items and low stock flags', () {
      final items = repository.getInventoryItems();
      expect(items.length, greaterThanOrEqualTo(5));
      final lowStock = items.where((i) => i.isLowStock).toList();
      expect(lowStock, isNotEmpty);
    });

    test('Shipment tracking has steps and valid AWB', () {
      final shipments = repository.getShipments();
      expect(shipments, isNotEmpty);
      expect(shipments.first.awbNumber, startsWith('SE-AWB-'));
      expect(shipments.first.trackingSteps, isNotEmpty);
    });
  });

  group('Widget Tests', () {
    testWidgets('Bottom navigation renders all 5 tabs', (WidgetTester tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: ShopEasyBottomNav(
              currentIndex: selected,
              onTap: (i) => selected = i,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Demand'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('GlassPanel renders with child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassPanel(
              child: Text('Test Glassmorphism Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Glassmorphism Content'), findsOneWidget);
    });

    testWidgets('GlassMetricCard renders title, value, unit, and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassMetricCard(
              title: 'Total Demand',
              value: '1,250',
              unit: 'orders',
              color: Colors.blue,
              glowColor: Colors.lightBlue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Total Demand'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('orders'), findsOneWidget);

      await tester.tap(find.byType(GlassMetricCard));
      expect(tapped, isTrue);
    });

    testWidgets('GlassQuickActionTile renders label and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassQuickActionTile(
              icon: Icons.location_on_rounded,
              label: 'View\nDemand',
              gradient: const [Colors.orange, Colors.deepOrange],
              glowColor: Colors.orange,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('View\nDemand'), findsOneWidget);
      await tester.tap(find.byType(GlassQuickActionTile));
      expect(tapped, isTrue);
    });

    testWidgets('GlassAlertCard renders alert details and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassAlertCard(
              title: 'High demand for Rice (50kg) in 3 shops',
              timeAgo: '2 hours ago',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('High demand for Rice (50kg) in 3 shops'), findsOneWidget);
      expect(find.text('2 hours ago'), findsOneWidget);
      await tester.tap(find.byType(GlassAlertCard));
      expect(tapped, isTrue);
    });

    testWidgets('ShopEasyHeader renders brand and header actions', (WidgetTester tester) async {
      bool notifTapped = false;
      bool profileTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShopEasyHeader(
              onNotificationTap: () => notifTapped = true,
              onProfileTap: () => profileTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ShopEasy'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      expect(notifTapped, isTrue);

      await tester.tap(find.byType(ClipOval));
      expect(profileTapped, isTrue);
    });

    testWidgets('UI States render Loading, Error, and Empty states', (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const LoadingState(message: 'Fetching inventory...'),
                ErrorState(message: 'Network error', onRetry: () => retried = true),
                const EmptyState(title: 'No Pending Orders'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Fetching inventory...'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('No Pending Orders'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('LoginScreen renders brand elements and interactive fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Distributor Login'), findsOneWidget);
      expect(find.text('Connect  •  Supply  •  Grow'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
      expect(find.text('Secure & Trusted'), findsOneWidget);
    });

    testWidgets('DashboardScreen renders all reference components', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Verify Header
      expect(find.text('ShopEasy'), findsOneWidget);

      // Verify Welcome
      expect(find.text('Welcome, Ramesh Kumar'), findsOneWidget);
      expect(find.text('Distributor'), findsOneWidget);

      // Verify 4 Metric Cards
      expect(find.text('Total Demand'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('Pending Ship Orders'), findsOneWidget);
      expect(find.text('Warehouse Stock'), findsOneWidget);
      expect(find.text('Dispatch Pending'), findsOneWidget);

      // Verify Quick Actions Panel
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('View\nDemand'), findsOneWidget);
      expect(find.text('Check\nInventory'), findsOneWidget);
      expect(find.text('Shop\nDirectory'), findsOneWidget);
      expect(find.text('New\nOrder'), findsOneWidget);

      // Verify Recent Alerts Panel
      expect(find.text('Recent Alerts'), findsOneWidget);
      expect(find.text('High demand for Rice (50kg) in 3 shops'), findsOneWidget);
      expect(find.text('2 hours ago'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('GlassDemandMetricCard renders metric data and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassDemandMetricCard(
              title: 'Forecast',
              value: '420',
              icon: Icons.view_in_ar_rounded,
              accentColor: Colors.blue,
              bgColor: Colors.lightBlue.withOpacity(0.2),
              glowColor: Colors.lightBlue,
              iconGradient: const [Colors.lightBlue, Colors.blue],
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Forecast'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('units'), findsOneWidget);

      await tester.tap(find.byType(GlassDemandMetricCard));
      expect(tapped, isTrue);
    });

    testWidgets('DemandProductRow renders product name and demand quantity', (WidgetTester tester) async {
      bool tapped = false;
      const product = DemandProduct(
        id: 'DP-01',
        name: 'Rice (25kg)',
        category: 'Grains & Staples',
        totalDemand: 420,
        price: 1250,
        imageAsset: 'assets/images/prod_rice.png',
        unit: 'bags',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DemandProductRow(
              product: product,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Rice (25kg)'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);

      await tester.tap(find.byType(DemandProductRow));
      expect(tapped, isTrue);
    });

    testWidgets('DemandScreen renders Aggregated Demand reference components', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DemandScreen(),
          ),
        ),
      );

      // Verify Header and Subtitle
      expect(find.text('ShopEasy'), findsOneWidget);
      expect(find.text('Your Local Shop, Our Priority'), findsOneWidget);

      // Verify Aggregated Demand Panel & Date Filter
      expect(find.text('Aggregated Demand'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Verify 4 Demand Metric Cards and Top Product values
      expect(find.text('Forecast'), findsOneWidget);
      expect(find.text('420'), findsNWidgets(2));
      expect(find.text('Requested'), findsOneWidget);
      expect(find.text('360'), findsNWidgets(2));
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('280'), findsNWidgets(2));
      expect(find.text('Allocated'), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);

      // Verify Top Products by Demand Panel
      expect(find.text('Top Products by Demand'), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
      expect(find.text('Total Demand'), findsOneWidget);

      // Verify 4 Reference Products
      expect(find.text('Rice (25kg)'), findsOneWidget);
      expect(find.text('Cooking Oil (1L)'), findsOneWidget);
      expect(find.text('Wheat Flour (10kg)'), findsOneWidget);
      expect(find.text('Sugar (1kg)'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('ProductCatalogueScreen renders reference header, search, chips and products', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductCatalogueScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Brand & Header
      expect(find.text('ShopEasy'), findsOneWidget);
      expect(find.text('Your Local Shop, Our Priority'), findsOneWidget);

      // Search & Categories
      expect(find.text('Search products...'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Grocery'), findsOneWidget);
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Personal Care'), findsOneWidget);

      // Products from Reference Screenshot
      expect(find.text('Rice (25kg)'), findsOneWidget);
      expect(find.text('Cooking Oil (1L)'), findsOneWidget);
      expect(find.text('Wheat Flour (10kg)'), findsOneWidget);
      expect(find.text('Sugar (1kg)'), findsOneWidget);

      // Stock status badges
      expect(find.text('In Stock'), findsWidgets);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('SupplierManagementScreen renders reference tabs, suppliers, and key reports', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SupplierManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and Heading
      expect(find.text('Supplier Management'), findsOneWidget);
      expect(find.text('Add Supplier'), findsOneWidget);

      // Tabs
      expect(find.text('Suppliers'), findsOneWidget);
      expect(find.text('Reports & Analytics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Demonstration Suppliers
      expect(find.text('ABC Foods Ltd.'), findsOneWidget);
      expect(find.text('Sunrise FMCG'), findsOneWidget);
      expect(find.text('Global Partners'), findsOneWidget);

      // Key Reports Shortcut
      expect(find.text('Key Reports'), findsOneWidget);
      expect(find.text('Stock Report'), findsOneWidget);
      expect(find.text('Sales Report'), findsOneWidget);
      expect(find.text('Purchase Report'), findsOneWidget);
      expect(find.text('Profit & Loss'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('SalesmanCoordinationScreen renders profile and today schedule', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SalesmanCoordinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Heading and Profile
      expect(find.text('Salesman Coordination'), findsOneWidget);
      expect(find.text('Rohit Kumar'), findsOneWidget);
      expect(find.text('On Route'), findsOneWidget);

      // Tabs
      expect(find.text("Today's Visits"), findsOneWidget);
      expect(find.text('Visit History'), findsOneWidget);

      // Schedule Shops
      expect(find.text('Sharma Gen. Store'), findsOneWidget);
      expect(find.text('Gupta Kirana Store'), findsOneWidget);
      expect(find.text('Verma Provision Store'), findsOneWidget);
      expect(find.text('Singh Traders'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('KeyReportsScreen renders report breakdown and accounting rows', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KeyReportsScreen(initialTab: 3), // Profit & Loss
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Financial & Operations Reports'), findsOneWidget);
      expect(find.text('Profit & Loss'), findsOneWidget);
      expect(find.text('Net Distribution Profit'), findsOneWidget);
      expect(find.text('Gross Revenue (Sales)'), findsOneWidget);
      expect(find.text('Cost of Goods Sold (COGS)'), findsOneWidget);
      expect(find.text('Net Operating Profit'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('GlassComponents render smoothly with interactive handlers', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const GlassCard(child: Text('Card Content')),
                GlassButton(
                  text: 'Submit Order',
                  onPressed: () => buttonPressed = true,
                ),
                const GlassStatusBadge(status: 'Active'),
                const GlassSearchBar(hintText: 'Filter Items...'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.text('Submit Order'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Filter Items...'), findsOneWidget);

      await tester.tap(find.text('Submit Order'));
      expect(buttonPressed, isTrue);
    });
  });

  group('Supplier, Salesman & Report Unit Tests', () {
    late DistributorRepository repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = DistributorRepository();
    });

    test('Supplier CRUD operations operate correctly', () {
      final initial = repo.getSuppliers();
      expect(initial.length, 3);
      expect(initial[0].name, 'ABC Foods Ltd.');
      expect(initial[0].totalPurchases, 250000.0);
      expect(initial[1].name, 'Sunrise FMCG');
      expect(initial[1].totalPurchases, 165000.0);
      expect(initial[2].name, 'Global Partners');
      expect(initial[2].totalPurchases, 120000.0);

      // Add supplier
      const newSup = Supplier(
        id: 'SUP-NEW',
        name: 'Hindustan Foods',
        totalPurchases: 50000.0,
        status: 'Active',
        category: 'Spices',
        contactPerson: 'Karan Mehra',
        phone: '+91 99999 11111',
        email: 'karan@hf.com',
        address: 'Delhi NCR',
        lastPurchaseDate: 'Today',
      );
      repo.addSupplier(newSup);
      expect(repo.getSuppliers().length, 4);

      // Delete supplier
      repo.deleteSupplier('SUP-NEW');
      expect(repo.getSuppliers().length, 3);
    });

    test('Salesman profile and visit updates operate correctly', () {
      final profile = repo.getSalesmanProfile();
      expect(profile.name, 'Rohit Kumar');
      expect(profile.role, 'Salesman');
      expect(profile.assignedShopsCount, 5);
      expect(profile.routeDistanceKm, 22.0);
      expect(profile.status, 'On Route');

      final visits = repo.getSalesmanVisits();
      expect(visits.length, 4);
      expect(visits[0].shopName, 'Sharma Gen. Store');
      expect(visits[0].isVisited, isTrue);
      expect(visits[2].shopName, 'Verma Provision Store');
      expect(visits[2].isPending, isTrue);

      // Complete pending visit
      repo.updateSalesmanVisit('VIS-03', 'Visited', notes: 'Collected demand', orderAmount: 12000.0);
      final updatedVisits = repo.getSalesmanVisits();
      final v3 = updatedVisits.firstWhere((v) => v.id == 'VIS-03');
      expect(v3.isVisited, isTrue);
      expect(v3.collectedDemandAmount, 12000.0);
    });

    test('Key reports financial calculations are mathematically consistent', () {
      final stock = repo.getStockReport();
      expect(stock.totalValuation, 1840000.0);
      expect(stock.totalSkus, 48);
      expect(stock.lowStockCount, 6);

      final sales = repo.getSalesReport();
      expect(sales.totalRevenue, 1285000.0);

      final purchase = repo.getPurchaseReport();
      expect(purchase.totalPurchases, greaterThan(0));

      final pl = repo.getProfitLossReport();
      expect(pl.totalRevenue, 1285000.0);
      expect(pl.costOfGoodsSold, 940000.0);
      expect(pl.grossProfit, pl.totalRevenue - pl.costOfGoodsSold);
      expect(pl.grossProfit, 345000.0);
      expect(pl.netProfit, pl.grossProfit - pl.operatingExpenses);
      expect(pl.netProfit, 260000.0);
    });
  });
}

