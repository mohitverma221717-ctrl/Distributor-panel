import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/distributor_models.dart';

class DistributorRepository {
  static const String _userKey = 'shopeasy_current_user';
  static const String _tokenKey = 'shopeasy_auth_token';

  DistributorUser? _currentUser;

  DistributorRepository() {
    _initDefaultUser();
  }

  void _initDefaultUser() {
    _currentUser = const DistributorUser(
      id: 'D-9912',
      name: 'Ramesh Kumar',
      businessName: 'Ramesh Distributors',
      mobileNumber: '9876543210',
      gstNumber: '22AABCD1234F1ZS',
      businessType: 'Wholesaler / Distributor',
      address: '123 Market Road, Civil Lines, Azamgarh, UP - 276001',
      status: 'Approved',
      token: null,
    );
  }

  Future<void> loadPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = DistributorUser.fromJson(map);
      } catch (_) {
        _initDefaultUser();
      }
    }
  }

  DistributorUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!.token != null;

  Future<DistributorUser> login(String mobileNumber, String password) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 650));

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (mobileNumber.length != 10) {
      throw Exception('Please enter a valid 10-digit mobile number');
    }

    // Authenticate user
    final user = DistributorUser(
      id: 'D-9912',
      name: 'Ramesh Kumar',
      businessName: 'Ramesh Distributors',
      mobileNumber: mobileNumber,
      gstNumber: '22AABCD1234F1ZS',
      businessType: 'Wholesaler / Distributor',
      address: '123 Market Road, Civil Lines, Azamgarh, UP - 276001',
      status: 'Approved',
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, user.token!);

    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> registerDistributor({
    required String businessName,
    required String ownerName,
    required String mobileNumber,
    required String gstNumber,
    required String businessType,
    required String address,
    required List<String> uploadedDocs,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final refId = 'SE-DIST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newUser = DistributorUser(
      id: refId,
      name: ownerName,
      businessName: businessName,
      mobileNumber: mobileNumber,
      gstNumber: gstNumber.isNotEmpty ? gstNumber : 'PENDING_VERIFICATION',
      businessType: businessType,
      address: address,
      status: 'Pending Verification',
      token: 'token_reg_$refId',
    );

    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(newUser.toJson()));
    await prefs.setString(_tokenKey, newUser.token!);

    return {
      'referenceId': refId,
      'status': 'Under Verification',
      'message': 'Registration application submitted successfully. Our field inspection team will verify your documents within 24-48 hours.',
      'user': newUser,
    };
  }

  Future<bool> sendPasswordResetOtp(String mobileNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mobileNumber.length != 10) {
      throw Exception('Enter a valid 10-digit mobile number');
    }
    return true;
  }

  Future<bool> verifyOtpAndResetPassword(String mobile, String otp, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp != '1234' && otp != '123456') {
      throw Exception('Invalid OTP. Please enter 1234');
    }
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    return true;
  }

  // --- Mock Database for Core Entities matching Screenshots ---

  List<Shop> getShops() {
    return [
      const Shop(
        id: 'SH-01',
        name: 'Sharma General Store',
        initial: 'S',
        area: 'Deoiganj',
        distanceKm: 2.6,
        pendingOrders: 3,
        totalOrders: 12,
        isActive: true,
        phone: '+91 94150 12345',
        address: 'Plot 4, Main Chowk, Deoiganj, Azamgarh',
        ownerName: 'Madan Sharma',
        topDemand: 'Rice (25kg), Mustard Oil',
      ),
      const Shop(
        id: 'SH-02',
        name: 'Gupta Kirana Store',
        initial: 'G',
        area: 'Main Bazar',
        distanceKm: 3.1,
        pendingOrders: 5,
        totalOrders: 18,
        isActive: true,
        phone: '+91 98380 54321',
        address: 'Shop 12, Clock Tower, Main Bazar, Azamgarh',
        ownerName: 'Sanjay Gupta',
        topDemand: 'Cooking Oil (1L), Sugar (1kg)',
      ),
      const Shop(
        id: 'SH-03',
        name: 'Verma Provision Store',
        initial: 'V',
        area: 'Kachhpura',
        distanceKm: 4.2,
        pendingOrders: 2,
        totalOrders: 9,
        isActive: true,
        phone: '+91 91290 98765',
        address: 'Near Old Post Office, Kachhpura, Azamgarh',
        ownerName: 'Sunil Verma',
        topDemand: 'Wheat Flour (10kg)',
      ),
      const Shop(
        id: 'SH-04',
        name: 'Singh Traders',
        initial: 'S',
        area: 'Nawabganj',
        distanceKm: 5.0,
        pendingOrders: 4,
        totalOrders: 15,
        isActive: true,
        phone: '+91 94500 67890',
        address: 'Station Road, Nawabganj, Azamgarh',
        ownerName: 'Raghav Singh',
        topDemand: 'Pulses, Spices Packets',
      ),
      const Shop(
        id: 'SH-05',
        name: 'Anand Super Market',
        initial: 'A',
        area: 'Civil Lines',
        distanceKm: 1.8,
        pendingOrders: 1,
        totalOrders: 22,
        isActive: true,
        phone: '+91 97920 11223',
        address: 'Collectorate Gate No 2, Civil Lines',
        ownerName: 'Anand Mishra',
        topDemand: 'Packaged Atta, Pure Ghee',
      ),
      const Shop(
        id: 'SH-06',
        name: 'Bharat Daily Mart',
        initial: 'B',
        area: 'Ailwal',
        distanceKm: 3.8,
        pendingOrders: 6,
        totalOrders: 27,
        isActive: true,
        phone: '+91 98890 33445',
        address: 'Bada Pul Road, Ailwal',
        ownerName: 'Rajesh Bharat',
        topDemand: 'Basmati Rice, Soyabean Oil',
      ),
    ];
  }

  List<DemandProduct> getTopDemandProducts() {
    return [
      const DemandProduct(
        id: 'DP-01',
        name: 'Rice (25kg)',
        category: 'Grocery',
        totalDemand: 420,
        price: 1250,
        imageAsset: 'assets/images/prod_rice.png',
        unit: 'bags',
      ),
      const DemandProduct(
        id: 'DP-02',
        name: 'Cooking Oil (1L)',
        category: 'Grocery',
        totalDemand: 360,
        price: 160,
        imageAsset: 'assets/images/prod_oil.png',
        unit: 'bottles',
      ),
      const DemandProduct(
        id: 'DP-03',
        name: 'Wheat Flour (10kg)',
        category: 'Grocery',
        totalDemand: 280,
        price: 280,
        imageAsset: 'assets/images/prod_flour.png',
        unit: 'packs',
      ),
      const DemandProduct(
        id: 'DP-04',
        name: 'Sugar (1kg)',
        category: 'Grocery',
        totalDemand: 500,
        price: 45,
        imageAsset: 'assets/images/prod_sugar.png',
        unit: 'packets',
      ),
      const DemandProduct(
        id: 'DP-05',
        name: 'Detergent Powder (1kg)',
        category: 'Household',
        totalDemand: 310,
        price: 130,
        unit: 'packs',
      ),
      const DemandProduct(
        id: 'DP-06',
        name: 'Dishwash Gel (500ml)',
        category: 'Household',
        totalDemand: 220,
        price: 95,
        unit: 'bottles',
      ),
      const DemandProduct(
        id: 'DP-07',
        name: 'Bathing Soap (Pack of 4)',
        category: 'Personal Care',
        totalDemand: 410,
        price: 145,
        unit: 'packs',
      ),
      const DemandProduct(
        id: 'DP-08',
        name: 'Herbal Shampoo (340ml)',
        category: 'Personal Care',
        totalDemand: 180,
        price: 210,
        unit: 'bottles',
      ),
    ];
  }

  List<InventoryItem> getInventoryItems() {
    return [
      const InventoryItem(
        id: 'INV-01',
        name: 'Rice (25kg Bag - Premium Kolam)',
        category: 'Grains',
        quantity: 2450,
        unit: 'bags',
        lowStockThreshold: 500,
        pricePerUnit: 1250.0,
      ),
      const InventoryItem(
        id: 'INV-02',
        name: 'Cooking Oil (1L Fortune Refined)',
        category: 'Oils',
        quantity: 1820,
        unit: 'bottles',
        lowStockThreshold: 400,
        pricePerUnit: 140.0,
      ),
      const InventoryItem(
        id: 'INV-03',
        name: 'Wheat Flour (10kg Aashirvaad Atta)',
        category: 'Flour',
        quantity: 1640,
        unit: 'packs',
        lowStockThreshold: 300,
        pricePerUnit: 380.0,
      ),
      const InventoryItem(
        id: 'INV-04',
        name: 'Refined White Sugar (1kg Packet)',
        category: 'Sweeteners',
        quantity: 1280,
        unit: 'packets',
        lowStockThreshold: 250,
        pricePerUnit: 44.0,
      ),
      const InventoryItem(
        id: 'INV-05',
        name: 'Toor Dal Premium (5kg Pack)',
        category: 'Pulses',
        quantity: 750,
        unit: 'bags',
        lowStockThreshold: 200,
        pricePerUnit: 680.0,
      ),
      const InventoryItem(
        id: 'INV-06',
        name: 'Tata Salt Vacuum Evaporated (1kg)',
        category: 'Salt & Spices',
        quantity: 360,
        unit: 'packets',
        lowStockThreshold: 400, // Low stock indicator
        pricePerUnit: 28.0,
      ),
      const InventoryItem(
        id: 'INV-07',
        name: 'Red Chilli Powder (500g Everest)',
        category: 'Salt & Spices',
        quantity: 120,
        unit: 'packs',
        lowStockThreshold: 200, // Low stock indicator
        pricePerUnit: 145.0,
      ),
    ];
  }

  List<DistributorOrder> getOrders() {
    return [
      DistributorOrder(
        id: 'ORD-9201',
        shopId: 'SH-01',
        shopName: 'Sharma General Store',
        itemCount: 4,
        orderAmount: 8450.0,
        status: 'Pending',
        date: DateTime.now().subtract(const Duration(minutes: 45)),
        items: const [
          OrderItem(productName: 'Rice (25kg)', quantity: 5, price: 1250),
          OrderItem(productName: 'Cooking Oil (1L)', quantity: 15, price: 140),
        ],
      ),
      DistributorOrder(
        id: 'ORD-9202',
        shopId: 'SH-02',
        shopName: 'Gupta Kirana Store',
        itemCount: 6,
        orderAmount: 14200.0,
        status: 'Pending',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        items: const [
          OrderItem(productName: 'Wheat Flour (10kg)', quantity: 20, price: 380),
          OrderItem(productName: 'Sugar (1kg)', quantity: 150, price: 44),
        ],
      ),
      DistributorOrder(
        id: 'ORD-9195',
        shopId: 'SH-03',
        shopName: 'Verma Provision Store',
        itemCount: 3,
        orderAmount: 6800.0,
        status: 'Processing',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        items: const [
          OrderItem(productName: 'Toor Dal (5kg)', quantity: 10, price: 680),
        ],
      ),
      DistributorOrder(
        id: 'ORD-9188',
        shopId: 'SH-04',
        shopName: 'Singh Traders',
        itemCount: 8,
        orderAmount: 22650.0,
        status: 'Delivered',
        date: DateTime.now().subtract(const Duration(days: 1)),
        items: const [
          OrderItem(productName: 'Rice (25kg)', quantity: 12, price: 1250),
          OrderItem(productName: 'Cooking Oil (1L)', quantity: 40, price: 140),
          OrderItem(productName: 'Sugar (1kg)', quantity: 50, price: 44),
        ],
      ),
    ];
  }

  List<DispatchRoute> getDispatchRoutes() {
    return const [
      DispatchRoute(
        id: 'RT-A',
        routeName: 'Route A — North Azamgarh',
        assignedDriver: 'Manoj Yadav',
        driverPhone: '+91 94151 77889',
        stopCount: 6,
        distanceKm: 14.5,
        estDuration: '1 hr 45 min',
        status: 'Ready',
        shopNames: ['Sharma General Store', 'Bharat Daily Mart', 'Kisan Seva Kendra'],
      ),
      DispatchRoute(
        id: 'RT-B',
        routeName: 'Route B — Main Bazar & Civil Lines',
        assignedDriver: 'Suresh Verma',
        driverPhone: '+91 98390 44556',
        stopCount: 8,
        distanceKm: 11.2,
        estDuration: '2 hr 10 min',
        status: 'In Transit',
        shopNames: ['Gupta Kirana Store', 'Anand Super Market', 'Verma Provision Store'],
      ),
      DispatchRoute(
        id: 'RT-C',
        routeName: 'Route C — Southern Bypass & Nawabganj',
        assignedDriver: 'Amit Kumar',
        driverPhone: '+91 91290 88990',
        stopCount: 4,
        distanceKm: 19.8,
        estDuration: '1 hr 30 min',
        status: 'Ready',
        shopNames: ['Singh Traders', 'Chaurasia Store', 'Om Provision'],
      ),
    ];
  }

  List<Shipment> getShipments() {
    return const [
      Shipment(
        id: 'SHP-801',
        awbNumber: 'SE-AWB-98402',
        orderId: 'ORD-9201',
        shopName: 'Sharma General Store',
        productSummary: '5x Rice (25kg), 15x Cooking Oil',
        status: 'Out for Delivery',
        lastUpdate: '15 mins ago • Van #UP-50-AT-4412',
        trackingSteps: [
          TrackingStep(
            title: 'Order Confirmed',
            time: 'Today, 09:15 AM',
            isCompleted: true,
            description: 'Order validated against warehouse allocation',
          ),
          TrackingStep(
            title: 'Packed at Hub',
            time: 'Today, 10:30 AM',
            isCompleted: true,
            description: 'Cartons sealed & scanned at Azamgarh Central Depot',
          ),
          TrackingStep(
            title: 'Out for Delivery',
            time: 'Today, 12:45 PM',
            isCompleted: true,
            description: 'Assigned to Driver Manoj Yadav (Contact: +91 94151 77889)',
          ),
          TrackingStep(
            title: 'Delivery Confirmation',
            time: 'Expected by 02:30 PM',
            isCompleted: false,
            description: 'Shop owner OTP required for handover',
          ),
        ],
      ),
      Shipment(
        id: 'SHP-802',
        awbNumber: 'SE-AWB-98390',
        orderId: 'ORD-9202',
        shopName: 'Gupta Kirana Store',
        productSummary: '20x Wheat Flour, 150x Sugar',
        status: 'Packed at Hub',
        lastUpdate: '1 hour ago',
        trackingSteps: [
          TrackingStep(
            title: 'Order Confirmed',
            time: 'Today, 08:30 AM',
            isCompleted: true,
            description: 'Demand requisition fulfilled',
          ),
          TrackingStep(
            title: 'Packed at Hub',
            time: 'Today, 11:00 AM',
            isCompleted: true,
            description: 'Pallet loading in staging bay 4',
          ),
          TrackingStep(
            title: 'Out for Delivery',
            time: 'Scheduled 03:00 PM',
            isCompleted: false,
            description: 'Awaiting truck arrival',
          ),
        ],
      ),
    ];
  }

  List<AppAlertNotification> getNotifications() {
    return const [
      AppAlertNotification(
        id: 'N-1',
        title: 'High demand for Rice (50kg) in 3 shops',
        message: 'High demand for Rice (50kg) in 3 shops in Deoiganj area.',
        timeAgo: '2 hours ago',
        isRead: false,
        type: 'demand',
      ),
      AppAlertNotification(
        id: 'N-2',
        title: 'Low Stock Warning',
        message: 'Red Chilli Powder (500g) stock has dropped below 150 units.',
        timeAgo: '3 hours ago',
        isRead: false,
        type: 'low_stock',
      ),
      AppAlertNotification(
        id: 'N-3',
        title: 'Route A Ready for Dispatch',
        message: 'Driver Manoj Yadav is assigned and vehicle UP-50-AT-4412 is loaded.',
        timeAgo: '4 hours ago',
        isRead: true,
        type: 'dispatch',
      ),
      AppAlertNotification(
        id: 'N-4',
        title: 'New Retailer Connected',
        message: 'Anand Super Market has joined your distribution network.',
        timeAgo: 'Yesterday',
        isRead: true,
        type: 'order',
      ),
    ];
  }

  // --- Suppliers Management (Section 6) ---
  final List<Supplier> _suppliers = [
    const Supplier(
      id: 'SUP-01',
      name: 'ABC Foods Ltd.',
      totalPurchases: 250000.0,
      status: 'Active',
      category: 'Grains & Pulses',
      contactPerson: 'Arun Bhatia',
      phone: '+91 98110 54321',
      email: 'sales@abcfoods.com',
      address: 'Industrial Area Phase 2, Kanpur',
      lastPurchaseDate: 'Yesterday',
    ),
    const Supplier(
      id: 'SUP-02',
      name: 'Sunrise FMCG',
      totalPurchases: 165000.0,
      status: 'Active',
      category: 'Edible Oils & Spices',
      contactPerson: 'Sunil Rastogi',
      phone: '+91 94152 78901',
      email: 'orders@sunrisefmcg.in',
      address: 'Transport Nagar, Varanasi',
      lastPurchaseDate: '3 days ago',
    ),
    const Supplier(
      id: 'SUP-03',
      name: 'Global Partners',
      totalPurchases: 120000.0,
      status: 'Active',
      category: 'Packaged Staples & Sugar',
      contactPerson: 'Pooja Agarwal',
      phone: '+91 98391 22334',
      email: 'supply@globalpartners.com',
      address: 'Civil Lines, Lucknow',
      lastPurchaseDate: 'Last week',
    ),
  ];

  List<Supplier> getSuppliers() => List.unmodifiable(_suppliers);

  void addSupplier(Supplier supplier) {
    _suppliers.insert(0, supplier);
  }

  void updateSupplier(Supplier supplier) {
    final idx = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (idx != -1) {
      _suppliers[idx] = supplier;
    }
  }

  void deleteSupplier(String id) {
    _suppliers.removeWhere((s) => s.id == id);
  }

  // --- Salesman Coordination (Section 8) ---
  SalesmanProfile _salesman = const SalesmanProfile(
    id: 'SM-01',
    name: 'Rohit Kumar',
    role: 'Salesman',
    assignedShopsCount: 5,
    routeDistanceKm: 22.0,
    status: 'On Route',
    phone: '+91 98712 34567',
    vehicleNumber: 'UP-50-BX-9021',
  );

  SalesmanProfile getSalesmanProfile() => _salesman;

  void updateSalesmanStatus(String newStatus) {
    _salesman = _salesman.copyWith(status: newStatus);
  }

  final List<SalesmanVisit> _salesmanVisits = [
    const SalesmanVisit(
      id: 'VIS-01',
      shopId: 'SH-01',
      shopName: 'Sharma Gen. Store',
      status: 'Visited',
      scheduledTime: '9:30 AM',
      visitNotes: 'Collected demand for 20 bags Rice (25kg). Payment received via UPI.',
      collectedDemandAmount: 25000.0,
      visitedAt: '9:32 AM',
    ),
    const SalesmanVisit(
      id: 'VIS-02',
      shopId: 'SH-02',
      shopName: 'Gupta Kirana Store',
      status: 'Visited',
      scheduledTime: '11:45 AM',
      visitNotes: 'Inventory verified. Low on Cooking Oil, placed refill request.',
      collectedDemandAmount: 18400.0,
      visitedAt: '11:50 AM',
    ),
    const SalesmanVisit(
      id: 'VIS-03',
      shopId: 'SH-03',
      shopName: 'Verma Provision Store',
      status: 'Pending',
      scheduledTime: '2:00 PM',
    ),
    const SalesmanVisit(
      id: 'VIS-04',
      shopId: 'SH-04',
      shopName: 'Singh Traders',
      status: 'Pending',
      scheduledTime: '4:30 PM',
    ),
  ];

  List<SalesmanVisit> getSalesmanVisits() => List.unmodifiable(_salesmanVisits);

  void updateSalesmanVisit(String id, String status, {String? notes, double? orderAmount}) {
    final idx = _salesmanVisits.indexWhere((v) => v.id == id);
    if (idx != -1) {
      final current = _salesmanVisits[idx];
      _salesmanVisits[idx] = current.copyWith(
        status: status,
        visitNotes: notes ?? current.visitNotes,
        collectedDemandAmount: orderAmount ?? current.collectedDemandAmount,
        visitedAt: status.toLowerCase() == 'visited' ? 'Just now' : null,
      );
    }
  }

  // --- Key Reports (Section 7) ---
  StockReportSummary getStockReport() {
    return const StockReportSummary(
      totalValuation: 1840000.0,
      totalSkus: 48,
      lowStockCount: 6,
      turnoverRatio: 4.2,
      categoryBreakdown: [
        {'category': 'Grains & Rice', 'value': 750000.0, 'items': 14},
        {'category': 'Edible Oils', 'value': 480000.0, 'items': 10},
        {'category': 'Flours & Atta', 'value': 310000.0, 'items': 8},
        {'category': 'Sweeteners & Sugar', 'value': 180000.0, 'items': 6},
        {'category': 'Household & Personal Care', 'value': 120000.0, 'items': 10},
      ],
    );
  }

  SalesReportSummary getSalesReport() {
    return const SalesReportSummary(
      totalRevenue: 1285000.0,
      totalOrders: 142,
      averageOrderValue: 9049.0,
      monthlyGrowthPercent: 18.4,
      topProducts: [
        {'name': 'Rice (25kg)', 'revenue': 525000.0, 'units': 420},
        {'name': 'Wheat Flour (10kg)', 'revenue': 280000.0, 'units': 1000},
        {'name': 'Cooking Oil (1L)', 'revenue': 224000.0, 'units': 1400},
        {'name': 'Sugar (1kg)', 'revenue': 112500.0, 'units': 2500},
      ],
    );
  }

  PurchaseReportSummary getPurchaseReport() {
    final total = _suppliers.fold<double>(0.0, (sum, s) => sum + s.totalPurchases);
    return PurchaseReportSummary(
      totalPurchases: total,
      outstandingPayable: 185000.0,
      activeSuppliersCount: _suppliers.where((s) => s.status == 'Active').length,
      topSuppliers: _suppliers.map((s) => {
        'name': s.name,
        'amount': s.totalPurchases,
        'status': s.status,
      }).toList(),
    );
  }

  ProfitLossSummary getProfitLossReport() {
    const revenue = 1285000.0;
    const cogs = 940000.0;
    const grossProfit = revenue - cogs; // 345,000
    const grossMargin = (grossProfit / revenue) * 100; // 26.8%
    const operatingExpenses = 85000.0; // Warehouse + logistics
    const netProfit = grossProfit - operatingExpenses; // 260,000
    const netMargin = (netProfit / revenue) * 100; // 20.2%

    return const ProfitLossSummary(
      totalRevenue: revenue,
      costOfGoodsSold: cogs,
      grossProfit: grossProfit,
      grossMarginPercent: grossMargin,
      operatingExpenses: operatingExpenses,
      netProfit: netProfit,
      netMarginPercent: netMargin,
    );
  }
}

