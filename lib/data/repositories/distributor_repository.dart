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
  bool get isAuthenticated =>
      _currentUser != null && _currentUser!.token != null;

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

    final refId =
        'SE-DIST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

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

  Future<bool> verifyOtpAndResetPassword(
    String mobile,
    String otp,
    String newPassword,
  ) async {
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
      // Primary Section 5.7 Reference Demonstration Products (Top 5 Table Rows)
      const InventoryItem(
        id: 'INV-01',
        name: 'Rice (25kg)',
        category: 'Grains',
        quantity: 420,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 1250.0,
        imageAsset: 'assets/images/prod_rice.png',
        sku: 'SKU-RC-25',
        warehouseLocation: 'Bay A-01, Pallet 3',
      ),
      const InventoryItem(
        id: 'INV-02',
        name: 'Cooking Oil (1L)',
        category: 'Oils',
        quantity: 360,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 160.0,
        imageAsset: 'assets/images/prod_oil.png',
        sku: 'SKU-OL-01',
        warehouseLocation: 'Bay B-04, Rack 2',
      ),
      const InventoryItem(
        id: 'INV-03',
        name: 'Wheat Flour (10kg)',
        category: 'Flour',
        quantity: 280,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 280.0,
        imageAsset: 'assets/images/prod_flour.png',
        sku: 'SKU-WF-10',
        warehouseLocation: 'Bay A-03, Pallet 1',
      ),
      const InventoryItem(
        id: 'INV-04',
        name: 'Sugar (1kg)',
        category: 'Sweeteners',
        quantity: 240,
        unit: 'units',
        lowStockThreshold: 250, // Low stock: 240 <= 250
        pricePerUnit: 45.0,
        imageAsset: 'assets/images/prod_sugar.png',
        sku: 'SKU-SG-01',
        warehouseLocation: 'Bay C-02, Shelf 4',
      ),
      const InventoryItem(
        id: 'INV-05',
        name: 'Tea (1kg)',
        category: 'Beverages',
        quantity: 227,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 320.0,
        imageAsset: 'assets/images/prod_tea.png',
        sku: 'SKU-TE-01',
        warehouseLocation: 'Bay C-05, Shelf 1',
      ),

      // Additional Low Stock Items (11 more, totaling 12 Low Stock Items)
      const InventoryItem(
        id: 'INV-06',
        name: 'Tata Salt (1kg)',
        category: 'Salt & Spices',
        quantity: 95,
        unit: 'units',
        lowStockThreshold: 150,
        pricePerUnit: 28.0,
        sku: 'SKU-ST-01',
        warehouseLocation: 'Bay D-01',
      ),
      const InventoryItem(
        id: 'INV-07',
        name: 'Red Chilli Powder (500g)',
        category: 'Salt & Spices',
        quantity: 45,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 145.0,
        sku: 'SKU-RC-05',
        warehouseLocation: 'Bay D-02',
      ),
      const InventoryItem(
        id: 'INV-08',
        name: 'Turmeric Powder (500g)',
        category: 'Salt & Spices',
        quantity: 60,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 110.0,
        sku: 'SKU-TM-05',
        warehouseLocation: 'Bay D-03',
      ),
      const InventoryItem(
        id: 'INV-09',
        name: 'Coriander Powder (500g)',
        category: 'Salt & Spices',
        quantity: 55,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 95.0,
        sku: 'SKU-CP-05',
        warehouseLocation: 'Bay D-04',
      ),
      const InventoryItem(
        id: 'INV-10',
        name: 'Moong Dal (1kg)',
        category: 'Pulses',
        quantity: 80,
        unit: 'units',
        lowStockThreshold: 120,
        pricePerUnit: 135.0,
        sku: 'SKU-MD-01',
        warehouseLocation: 'Bay E-01',
      ),
      const InventoryItem(
        id: 'INV-11',
        name: 'Chana Dal (1kg)',
        category: 'Pulses',
        quantity: 75,
        unit: 'units',
        lowStockThreshold: 120,
        pricePerUnit: 98.0,
        sku: 'SKU-CD-01',
        warehouseLocation: 'Bay E-02',
      ),
      const InventoryItem(
        id: 'INV-12',
        name: 'Urad Dal (1kg)',
        category: 'Pulses',
        quantity: 65,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 140.0,
        sku: 'SKU-UD-01',
        warehouseLocation: 'Bay E-03',
      ),
      const InventoryItem(
        id: 'INV-13',
        name: 'Mustard Oil (1L)',
        category: 'Oils',
        quantity: 90,
        unit: 'units',
        lowStockThreshold: 150,
        pricePerUnit: 175.0,
        sku: 'SKU-MO-01',
        warehouseLocation: 'Bay B-02',
      ),
      const InventoryItem(
        id: 'INV-14',
        name: 'Bathing Soap (Pack of 4)',
        category: 'Personal Care',
        quantity: 110,
        unit: 'units',
        lowStockThreshold: 150,
        pricePerUnit: 145.0,
        sku: 'SKU-BS-04',
        warehouseLocation: 'Bay F-01',
      ),
      const InventoryItem(
        id: 'INV-15',
        name: 'Dishwash Bar (Pack of 3)',
        category: 'Household',
        quantity: 85,
        unit: 'units',
        lowStockThreshold: 120,
        pricePerUnit: 45.0,
        sku: 'SKU-DW-03',
        warehouseLocation: 'Bay F-02',
      ),
      const InventoryItem(
        id: 'INV-16',
        name: 'Biscuits Assorted (Box)',
        category: 'Snacks',
        quantity: 70,
        unit: 'units',
        lowStockThreshold: 100,
        pricePerUnit: 250.0,
        sku: 'SKU-BA-01',
        warehouseLocation: 'Bay G-01',
      ),

      // Bulk In-Stock Inventory (Brings total units to EXACTLY 8,420)
      const InventoryItem(
        id: 'INV-17',
        name: 'Premium Basmati Rice (10kg)',
        category: 'Grains',
        quantity: 1450,
        unit: 'units',
        lowStockThreshold: 200,
        pricePerUnit: 950.0,
        sku: 'SKU-BR-10',
        warehouseLocation: 'Bay A-05',
      ),
      const InventoryItem(
        id: 'INV-18',
        name: 'Sunflower Refined Oil (5L Can)',
        category: 'Oils',
        quantity: 1120,
        unit: 'units',
        lowStockThreshold: 200,
        pricePerUnit: 720.0,
        sku: 'SKU-SO-05',
        warehouseLocation: 'Bay B-01',
      ),
      const InventoryItem(
        id: 'INV-19',
        name: 'Whole Wheat Atta (5kg)',
        category: 'Flour',
        quantity: 1250,
        unit: 'units',
        lowStockThreshold: 250,
        pricePerUnit: 210.0,
        sku: 'SKU-WA-05',
        warehouseLocation: 'Bay A-04',
      ),
      const InventoryItem(
        id: 'INV-20',
        name: 'Toor Dal Premium (5kg)',
        category: 'Pulses',
        quantity: 850,
        unit: 'units',
        lowStockThreshold: 200,
        pricePerUnit: 680.0,
        sku: 'SKU-TD-05',
        warehouseLocation: 'Bay E-04',
      ),
      const InventoryItem(
        id: 'INV-21',
        name: 'Washing Powder (1kg Pack)',
        category: 'Household',
        quantity: 720,
        unit: 'units',
        lowStockThreshold: 150,
        pricePerUnit: 130.0,
        sku: 'SKU-WP-01',
        warehouseLocation: 'Bay F-03',
      ),
      const InventoryItem(
        id: 'INV-22',
        name: 'Iodized Table Salt (1kg)',
        category: 'Salt & Spices',
        quantity: 673,
        unit: 'units',
        lowStockThreshold: 200,
        pricePerUnit: 25.0,
        sku: 'SKU-TS-01',
        warehouseLocation: 'Bay D-05',
      ),
    ];
  }

  final List<DistributorOrder> _orders = [
    // 1. Primary Reference Order 1 (Pending)
    DistributorOrder(
      id: 'ORD-9201',
      shopId: 'SH-01',
      shopName: 'Sharma Gen. Store',
      location: 'Deoganj',
      itemCount: 2,
      orderAmount: 2460.0,
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(minutes: 35)),
      customerPhone: '+91 98765 12340',
      notes: 'Urgent weekend morning delivery requested',
      statusHistory: const [
        'Order submitted by Sharma Gen. Store via App',
        'Demand aggregated into Route A batch',
      ],
      items: const [
        OrderItem(productName: 'Rice (25kg)', quantity: 1, price: 1250),
        OrderItem(productName: 'Refined Oil (1L)', quantity: 1, price: 1210),
      ],
    ),

    // 2. Primary Reference Order 2 (Processing)
    DistributorOrder(
      id: 'ORD-9202',
      shopId: 'SH-02',
      shopName: 'Gupta Kirana Store',
      location: 'Main Bazar',
      itemCount: 4,
      orderAmount: 4120.0,
      status: 'Processing',
      date: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      customerPhone: '+91 91234 56780',
      notes: 'Payment confirmed via UPI; packing in Bay B',
      statusHistory: const [
        'Order placed by Sanjay Gupta',
        'Payment verified ₹4,120',
        'Allocated to Bay B picking list',
      ],
      items: const [
        OrderItem(productName: 'Wheat Flour (10kg)', quantity: 5, price: 380),
        OrderItem(productName: 'Sugar (1kg)', quantity: 20, price: 45),
        OrderItem(productName: 'Cooking Oil (1L)', quantity: 5, price: 160),
        OrderItem(productName: 'Tea (1kg)', quantity: 1, price: 520),
      ],
    ),

    // 3. Primary Reference Order 3 (Processing)
    DistributorOrder(
      id: 'ORD-9195',
      shopId: 'SH-03',
      shopName: 'Verma Provision Store',
      location: 'Kachhpura',
      itemCount: 3,
      orderAmount: 2780.0,
      status: 'Processing',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      customerPhone: '+91 91290 98765',
      notes: 'Goods packaged, staging at dispatch bay 1',
      statusHistory: const [
        'Order created by Sunil Verma',
        'Assigned to Vehicle UP-50-AT-4412',
      ],
      items: const [
        OrderItem(productName: 'Toor Dal (5kg)', quantity: 2, price: 680),
        OrderItem(productName: 'Cooking Oil (1L)', quantity: 6, price: 160),
        OrderItem(productName: 'Sugar (1kg)', quantity: 10, price: 46),
      ],
    ),

    // 4. Primary Reference Order 4 (Delivered)
    DistributorOrder(
      id: 'ORD-9188',
      shopId: 'SH-04',
      shopName: 'Singh Traders',
      location: 'Nawabganj',
      itemCount: 5,
      orderAmount: 6000.0,
      status: 'Delivered',
      date: DateTime.now().subtract(const Duration(hours: 7)),
      customerPhone: '+91 94500 67890',
      notes: 'Received by Raghav Singh. Signature recorded on delivery.',
      statusHistory: const [
        'Order placed yesterday 6:00 PM',
        'Dispatched on Route B',
        'Delivered & OTP confirmed by Raghav Singh',
      ],
      items: const [
        OrderItem(productName: 'Rice (25kg)', quantity: 4, price: 1250),
        OrderItem(productName: 'Cooking Oil (1L)', quantity: 5, price: 160),
        OrderItem(productName: 'Tata Salt (1kg)', quantity: 4, price: 25),
        OrderItem(productName: 'Moong Dal (1kg)', quantity: 1, price: 100),
      ],
    ),

    // Additional Pending Orders (to total 4 Pending)
    DistributorOrder(
      id: 'ORD-9203',
      shopId: 'SH-05',
      shopName: 'Anand Super Market',
      location: 'Civil Lines',
      itemCount: 3,
      orderAmount: 3450.0,
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(minutes: 50)),
      items: const [
        OrderItem(productName: 'Atta (5kg)', quantity: 10, price: 210),
        OrderItem(productName: 'Ghee (1L)', quantity: 2, price: 675),
      ],
    ),
    DistributorOrder(
      id: 'ORD-9204',
      shopId: 'SH-06',
      shopName: 'Bharat Daily Mart',
      location: 'Ailwal',
      itemCount: 6,
      orderAmount: 5120.0,
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      items: const [
        OrderItem(productName: 'Soyabean Oil (1L)', quantity: 20, price: 140),
        OrderItem(productName: 'Basmati Rice (5kg)', quantity: 4, price: 580),
      ],
    ),
    DistributorOrder(
      id: 'ORD-9205',
      shopId: 'SH-07',
      shopName: 'Kisan Seva Kendra',
      location: 'Chowk',
      itemCount: 2,
      orderAmount: 1850.0,
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      items: const [
        OrderItem(productName: 'Sugar (1kg)', quantity: 30, price: 45),
        OrderItem(productName: 'Salt (1kg)', quantity: 20, price: 25),
      ],
    ),

    // Additional Processing Orders (to total 4 Processing)
    DistributorOrder(
      id: 'ORD-9196',
      shopId: 'SH-08',
      shopName: 'Patel Kirana Bhandar',
      location: 'Rani Ki Sarai',
      itemCount: 4,
      orderAmount: 4900.0,
      status: 'Processing',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      items: const [
        OrderItem(productName: 'Mustard Oil (1L)', quantity: 15, price: 175),
        OrderItem(productName: 'Toor Dal (1kg)', quantity: 15, price: 150),
      ],
    ),
    DistributorOrder(
      id: 'ORD-9197',
      shopId: 'SH-09',
      shopName: 'Laxmi Grocery Store',
      location: 'Mubarakpur',
      itemCount: 5,
      orderAmount: 3820.0,
      status: 'Processing',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      items: const [
        OrderItem(productName: 'Wheat Flour (10kg)', quantity: 10, price: 280),
        OrderItem(productName: 'Spices Packets', quantity: 20, price: 51),
      ],
    ),

    // Additional Delivered Order (to total 2 Delivered)
    DistributorOrder(
      id: 'ORD-9189',
      shopId: 'SH-10',
      shopName: 'Mohan General Store',
      location: 'Bilariaganj',
      itemCount: 3,
      orderAmount: 7200.0,
      status: 'Delivered',
      date: DateTime.now().subtract(const Duration(days: 1)),
      items: const [
        OrderItem(productName: 'Rice (25kg)', quantity: 5, price: 1250),
        OrderItem(productName: 'Sugar (1kg)', quantity: 20, price: 45),
      ],
    ),

    // 2 Dispatched / In Transit Orders (bringing Total Orders to EXACTLY 12)
    DistributorOrder(
      id: 'ORD-9198',
      shopId: 'SH-11',
      shopName: 'Agrawal Brothers',
      location: 'Kotwali Bazar',
      itemCount: 4,
      orderAmount: 5600.0,
      status: 'Dispatched',
      date: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
      items: const [
        OrderItem(productName: 'Rice (25kg)', quantity: 3, price: 1250),
        OrderItem(productName: 'Sunflower Oil (5L)', quantity: 2, price: 720),
      ],
    ),
    DistributorOrder(
      id: 'ORD-9199',
      shopId: 'SH-12',
      shopName: 'Jaiswal Traders',
      location: 'Harraiya',
      itemCount: 3,
      orderAmount: 3100.0,
      status: 'Dispatched',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      items: const [
        OrderItem(productName: 'Atta (10kg)', quantity: 10, price: 280),
        OrderItem(productName: 'Washing Powder', quantity: 3, price: 100),
      ],
    ),
  ];

  List<DistributorOrder> getOrders() {
    return List.unmodifiable(_orders);
  }

  DistributorOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateOrderStatus(
    String orderId,
    String newStatus, {
    String? note,
    String performedBy = 'Distributor',
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _orders[idx];
      final history = List<String>.from(current.statusHistory)
        ..insert(
          0,
          'Status updated to $newStatus by $performedBy${note != null ? ' ($note)' : ''}',
        );
      _orders[idx] = current.copyWith(
        status: newStatus,
        statusHistory: history,
      );
    }
  }

  void addOrder(DistributorOrder order) {
    _orders.insert(0, order);
  }

  final List<DispatchRoute> _dispatchRoutes = [
    // 1. Reference Route A - Main Market
    DispatchRoute(
      id: 'RT-A',
      routeName: 'Route A - Main Market',
      assignedDriver: 'Manoj Yadav',
      driverPhone: '+91 94151 77889',
      vehicleNumber: 'UP-50-AT-4412',
      stopCount: 5,
      distanceKm: 18.0,
      estDuration: '2h 30m',
      status: 'On Route',
      dispatchDate: DateTime(2025, 4, 24),
      shopNames: const [
        'Sharma Gen. Store',
        'Gupta Kirana Store',
        'Bharat Daily Mart',
        'Kisan Seva Kendra',
        'Chaurasia Brothers',
      ],
      stops: const [
        RouteStop(
          sequence: 1,
          shopId: 'SH-01',
          shopName: 'Sharma Gen. Store',
          address: 'Deoganj, Azamgarh',
          orderId: 'ORD-9201',
          orderAmount: 2460.0,
          status: 'Delivered',
        ),
        RouteStop(
          sequence: 2,
          shopId: 'SH-02',
          shopName: 'Gupta Kirana Store',
          address: 'Main Bazar, Azamgarh',
          orderId: 'ORD-9202',
          orderAmount: 4120.0,
          status: 'In Transit',
        ),
        RouteStop(
          sequence: 3,
          shopId: 'SH-05',
          shopName: 'Bharat Daily Mart',
          address: 'Station Road, Azamgarh',
          orderId: 'ORD-9190',
          orderAmount: 3400.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 4,
          shopId: 'SH-06',
          shopName: 'Kisan Seva Kendra',
          address: 'Mandi Samiti, Azamgarh',
          orderId: 'ORD-9185',
          orderAmount: 1850.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 5,
          shopId: 'SH-07',
          shopName: 'Chaurasia Brothers',
          address: 'Kotwali Crossing, Azamgarh',
          orderId: 'ORD-9180',
          orderAmount: 2900.0,
          status: 'Pending',
        ),
      ],
      orderIds: const [
        'ORD-9201',
        'ORD-9202',
        'ORD-9190',
        'ORD-9185',
        'ORD-9180',
      ],
      statusHistory: const [
        'Route created & orders batched for 24 Apr 2025',
        'Driver Manoj Yadav assigned with Vehicle UP-50-AT-4412',
        'Departed Azamgarh Central Depot - On Route',
      ],
    ),

    // 2. Reference Route B - Mubarikabad
    DispatchRoute(
      id: 'RT-B',
      routeName: 'Route B - Mubarikabad',
      assignedDriver: 'Suresh Verma',
      driverPhone: '+91 98390 44556',
      vehicleNumber: 'UP-50-BX-1022',
      stopCount: 5,
      distanceKm: 18.0,
      estDuration: '2h 10m',
      status: 'Ready',
      dispatchDate: DateTime(2025, 4, 24),
      shopNames: const [
        'Verma Provision Store',
        'Anand Super Market',
        'Mubarikabad Mini Mart',
        'Ali Kirana Store',
        'New Janta Store',
      ],
      stops: const [
        RouteStop(
          sequence: 1,
          shopId: 'SH-03',
          shopName: 'Verma Provision Store',
          address: 'Kachhpura, Mubarikabad',
          orderId: 'ORD-9195',
          orderAmount: 2780.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 2,
          shopId: 'SH-08',
          shopName: 'Anand Super Market',
          address: 'Bus Stand Road, Mubarikabad',
          orderId: 'ORD-9192',
          orderAmount: 5100.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 3,
          shopId: 'SH-09',
          shopName: 'Mubarikabad Mini Mart',
          address: 'Near Old Post Office, Mubarikabad',
          orderId: 'ORD-9187',
          orderAmount: 2200.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 4,
          shopId: 'SH-10',
          shopName: 'Ali Kirana Store',
          address: 'Jama Masjid Market, Mubarikabad',
          orderId: 'ORD-9184',
          orderAmount: 1950.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 5,
          shopId: 'SH-11',
          shopName: 'New Janta Store',
          address: 'Hospital Square, Mubarikabad',
          orderId: 'ORD-9179',
          orderAmount: 3150.0,
          status: 'Pending',
        ),
      ],
      orderIds: const [
        'ORD-9195',
        'ORD-9192',
        'ORD-9187',
        'ORD-9184',
        'ORD-9179',
      ],
      statusHistory: const [
        'Route planned for 24 Apr 2025',
        'Staging bay loading verified',
        'Status marked Ready for departure',
      ],
    ),

    // 3. Reference Route C - Deotgaon
    DispatchRoute(
      id: 'RT-C',
      routeName: 'Route C - Deotgaon',
      assignedDriver: 'Amit Kumar',
      driverPhone: '+91 91290 88990',
      vehicleNumber: 'UP-50-CK-7890',
      stopCount: 4,
      distanceKm: 16.0,
      estDuration: '1h 45m',
      status: 'Pending',
      dispatchDate: DateTime(2025, 4, 24),
      shopNames: const [
        'Singh Traders',
        'Deotgaon Farmers Mart',
        'Patel Traders',
        'Kashi General Store',
      ],
      stops: const [
        RouteStop(
          sequence: 1,
          shopId: 'SH-04',
          shopName: 'Singh Traders',
          address: 'Nawabganj Bypass, Deotgaon',
          orderId: 'ORD-9188',
          orderAmount: 6000.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 2,
          shopId: 'SH-12',
          shopName: 'Deotgaon Farmers Mart',
          address: 'Rural Link Road, Deotgaon',
          orderId: 'ORD-9182',
          orderAmount: 2450.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 3,
          shopId: 'SH-13',
          shopName: 'Patel Traders',
          address: 'Panchayat Bhavan Road, Deotgaon',
          orderId: 'ORD-9178',
          orderAmount: 3800.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 4,
          shopId: 'SH-14',
          shopName: 'Kashi General Store',
          address: 'East Canal Colony, Deotgaon',
          orderId: 'ORD-9175',
          orderAmount: 1600.0,
          status: 'Pending',
        ),
      ],
      orderIds: const ['ORD-9188', 'ORD-9182', 'ORD-9178', 'ORD-9175'],
      statusHistory: const [
        'Route draft generated for 24 Apr 2025',
        'Awaiting final stock picking completion',
      ],
    ),

    // 4. Reference Route D - Kochbazar
    DispatchRoute(
      id: 'RT-D',
      routeName: 'Route D - Kochbazar',
      assignedDriver: 'Rakesh Bind',
      driverPhone: '+91 97920 33441',
      vehicleNumber: 'UP-50-DH-5521',
      stopCount: 5,
      distanceKm: 24.0,
      estDuration: '3h 20m',
      status: 'Not Started',
      dispatchDate: DateTime(2025, 4, 24),
      shopNames: const [
        'Om Provision Store',
        'Maa Durga Kirana',
        'Bholenath Trading',
        'Kochbazar Fresh Point',
        'Shree Ram Departmental',
      ],
      stops: const [
        RouteStop(
          sequence: 1,
          shopId: 'SH-15',
          shopName: 'Om Provision Store',
          address: 'North Crossing, Kochbazar',
          orderId: 'ORD-9172',
          orderAmount: 2100.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 2,
          shopId: 'SH-16',
          shopName: 'Maa Durga Kirana',
          address: 'Main Chowk, Kochbazar',
          orderId: 'ORD-9170',
          orderAmount: 3250.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 3,
          shopId: 'SH-17',
          shopName: 'Bholenath Trading',
          address: 'Grain Market, Kochbazar',
          orderId: 'ORD-9168',
          orderAmount: 4800.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 4,
          shopId: 'SH-18',
          shopName: 'Kochbazar Fresh Point',
          address: 'Cinema Road, Kochbazar',
          orderId: 'ORD-9165',
          orderAmount: 1950.0,
          status: 'Pending',
        ),
        RouteStop(
          sequence: 5,
          shopId: 'SH-19',
          shopName: 'Shree Ram Departmental',
          address: 'Outer Ring Road, Kochbazar',
          orderId: 'ORD-9162',
          orderAmount: 2700.0,
          status: 'Pending',
        ),
      ],
      orderIds: const [
        'ORD-9172',
        'ORD-9170',
        'ORD-9168',
        'ORD-9165',
        'ORD-9162',
      ],
      statusHistory: const [
        'Route mapped for 24 Apr 2025 afternoon dispatch wave',
      ],
    ),
  ];

  List<DispatchRoute> getDispatchRoutes({DateTime? forDate}) {
    if (forDate == null) {
      return List.unmodifiable(_dispatchRoutes);
    }
    return _dispatchRoutes
        .where(
          (r) =>
              r.dispatchDate.year == forDate.year &&
              r.dispatchDate.month == forDate.month &&
              r.dispatchDate.day == forDate.day,
        )
        .toList();
  }

  DispatchRoute? getDispatchRouteById(String id) {
    try {
      return _dispatchRoutes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateRouteStatus(String routeId, String newStatus, {String? note}) {
    final idx = _dispatchRoutes.indexWhere((r) => r.id == routeId);
    if (idx != -1) {
      final current = _dispatchRoutes[idx];
      final history = List<String>.from(current.statusHistory)
        ..insert(
          0,
          'Status updated to $newStatus${note != null ? ' ($note)' : ''}',
        );
      _dispatchRoutes[idx] = current.copyWith(
        status: newStatus,
        statusHistory: history,
      );
    }
  }

  final List<Shipment> _shipments = [
    // 1. Reference Shipment 1 (Delivered)
    const Shipment(
      id: 'SHP-01',
      awbNumber: 'AWB0012345',
      orderId: 'ORD-9201',
      shopName: 'Sharma Gen. Store',
      productName: 'Rice (25kg)',
      quantity: 12,
      productSummary: '12 units Rice (25kg)',
      status: 'Delivered',
      timestamp: 'Today, 10:24 AM',
      lastUpdate: 'Handover complete with Shop OTP',
      driverName: 'Manoj Yadav',
      driverPhone: '+91 94151 77889',
      vehicleNumber: 'UP-50-AT-4412',
      deliveryAddress: 'Deoganj, Azamgarh',
      trackingSteps: [
        TrackingStep(
          title: 'Order Confirmed',
          time: 'Today, 08:00 AM',
          isCompleted: true,
          description: 'Order confirmed and inventory locked',
        ),
        TrackingStep(
          title: 'Dispatched from Hub',
          time: 'Today, 08:45 AM',
          isCompleted: true,
          description: 'Loaded onto Vehicle UP-50-AT-4412',
        ),
        TrackingStep(
          title: 'Out for Delivery',
          time: 'Today, 09:30 AM',
          isCompleted: true,
          description: 'Driver Manoj Yadav en route to Sharma Gen. Store',
        ),
        TrackingStep(
          title: 'Delivered Successfully',
          time: 'Today, 10:24 AM',
          isCompleted: true,
          description: 'Delivered and verified via shop OTP',
        ),
      ],
    ),

    // 2. Reference Shipment 2 (In Transit)
    const Shipment(
      id: 'SHP-02',
      awbNumber: 'AWB0012356',
      orderId: 'ORD-9202',
      shopName: 'Gupta Kirana Store',
      productName: 'Cooking Oil (1L)',
      quantity: 10,
      productSummary: '10 units Cooking Oil (1L)',
      status: 'In Transit',
      timestamp: 'Today, 08:45 AM',
      lastUpdate: 'En route via Main Market bypass',
      driverName: 'Manoj Yadav',
      driverPhone: '+91 94151 77889',
      vehicleNumber: 'UP-50-AT-4412',
      deliveryAddress: 'Main Bazar, Azamgarh',
      trackingSteps: [
        TrackingStep(
          title: 'Order Confirmed',
          time: 'Today, 07:30 AM',
          isCompleted: true,
          description: 'Order processed for delivery wave 1',
        ),
        TrackingStep(
          title: 'Dispatched from Hub',
          time: 'Today, 08:45 AM',
          isCompleted: true,
          description: 'Departed Azamgarh Central Depot',
        ),
        TrackingStep(
          title: 'In Transit',
          time: 'Today, 09:15 AM',
          isCompleted: true,
          description: 'Approaching Main Bazar sector',
        ),
        TrackingStep(
          title: 'Delivery Handover',
          time: 'Expected by 11:30 AM',
          isCompleted: false,
          description: 'Awaiting shop arrival',
        ),
      ],
    ),

    // 3. Reference Shipment 3 (Out for Delivery)
    const Shipment(
      id: 'SHP-03',
      awbNumber: 'AWB0012367',
      orderId: 'ORD-9195',
      shopName: 'Verma Provision Store',
      productName: 'Wheat Flour (10kg)',
      quantity: 8,
      productSummary: '8 units Wheat Flour (10kg)',
      status: 'Out for Delivery',
      timestamp: 'Today, 07:25 AM',
      lastUpdate: 'Assigned to delivery route B',
      driverName: 'Suresh Verma',
      driverPhone: '+91 98390 44556',
      vehicleNumber: 'UP-50-BX-1022',
      deliveryAddress: 'Kachhpura, Mubarikabad',
      trackingSteps: [
        TrackingStep(
          title: 'Order Confirmed',
          time: 'Today, 06:45 AM',
          isCompleted: true,
          description: 'Stock verified in bay 2',
        ),
        TrackingStep(
          title: 'Out for Delivery',
          time: 'Today, 07:25 AM',
          isCompleted: true,
          description: 'Assigned to driver Suresh Verma',
        ),
        TrackingStep(
          title: 'Arriving at Shop',
          time: 'Expected by 01:00 PM',
          isCompleted: false,
          description: 'Estimated arrival in 45 minutes',
        ),
      ],
    ),

    // 4. Reference Shipment 4 (Scheduled)
    const Shipment(
      id: 'SHP-04',
      awbNumber: 'AWB0012378',
      orderId: 'ORD-9188',
      shopName: 'Singh Traders',
      productName: 'Sugar (1kg)',
      quantity: 20,
      productSummary: '20 units Sugar (1kg)',
      status: 'Scheduled',
      timestamp: 'Today, 06:30 PM',
      lastUpdate: 'Scheduled for evening batch',
      driverName: 'Amit Kumar',
      driverPhone: '+91 91290 88990',
      vehicleNumber: 'UP-50-CK-7890',
      deliveryAddress: 'Nawabganj, Azamgarh',
      trackingSteps: [
        TrackingStep(
          title: 'Shipment Scheduled',
          time: 'Today, 09:00 AM',
          isCompleted: true,
          description: 'Delivery window allocated for 06:30 PM wave',
        ),
        TrackingStep(
          title: 'Staging & Loading',
          time: 'Scheduled 04:30 PM',
          isCompleted: false,
          description: 'Goods to be transferred to dispatch deck',
        ),
        TrackingStep(
          title: 'Out for Delivery',
          time: 'Scheduled 05:45 PM',
          isCompleted: false,
          description: 'Pending driver check-in',
        ),
      ],
    ),
  ];

  List<Shipment> getShipments() {
    return List.unmodifiable(_shipments);
  }

  Shipment? getShipmentByAwb(String awb) {
    try {
      return _shipments.firstWhere(
        (s) => s.awbNumber.toLowerCase() == awb.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void updateShipmentStatus(
    String awbNumber,
    String newStatus, {
    String? note,
  }) {
    final idx = _shipments.indexWhere((s) => s.awbNumber == awbNumber);
    if (idx != -1) {
      final current = _shipments[idx];
      final updatedSteps = List<TrackingStep>.from(current.trackingSteps)
        ..add(
          TrackingStep(
            title: 'Status changed to $newStatus',
            time: 'Just now',
            isCompleted: true,
            description: note ?? 'Status update recorded in tracking system',
          ),
        );
      _shipments[idx] = current.copyWith(
        status: newStatus,
        lastUpdate: note ?? 'Updated to $newStatus',
        trackingSteps: updatedSteps,
      );
    }
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
      visitNotes:
          'Collected demand for 20 bags Rice (25kg). Payment received via UPI.',
      collectedDemandAmount: 25000.0,
      visitedAt: '9:32 AM',
    ),
    const SalesmanVisit(
      id: 'VIS-02',
      shopId: 'SH-02',
      shopName: 'Gupta Kirana Store',
      status: 'Visited',
      scheduledTime: '11:45 AM',
      visitNotes:
          'Inventory verified. Low on Cooking Oil, placed refill request.',
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

  void updateSalesmanVisit(
    String id,
    String status, {
    String? notes,
    double? orderAmount,
  }) {
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
        {
          'category': 'Household & Personal Care',
          'value': 120000.0,
          'items': 10,
        },
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
    final total = _suppliers.fold<double>(
      0.0,
      (sum, s) => sum + s.totalPurchases,
    );
    return PurchaseReportSummary(
      totalPurchases: total,
      outstandingPayable: 185000.0,
      activeSuppliersCount: _suppliers
          .where((s) => s.status == 'Active')
          .length,
      topSuppliers: _suppliers
          .map(
            (s) => {
              'name': s.name,
              'amount': s.totalPurchases,
              'status': s.status,
            },
          )
          .toList(),
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

  // --- Stock Movement History (Section 5.8) ---
  final List<StockMovement> _movements = [
    StockMovement(
      id: 'MOV-101',
      itemId: 'INV-01',
      productName: 'Rice (25kg)',
      type: 'RECEIPT',
      quantityChange: 150,
      balanceAfter: 420,
      reason: 'Inbound PO #PO-8821 from ABC Foods Ltd.',
      performedBy: 'Warehouse Supervisor',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    StockMovement(
      id: 'MOV-102',
      itemId: 'INV-04',
      productName: 'Sugar (1kg)',
      type: 'ISSUE',
      quantityChange: -60,
      balanceAfter: 240,
      reason: 'Dispatched for Route A (Sharma Store)',
      performedBy: 'Warehouse Dispatcher',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    StockMovement(
      id: 'MOV-103',
      itemId: 'INV-02',
      productName: 'Cooking Oil (1L)',
      type: 'ADJUSTMENT',
      quantityChange: 10,
      balanceAfter: 360,
      reason: 'Cycle count physical reconciliation',
      performedBy: 'Quality Control Lead',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockMovement(
      id: 'MOV-104',
      itemId: 'INV-05',
      productName: 'Tea (1kg)',
      type: 'RECEIPT',
      quantityChange: 50,
      balanceAfter: 227,
      reason: 'Stock replenishment PO #PO-8819',
      performedBy: 'Warehouse Inward',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<StockMovement> getStockMovements({String? itemId}) {
    if (itemId != null) {
      return _movements.where((m) => m.itemId == itemId).toList();
    }
    return List.unmodifiable(_movements);
  }

  void recordStockMovement(StockMovement movement) {
    _movements.insert(0, movement);
  }
}
