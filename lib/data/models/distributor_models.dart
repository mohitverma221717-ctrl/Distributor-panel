class DistributorUser {
  final String id;
  final String name;
  final String businessName;
  final String mobileNumber;
  final String gstNumber;
  final String businessType;
  final String address;
  final String email;
  final String avatarAsset;
  final String status;
  final String? token;

  const DistributorUser({
    required this.id,
    required this.name,
    required this.businessName,
    required this.mobileNumber,
    required this.gstNumber,
    required this.businessType,
    required this.address,
    this.email = 'ramesh.distributors@shopeasy.in',
    this.avatarAsset = 'assets/images/user_avatar.png',
    this.status = 'Approved',
    this.token,
  });

  DistributorUser copyWith({
    String? id,
    String? name,
    String? businessName,
    String? mobileNumber,
    String? gstNumber,
    String? businessType,
    String? address,
    String? email,
    String? avatarAsset,
    String? status,
    String? token,
  }) {
    return DistributorUser(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      email: email ?? this.email,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      status: status ?? this.status,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'businessName': businessName,
    'mobileNumber': mobileNumber,
    'gstNumber': gstNumber,
    'businessType': businessType,
    'address': address,
    'email': email,
    'avatarAsset': avatarAsset,
    'status': status,
    'token': token,
  };

  factory DistributorUser.fromJson(Map<String, dynamic> json) =>
      DistributorUser(
        id: json['id'] as String? ?? 'D-101',
        name: json['name'] as String? ?? 'Ramesh Kumar',
        businessName: json['businessName'] as String? ?? 'Ramesh Distributors',
        mobileNumber: json['mobileNumber'] as String? ?? '9876543210',
        gstNumber: json['gstNumber'] as String? ?? '22AABCD1234F1ZS',
        businessType:
            json['businessType'] as String? ?? 'Wholesaler / Distributor',
        address:
            json['address'] as String? ??
            '123 Market Road, Civil Lines, Azamgarh, UP - 276001',
        email: json['email'] as String? ?? 'ramesh.distributors@shopeasy.in',
        avatarAsset:
            json['avatarAsset'] as String? ?? 'assets/images/user_avatar.png',
        status: json['status'] as String? ?? 'Approved',
        token: json['token'] as String?,
      );
}

class Shop {
  final String id;
  final String name;
  final String initial;
  final String area;
  final double distanceKm;
  final int pendingOrders;
  final int totalOrders;
  final bool isActive;
  final String phone;
  final String address;
  final String ownerName;
  final String topDemand;

  const Shop({
    required this.id,
    required this.name,
    required this.initial,
    required this.area,
    required this.distanceKm,
    required this.pendingOrders,
    required this.totalOrders,
    this.isActive = true,
    required this.phone,
    required this.address,
    required this.ownerName,
    required this.topDemand,
  });
}

class DemandProduct {
  final String id;
  final String name;
  final String category;
  final int totalDemand;
  final double price;
  final String? imageAsset;
  final String unit;

  const DemandProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.totalDemand,
    required this.price,
    this.imageAsset,
    required this.unit,
  });

  DemandProduct copyWith({
    String? id,
    String? name,
    String? category,
    int? totalDemand,
    double? price,
    String? imageAsset,
    String? unit,
  }) {
    return DemandProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      totalDemand: totalDemand ?? this.totalDemand,
      price: price ?? this.price,
      imageAsset: imageAsset ?? this.imageAsset,
      unit: unit ?? this.unit,
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int lowStockThreshold;
  final double pricePerUnit;
  final String? imageAsset;
  final String sku;
  final String warehouseLocation;
  final DateTime? lastRestocked;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
    required this.pricePerUnit,
    this.imageAsset,
    this.sku = 'SKU-WH-01',
    this.warehouseLocation = 'Section A - Rack 04',
    this.lastRestocked,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    int? lowStockThreshold,
    double? pricePerUnit,
    String? imageAsset,
    String? sku,
    String? warehouseLocation,
    DateTime? lastRestocked,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      imageAsset: imageAsset ?? this.imageAsset,
      sku: sku ?? this.sku,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      lastRestocked: lastRestocked ?? this.lastRestocked,
    );
  }
}

class StockMovement {
  final String id;
  final String itemId;
  final String productName;
  final String type; // 'RECEIPT', 'ISSUE', 'ADJUSTMENT'
  final int quantityChange;
  final int balanceAfter;
  final String reason;
  final String performedBy;
  final DateTime timestamp;

  const StockMovement({
    required this.id,
    required this.itemId,
    required this.productName,
    required this.type,
    required this.quantityChange,
    required this.balanceAfter,
    required this.reason,
    required this.performedBy,
    required this.timestamp,
  });
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get subtotal => quantity * price;
}

class DistributorOrder {
  final String id;
  final String shopId;
  final String shopName;
  final String location;
  final int itemCount;
  final double orderAmount;
  final String status; // Pending, Processing, Delivered, Dispatched, Cancelled
  final DateTime date;
  final List<OrderItem> items;
  final String customerPhone;
  final String notes;
  final List<String> statusHistory;

  const DistributorOrder({
    required this.id,
    required this.shopId,
    required this.shopName,
    this.location = 'Azamgarh',
    required this.itemCount,
    required this.orderAmount,
    required this.status,
    required this.date,
    required this.items,
    this.customerPhone = '+91 98765 43210',
    this.notes = 'Regular wholesale replenishment',
    this.statusHistory = const ['Order placed by retailer'],
  });

  DistributorOrder copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? location,
    int? itemCount,
    double? orderAmount,
    String? status,
    DateTime? date,
    List<OrderItem>? items,
    String? customerPhone,
    String? notes,
    List<String>? statusHistory,
  }) {
    return DistributorOrder(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      itemCount: itemCount ?? this.itemCount,
      orderAmount: orderAmount ?? this.orderAmount,
      status: status ?? this.status,
      date: date ?? this.date,
      items: items ?? this.items,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

class RouteStop {
  final int sequence;
  final String shopId;
  final String shopName;
  final String address;
  final String orderId;
  final double orderAmount;
  final String status; // Pending, In Transit, Delivered, Skipped

  const RouteStop({
    required this.sequence,
    required this.shopId,
    required this.shopName,
    required this.address,
    required this.orderId,
    required this.orderAmount,
    this.status = 'Pending',
  });

  RouteStop copyWith({
    int? sequence,
    String? shopId,
    String? shopName,
    String? address,
    String? orderId,
    double? orderAmount,
    String? status,
  }) {
    return RouteStop(
      sequence: sequence ?? this.sequence,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      orderId: orderId ?? this.orderId,
      orderAmount: orderAmount ?? this.orderAmount,
      status: status ?? this.status,
    );
  }
}

class DispatchRoute {
  final String id;
  final String routeName;
  final String assignedDriver;
  final String driverPhone;
  final String vehicleNumber;
  final int stopCount;
  final double distanceKm;
  final String estDuration;
  final String
  status; // On Route, Ready, Pending, Not Started, Completed, Cancelled
  final DateTime dispatchDate;
  final List<String> shopNames;
  final List<RouteStop> stops;
  final List<String> orderIds;
  final List<String> statusHistory;

  const DispatchRoute({
    required this.id,
    required this.routeName,
    required this.assignedDriver,
    required this.driverPhone,
    this.vehicleNumber = 'UP-50-AT-4412',
    required this.stopCount,
    required this.distanceKm,
    required this.estDuration,
    required this.status,
    required this.dispatchDate,
    required this.shopNames,
    this.stops = const [],
    this.orderIds = const [],
    this.statusHistory = const ['Route planned and scheduled'],
  });

  DispatchRoute copyWith({
    String? id,
    String? routeName,
    String? assignedDriver,
    String? driverPhone,
    String? vehicleNumber,
    int? stopCount,
    double? distanceKm,
    String? estDuration,
    String? status,
    DateTime? dispatchDate,
    List<String>? shopNames,
    List<RouteStop>? stops,
    List<String>? orderIds,
    List<String>? statusHistory,
  }) {
    return DispatchRoute(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      stopCount: stopCount ?? this.stopCount,
      distanceKm: distanceKm ?? this.distanceKm,
      estDuration: estDuration ?? this.estDuration,
      status: status ?? this.status,
      dispatchDate: dispatchDate ?? this.dispatchDate,
      shopNames: shopNames ?? this.shopNames,
      stops: stops ?? this.stops,
      orderIds: orderIds ?? this.orderIds,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

class TrackingStep {
  final String title;
  final String time;
  final bool isCompleted;
  final String description;

  const TrackingStep({
    required this.title,
    required this.time,
    required this.isCompleted,
    required this.description,
  });
}

class Shipment {
  final String id;
  final String awbNumber;
  final String orderId;
  final String shopName;
  final String productName;
  final int quantity;
  final String productSummary;
  final String status; // Delivered, In Transit, Out for Delivery, Scheduled
  final String timestamp;
  final String lastUpdate;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String deliveryAddress;
  final List<TrackingStep> trackingSteps;

  const Shipment({
    required this.id,
    required this.awbNumber,
    required this.orderId,
    required this.shopName,
    required this.productName,
    required this.quantity,
    required this.productSummary,
    required this.status,
    required this.timestamp,
    required this.lastUpdate,
    this.driverName = 'Manoj Yadav',
    this.driverPhone = '+91 94151 77889',
    this.vehicleNumber = 'UP-50-AT-4412',
    this.deliveryAddress = 'Azamgarh Central Area',
    required this.trackingSteps,
  });

  Shipment copyWith({
    String? id,
    String? awbNumber,
    String? orderId,
    String? shopName,
    String? productName,
    int? quantity,
    String? productSummary,
    String? status,
    String? timestamp,
    String? lastUpdate,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    String? deliveryAddress,
    List<TrackingStep>? trackingSteps,
  }) {
    return Shipment(
      id: id ?? this.id,
      awbNumber: awbNumber ?? this.awbNumber,
      orderId: orderId ?? this.orderId,
      shopName: shopName ?? this.shopName,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      productSummary: productSummary ?? this.productSummary,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }
}

class AppAlertNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final String type; // demand, low_stock, dispatch, order

  const AppAlertNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    required this.type,
  });

  AppAlertNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isRead,
    String? type,
  }) {
    return AppAlertNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

class Supplier {
  final String id;
  final String name;
  final double totalPurchases;
  final String status; // Active, Pending, Inactive
  final String category;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String lastPurchaseDate;

  const Supplier({
    required this.id,
    required this.name,
    required this.totalPurchases,
    required this.status,
    required this.category,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.lastPurchaseDate,
  });

  Supplier copyWith({
    String? id,
    String? name,
    double? totalPurchases,
    String? status,
    String? category,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? lastPurchaseDate,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      status: status ?? this.status,
      category: category ?? this.category,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalPurchases': totalPurchases,
    'status': status,
    'category': category,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'address': address,
    'lastPurchaseDate': lastPurchaseDate,
  };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
    id: json['id'] as String,
    name: json['name'] as String,
    totalPurchases: (json['totalPurchases'] as num).toDouble(),
    status: json['status'] as String? ?? 'Active',
    category: json['category'] as String? ?? 'FMCG',
    contactPerson: json['contactPerson'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    address: json['address'] as String? ?? '',
    lastPurchaseDate: json['lastPurchaseDate'] as String? ?? 'Today',
  );
}

class SalesmanProfile {
  final String id;
  final String name;
  final String role;
  final int assignedShopsCount;
  final double routeDistanceKm;
  final String status; // On Route, At Shop, Completed, Off Duty
  final String phone;
  final String vehicleNumber;

  const SalesmanProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.assignedShopsCount,
    required this.routeDistanceKm,
    required this.status,
    required this.phone,
    required this.vehicleNumber,
  });

  SalesmanProfile copyWith({
    String? id,
    String? name,
    String? role,
    int? assignedShopsCount,
    double? routeDistanceKm,
    String? status,
    String? phone,
    String? vehicleNumber,
  }) {
    return SalesmanProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedShopsCount: assignedShopsCount ?? this.assignedShopsCount,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }
}

class SalesmanVisit {
  final String id;
  final String shopId;
  final String shopName;
  final String status; // Visited, Pending, Skipped
  final String scheduledTime;
  final String? visitNotes;
  final double? collectedDemandAmount;
  final String? visitedAt;

  const SalesmanVisit({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.status,
    required this.scheduledTime,
    this.visitNotes,
    this.collectedDemandAmount,
    this.visitedAt,
  });

  bool get isVisited => status.toLowerCase() == 'visited';
  bool get isPending => status.toLowerCase() == 'pending';

  SalesmanVisit copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? status,
    String? scheduledTime,
    String? visitNotes,
    double? collectedDemandAmount,
    String? visitedAt,
  }) {
    return SalesmanVisit(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      visitNotes: visitNotes ?? this.visitNotes,
      collectedDemandAmount:
          collectedDemandAmount ?? this.collectedDemandAmount,
      visitedAt: visitedAt ?? this.visitedAt,
    );
  }
}

class StockReportSummary {
  final double totalValuation;
  final int totalSkus;
  final int lowStockCount;
  final double turnoverRatio;
  final List<Map<String, dynamic>> categoryBreakdown;

  const StockReportSummary({
    required this.totalValuation,
    required this.totalSkus,
    required this.lowStockCount,
    required this.turnoverRatio,
    required this.categoryBreakdown,
  });
}

class SalesReportSummary {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final double monthlyGrowthPercent;
  final List<Map<String, dynamic>> topProducts;

  const SalesReportSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.monthlyGrowthPercent,
    required this.topProducts,
  });
}

class PurchaseReportSummary {
  final double totalPurchases;
  final double outstandingPayable;
  final int activeSuppliersCount;
  final List<Map<String, dynamic>> topSuppliers;

  const PurchaseReportSummary({
    required this.totalPurchases,
    required this.outstandingPayable,
    required this.activeSuppliersCount,
    required this.topSuppliers,
  });
}

class ProfitLossSummary {
  final double totalRevenue;
  final double costOfGoodsSold;
  final double grossProfit;
  final double grossMarginPercent;
  final double operatingExpenses;
  final double netProfit;
  final double netMarginPercent;

  const ProfitLossSummary({
    required this.totalRevenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.grossMarginPercent,
    required this.operatingExpenses,
    required this.netProfit,
    required this.netMarginPercent,
  });
}
