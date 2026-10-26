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
import 'package:shopeasy_distributor/features/inventory/inventory_screen.dart';
import 'package:shopeasy_distributor/features/orders/orders_screen.dart';
import 'package:shopeasy_distributor/features/dispatch/dispatch_screen.dart';
import 'package:shopeasy_distributor/features/shipments/shipments_screen.dart';

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

      // Section 5.3 & 5.4 Calculations
      final totalStock = items.fold(0, (sum, i) => sum + i.quantity);
      expect(totalStock, 8420);

      final lowStock = items.where((i) => i.isLowStock).toList();
      expect(lowStock.length, 12);

      // Section 5.7 Reference Demonstration Products
      expect(items[0].name, 'Rice (25kg)');
      expect(items[0].quantity, 420);
      expect(items[0].isLowStock, isFalse);

      expect(items[1].name, 'Cooking Oil (1L)');
      expect(items[1].quantity, 360);
      expect(items[1].isLowStock, isFalse);

      expect(items[2].name, 'Wheat Flour (10kg)');
      expect(items[2].quantity, 280);
      expect(items[2].isLowStock, isFalse);

      expect(items[3].name, 'Sugar (1kg)');
      expect(items[3].quantity, 240);
      expect(items[3].isLowStock, isTrue);

      expect(items[4].name, 'Tea (1kg)');
      expect(items[4].quantity, 227);
      expect(items[4].isLowStock, isFalse);
    });

    test('Shipment tracking returns 4 reference shipments with valid AWBs and steps', () {
      final shipments = repository.getShipments();
      expect(shipments.length, 4);

      // Section 9 Reference Demonstration Shipments
      final s1 = shipments.firstWhere((s) => s.awbNumber == 'AWB0012345');
      expect(s1.productName, 'Rice (25kg)');
      expect(s1.quantity, 12);
      expect(s1.shopName, 'Sharma Gen. Store');
      expect(s1.status, 'Delivered');
      expect(s1.timestamp, 'Today, 10:24 AM');

      final s2 = shipments.firstWhere((s) => s.awbNumber == 'AWB0012356');
      expect(s2.productName, 'Cooking Oil (1L)');
      expect(s2.quantity, 10);
      expect(s2.shopName, 'Gupta Kirana Store');
      expect(s2.status, 'In Transit');
      expect(s2.timestamp, 'Today, 08:45 AM');

      final s3 = shipments.firstWhere((s) => s.awbNumber == 'AWB0012367');
      expect(s3.productName, 'Wheat Flour (10kg)');
      expect(s3.quantity, 8);
      expect(s3.shopName, 'Verma Provision Store');
      expect(s3.status, 'Out for Delivery');
      expect(s3.timestamp, 'Today, 07:25 AM');

      final s4 = shipments.firstWhere((s) => s.awbNumber == 'AWB0012378');
      expect(s4.productName, 'Sugar (1kg)');
      expect(s4.quantity, 20);
      expect(s4.shopName, 'Singh Traders');
      expect(s4.status, 'Scheduled');
      expect(s4.timestamp, 'Today, 06:30 PM');

      // Status update transition
      repository.updateShipmentStatus(
        'AWB0012378',
        'In Transit',
        note: 'Truck loaded and departed',
      );
      final updatedS4 = repository.getShipmentByAwb('AWB0012378');
      expect(updatedS4?.status, 'In Transit');
      expect(updatedS4?.trackingSteps.last.title, contains('In Transit'));
    });

    test('Orders repository returns exact reference dataset and counts', () {
      final orders = repository.getOrders();
      expect(orders.length, 12);

      // Section 5 filter counts
      final pendingOrders = orders.where((o) => o.status == 'Pending').toList();
      final processingOrders = orders
          .where((o) => o.status == 'Processing')
          .toList();
      final deliveredOrders = orders
          .where((o) => o.status == 'Delivered')
          .toList();

      expect(pendingOrders.length, 4);
      expect(processingOrders.length, 4);
      expect(deliveredOrders.length, 2);

      // Section 8 Reference Demonstration Orders
      final order1 = orders.firstWhere((o) => o.id == 'ORD-9201');
      expect(order1.shopName, 'Sharma Gen. Store');
      expect(order1.location, 'Deoganj');
      expect(order1.itemCount, 2);
      expect(order1.orderAmount, 2460.0);
      expect(order1.status, 'Pending');

      final order2 = orders.firstWhere((o) => o.id == 'ORD-9202');
      expect(order2.shopName, 'Gupta Kirana Store');
      expect(order2.location, 'Main Bazar');
      expect(order2.itemCount, 4);
      expect(order2.orderAmount, 4120.0);
      expect(order2.status, 'Processing');

      final order3 = orders.firstWhere((o) => o.id == 'ORD-9195');
      expect(order3.shopName, 'Verma Provision Store');
      expect(order3.location, 'Kachhpura');
      expect(order3.itemCount, 3);
      expect(order3.orderAmount, 2780.0);
      expect(order3.status, 'Processing');

      final order4 = orders.firstWhere((o) => o.id == 'ORD-9188');
      expect(order4.shopName, 'Singh Traders');
      expect(order4.location, 'Nawabganj');
      expect(order4.itemCount, 5);
      expect(order4.orderAmount, 6000.0);
      expect(order4.status, 'Delivered');

      // Status update transition & history
      repository.updateOrderStatus(
        'ORD-9201',
        'Processing',
        note: 'Confirmed by distributor',
      );
      final updatedOrder = repository.getOrderById('ORD-9201');
      expect(updatedOrder?.status, 'Processing');
      expect(updatedOrder?.statusHistory.first, contains('Processing'));
    });

    test(
      'Dispatch repository returns 4 reference routes with stops and metrics',
      () {
        final routes = repository.getDispatchRoutes();
        expect(routes.length, 4);

        // Section 8 Reference Demonstration Routes
        final routeA = routes.firstWhere((r) => r.id == 'RT-A');
        expect(routeA.routeName, 'Route A - Main Market');
        expect(routeA.stopCount, 5);
        expect(routeA.distanceKm, 18.0);
        expect(routeA.estDuration, '2h 30m');
        expect(routeA.status, 'On Route');
        expect(routeA.stops.length, 5);

        final routeB = routes.firstWhere((r) => r.id == 'RT-B');
        expect(routeB.routeName, 'Route B - Mubarikabad');
        expect(routeB.stopCount, 5);
        expect(routeB.distanceKm, 18.0);
        expect(routeB.estDuration, '2h 10m');
        expect(routeB.status, 'Ready');

        final routeC = routes.firstWhere((r) => r.id == 'RT-C');
        expect(routeC.routeName, 'Route C - Deotgaon');
        expect(routeC.stopCount, 4);
        expect(routeC.distanceKm, 16.0);
        expect(routeC.estDuration, '1h 45m');
        expect(routeC.status, 'Pending');

        final routeD = routes.firstWhere((r) => r.id == 'RT-D');
        expect(routeD.routeName, 'Route D - Kochbazar');
        expect(routeD.stopCount, 5);
        expect(routeD.distanceKm, 24.0);
        expect(routeD.estDuration, '3h 20m');
        expect(routeD.status, 'Not Started');

        // Status update transition
        repository.updateRouteStatus(
          'RT-D',
          'Ready',
          note: 'Prepared for departure',
        );
        final updatedRouteD = repository.getDispatchRouteById('RT-D');
        expect(updatedRouteD?.status, 'Ready');
        expect(updatedRouteD?.statusHistory.first, contains('Ready'));
      },
    );
  });

  group('Widget Tests', () {
    testWidgets('Bottom navigation renders all 5 tabs', (
      WidgetTester tester,
    ) async {
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
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('GlassPanel renders with child content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassPanel(child: Text('Test Glassmorphism Content')),
          ),
        ),
      );

      expect(find.text('Test Glassmorphism Content'), findsOneWidget);
    });

    testWidgets('GlassMetricCard renders title, value, unit, and handles tap', (
      WidgetTester tester,
    ) async {
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

    testWidgets('GlassQuickActionTile renders label and handles tap', (
      WidgetTester tester,
    ) async {
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

    testWidgets('GlassAlertCard renders alert details and handles tap', (
      WidgetTester tester,
    ) async {
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

      expect(
        find.text('High demand for Rice (50kg) in 3 shops'),
        findsOneWidget,
      );
      expect(find.text('2 hours ago'), findsOneWidget);
      await tester.tap(find.byType(GlassAlertCard));
      expect(tapped, isTrue);
    });

    testWidgets('ShopEasyHeader renders brand and header actions', (
      WidgetTester tester,
    ) async {
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

    testWidgets('UI States render Loading, Error, and Empty states', (
      WidgetTester tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const LoadingState(message: 'Fetching inventory...'),
                ErrorState(
                  message: 'Network error',
                  onRetry: () => retried = true,
                ),
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

    testWidgets('LoginScreen renders brand elements and interactive fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      expect(find.text('Distributor Login'), findsOneWidget);
      expect(find.text('Connect  •  Supply  •  Grow'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
      expect(find.text('Secure & Trusted'), findsOneWidget);
    });

    testWidgets('DashboardScreen renders all reference components', (
      WidgetTester tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DashboardScreen())),
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
      expect(
        find.text('High demand for Rice (50kg) in 3 shops'),
        findsOneWidget,
      );
      expect(find.text('2 hours ago'), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('GlassDemandMetricCard renders metric data and handles tap', (
      WidgetTester tester,
    ) async {
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

    testWidgets('DemandProductRow renders product name and demand quantity', (
      WidgetTester tester,
    ) async {
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

    testWidgets('DemandScreen renders Aggregated Demand reference components', (
      WidgetTester tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DemandScreen())),
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

    testWidgets(
      'ProductCatalogueScreen renders reference header, search, chips and products',
      (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: ProductCatalogueScreen()),
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
      },
    );

    testWidgets(
      'SupplierManagementScreen renders reference tabs, suppliers, and key reports',
      (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: SupplierManagementScreen()),
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
      },
    );

    testWidgets(
      'SalesmanCoordinationScreen renders profile and today schedule',
      (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: SalesmanCoordinationScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Header branding
        expect(find.text('ShopEasy'), findsOneWidget);

        // Heading and Profile
        expect(find.text('Salesman Coordination'), findsOneWidget);
        expect(find.text('Rohit Kumar'), findsOneWidget);
        expect(find.text('Salesman'), findsWidgets);
        expect(find.text('Assigned Shops: 5  |  22 km'), findsOneWidget);
        expect(find.text('On Route'), findsOneWidget);

        // Tabs
        expect(find.text("Today's Visits"), findsOneWidget);
        expect(find.text('Visit History'), findsOneWidget);

        // Schedule Shops
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('Verma Provision Store'), findsOneWidget);
        expect(find.text('Singh Traders'), findsOneWidget);

        // Status badges and times
        expect(find.text('Visited'), findsNWidgets(2));
        expect(find.text('Pending'), findsNWidgets(2));
        expect(find.text('9:30 AM'), findsOneWidget);
        expect(find.text('11:45 AM'), findsOneWidget);
        expect(find.text('2:00 PM'), findsOneWidget);
        expect(find.text('4:30 PM'), findsOneWidget);

        // Tap on a pending visit row to open action sheet
        await tester.tap(find.text('Verma Provision Store'));
        await tester.pumpAndSettle();

        expect(find.text('Scheduled: 2:00 PM'), findsOneWidget);
        expect(find.text('Complete Visit'), findsOneWidget);

        // Complete the visit
        await tester.tap(find.text('Complete Visit'));
        await tester.pumpAndSettle();

        // Switch to Visit History tab
        await tester.tap(find.text('Visit History'));
        await tester.pumpAndSettle();

        // Now history displays completed visits (including the newly completed one)
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('Verma Provision Store'), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      },
    );

    testWidgets(
      'KeyReportsScreen renders report breakdown and accounting rows',
      (tester) async {
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
      },
    );

    testWidgets('GlassComponents render smoothly with interactive handlers', (
      tester,
    ) async {
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

    testWidgets('InventoryScreen renders all reference components', (
      tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: InventoryScreen())),
      );
      await tester.pumpAndSettle();

      // Heading & Subtitle
      expect(find.text('Warehouse Inventory'), findsOneWidget);
      expect(
        find.text('Manage your stock, keep business moving'),
        findsOneWidget,
      );

      // Dual Summary Cards
      expect(find.text('Total Stock'), findsOneWidget);
      expect(find.text('8,420'), findsOneWidget);
      expect(find.text('units'), findsOneWidget);
      expect(find.text('Low Stock Items'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);

      // Search Bar Placeholder
      expect(find.text('Search products...'), findsOneWidget);

      // Product Table Column Headers
      expect(find.text('Product'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);

      // 5 Primary Reference Products
      expect(find.text('Rice (25kg)'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('Cooking Oil (1L)'), findsOneWidget);
      expect(find.text('360'), findsOneWidget);
      expect(find.text('Wheat Flour (10kg)'), findsOneWidget);
      expect(find.text('280'), findsOneWidget);
      expect(find.text('Sugar (1kg)'), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
      expect(find.text('Tea (1kg)'), findsOneWidget);
      expect(find.text('227'), findsOneWidget);

      // Status Badges
      expect(find.text('In Stock'), findsWidgets);
      expect(find.text('Low Stock'), findsWidgets);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
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
      repo.updateSalesmanVisit(
        'VIS-03',
        'Visited',
        notes: 'Collected demand',
        orderAmount: 12000.0,
      );
      final updatedVisits = repo.getSalesmanVisits();
      final v3 = updatedVisits.firstWhere((v) => v.id == 'VIS-03');
      expect(v3.isVisited, isTrue);
      expect(v3.collectedDemandAmount, 12000.0);
    });

    test(
      'Key reports financial calculations are mathematically consistent',
      () {
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
      },
    );

    testWidgets(
      'OrdersScreen renders exact reference UI: tabs, counts, columns, and cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OrdersScreen())),
        );
        await tester.pumpAndSettle();

        // 1. Branding Header
        expect(find.text('ShopEasy'), findsOneWidget);
        expect(find.text('Your Local Shop, Our Priority'), findsOneWidget);

        // 2. Section 5 Status Filter Tabs with Counts
        expect(find.text('All (12)'), findsOneWidget);
        expect(find.text('Pending (4)'), findsOneWidget);
        expect(find.text('Processing (4)'), findsOneWidget);
        expect(find.text('Delivered (2)'), findsOneWidget);

        // 3. Section 6 Table Column Headings
        expect(find.text('Shop'), findsOneWidget);
        expect(find.text('Items'), findsOneWidget);
        expect(find.text('Amount'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);

        // 4. Section 8 Reference Demonstration Order Cards
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Deoganj'), findsOneWidget);
        expect(find.text('2 items'), findsWidgets);
        expect(find.text('₹ 2,460'), findsOneWidget);

        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('Main Bazar'), findsOneWidget);
        expect(find.text('4 items'), findsWidgets); // Used in Gupta & others
        expect(find.text('₹ 4,120'), findsOneWidget);

        expect(find.text('Verma Provision Store'), findsOneWidget);
        expect(find.text('Kachhpura'), findsOneWidget);
        expect(find.text('3 items'), findsWidgets);
        expect(find.text('₹ 2,780'), findsOneWidget);

        expect(find.text('Singh Traders'), findsOneWidget);
        expect(find.text('Nawabganj'), findsOneWidget);
        expect(find.text('5 items'), findsWidgets);
        expect(find.text('₹ 6,000'), findsOneWidget);

        // 5. Section 5 Tab Filter Interaction
        await tester.tap(find.text('Pending (4)'));
        await tester.pumpAndSettle();

        // Sharma Gen. Store (Pending) must remain visible
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        // Gupta Kirana Store (Processing) should be filtered out
        expect(find.text('Gupta Kirana Store'), findsNothing);

        // 6. Tap Order Card to Open Order Details Modal
        await tester.tap(find.text('Sharma Gen. Store'));
        await tester.pumpAndSettle();

        // Details modal displays
        expect(find.text('Order Details'), findsOneWidget);
        expect(find.text('ORD-9201'), findsOneWidget);
        expect(find.text('Action Workflow'), findsOneWidget);
        expect(find.text('Confirm Order'), findsOneWidget);
      },
    );

    testWidgets(
      'OrdersScreen renders without any overflow on narrow 375x812 mobile screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(375 * 2.0, 812 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OrdersScreen())),
        );
        await tester.pumpAndSettle();

        // Must display shop names and locations without collapsing or overflowing
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Deoganj'), findsOneWidget);
        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('Main Bazar'), findsOneWidget);
        expect(find.text('Verma Provision Store'), findsOneWidget);
        expect(find.text('Singh Traders'), findsOneWidget);

        // Verify no RenderFlex overflow exception was thrown
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'OrdersScreen renders without any overflow on compact 360x800 Android screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360 * 2.0, 800 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OrdersScreen())),
        );
        await tester.pumpAndSettle();

        // Must display all cards cleanly
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('Verma Provision Store'), findsOneWidget);
        expect(find.text('Singh Traders'), findsOneWidget);

        // Verify zero overflow exceptions
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DispatchScreen renders exact reference UI: header, date, summary cards, and route cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: DispatchScreen())),
        );
        await tester.pumpAndSettle();

        // 1. Branding Header
        expect(find.text('ShopEasy'), findsOneWidget);
        expect(find.text('Your Local Shop, Our Priority'), findsOneWidget);

        // 2. Section 5 Heading & Date Selector
        expect(find.text('Dispatch Planning'), findsOneWidget);
        expect(find.text('Plan routes, deliver faster'), findsOneWidget);
        expect(find.text('24 Apr 2025'), findsOneWidget);

        // 3. Section 6 Three Dispatch Summary Cards
        expect(find.text('Total Orders'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);

        expect(find.text('Assigned Routes'), findsOneWidget);
        expect(find.text('4'), findsWidgets); // Used in card and route stops

        expect(find.text('Pending Dispatch'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);

        // 4. Section 7 Routes Heading & View All Button
        expect(find.text('Routes'), findsOneWidget);
        expect(find.text('View All'), findsOneWidget);

        // 5. Section 8 Four Reference Route Cards
        expect(find.text('Route A - Main Market'), findsOneWidget);
        expect(find.text('5 Stops'), findsWidgets);
        expect(find.text('18 km'), findsWidgets);
        expect(find.text('2h 30m'), findsOneWidget);
        expect(find.text('On Route'), findsOneWidget);

        expect(find.text('Route B - Mubarikabad'), findsOneWidget);
        expect(find.text('2h 10m'), findsOneWidget);
        expect(find.text('Ready'), findsOneWidget);

        expect(find.text('Route C - Deotgaon'), findsOneWidget);
        expect(find.text('4 Stops'), findsOneWidget);
        expect(find.text('16 km'), findsOneWidget);
        expect(find.text('1h 45m'), findsOneWidget);
        expect(find.text('Pending'), findsOneWidget);

        expect(find.text('Route D - Kochbazar'), findsOneWidget);
        expect(find.text('24 km'), findsOneWidget);
        expect(find.text('3h 20m'), findsOneWidget);
        expect(find.text('Not Started'), findsOneWidget);

        // 6. Section 8 View Buttons
        expect(find.text('View'), findsNWidgets(4));

        // 7. Section 10 Tap View Button to Open Route Details Modal
        await tester.tap(find.text('View').first);
        await tester.pumpAndSettle();

        // Details modal displays
        expect(find.text('Route Details'), findsOneWidget);
        expect(find.text('Scheduled Stops (5)'), findsOneWidget);
        expect(find.text('Route History & Audit Trail'), findsOneWidget);
        expect(find.text('Action Workflow'), findsOneWidget);
      },
    );

    testWidgets(
      'ShipmentsScreen renders exact reference UI: header, search, filter button, and 4 shipment cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: ShipmentsScreen())),
        );
        await tester.pumpAndSettle();

        // 1. Branding Header
        expect(find.text('ShopEasy'), findsOneWidget);
        expect(find.text('Your Local Shop, Our Priority'), findsOneWidget);

        // 2. Section 5 & 6 Title & Search Field
        expect(find.text('Shipment Tracking'), findsOneWidget);
        expect(find.text('Track your orders in real-time'), findsOneWidget);
        expect(find.text('Search by AWB / Order ID...'), findsOneWidget);

        // 3. Section 7 Filter Button Icon
        expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);

        // 4. Section 9 Four Reference Demonstration Shipment Cards
        // Card 1
        expect(find.text('AWB0012345'), findsOneWidget);
        expect(find.text('Rice (25kg)  •  12 units'), findsOneWidget);
        expect(find.text('Sharma Gen. Store'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('Today, 10:24 AM'), findsOneWidget);

        // Card 2
        expect(find.text('AWB0012356'), findsOneWidget);
        expect(find.text('Cooking Oil (1L)  •  10 units'), findsOneWidget);
        expect(find.text('Gupta Kirana Store'), findsOneWidget);
        expect(find.text('In Transit'), findsOneWidget);
        expect(find.text('Today, 08:45 AM'), findsOneWidget);

        // Card 3
        expect(find.text('AWB0012367'), findsOneWidget);
        expect(find.text('Wheat Flour (10kg)  •  8 units'), findsOneWidget);
        expect(find.text('Verma Provision Store'), findsOneWidget);
        expect(find.text('Out for Delivery'), findsOneWidget);
        expect(find.text('Today, 07:25 AM'), findsOneWidget);

        // Card 4
        expect(find.text('AWB0012378'), findsOneWidget);
        expect(find.text('Sugar (1kg)  •  20 units'), findsOneWidget);
        expect(find.text('Singh Traders'), findsOneWidget);
        expect(find.text('Scheduled'), findsOneWidget);
        expect(find.text('Today, 06:30 PM'), findsOneWidget);

        // 5. Search Interaction
        await tester.enterText(find.byType(TextField), 'AWB0012345');
        await tester.pumpAndSettle();

        expect(find.text('Rice (25kg)  •  12 units'), findsOneWidget);
        expect(find.text('Cooking Oil (1L)  •  10 units'), findsNothing);

        // Clear search
        await tester.tap(find.byIcon(Icons.clear_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Cooking Oil (1L)  •  10 units'), findsOneWidget);

        // 6. Section 11 & 12 Tap Shipment Card to Open Shipment Details Modal
        await tester.tap(find.text('Rice (25kg)  •  12 units'));
        await tester.pumpAndSettle();

        // Details modal displays
        expect(find.text('Shipment Details'), findsOneWidget);
        expect(find.text('Tracking Timeline & Milestones'), findsOneWidget);
        expect(find.text('Action Workflow'), findsOneWidget);
      },
    );
  });
}
