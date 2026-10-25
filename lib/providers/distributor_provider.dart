import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/distributor_models.dart';
import '../data/repositories/distributor_repository.dart';

// Single repository instance
final distributorRepositoryProvider = Provider<DistributorRepository>((ref) {
  return DistributorRepository();
});

// Auth State
class AuthState {
  final DistributorUser? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAuthenticated => user != null && user?.token != null;

  AuthState copyWith({
    DistributorUser? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  AuthState build() {
    _init();
    return AuthState(user: _repository.currentUser);
  }

  Future<void> _init() async {
    await _repository.loadPersistedSession();
    state = AuthState(user: _repository.currentUser);
  }

  Future<bool> login(String mobile, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.login(mobile, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(user: null);
  }

  Future<Map<String, dynamic>?> registerDistributor({
    required String businessName,
    required String ownerName,
    required String mobileNumber,
    required String gstNumber,
    required String businessType,
    required String address,
    required List<String> uploadedDocs,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.registerDistributor(
        businessName: businessName,
        ownerName: ownerName,
        mobileNumber: mobileNumber,
        gstNumber: gstNumber,
        businessType: businessType,
        address: address,
        uploadedDocs: uploadedDocs,
      );
      state = state.copyWith(
        isLoading: false,
        user: res['user'] as DistributorUser,
        successMessage: res['message'] as String,
      );
      return res;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> sendPasswordResetOtp(String mobile) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.sendPasswordResetOtp(mobile);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtpAndResetPassword(String mobile, String otp, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyOtpAndResetPassword(mobile, otp, newPassword);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset successfully! Please login with your new credentials.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Shops Provider
enum ShopFilter { all, nearby, topDemands }

class ShopsNotifier extends Notifier<List<Shop>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);
  String _searchQuery = '';
  ShopFilter _filter = ShopFilter.all;

  @override
  List<Shop> build() {
    return _repository.getShops();
  }

  String get searchQuery => _searchQuery;
  ShopFilter get filter => _filter;

  void setSearchQuery(String q) {
    _searchQuery = q.toLowerCase();
    _applyFilters();
  }

  void setFilter(ShopFilter f) {
    _filter = f;
    _applyFilters();
  }

  void _applyFilters() {
    var list = _repository.getShops();

    if (_filter == ShopFilter.nearby) {
      list = list.where((s) => s.distanceKm <= 3.5).toList();
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_filter == ShopFilter.topDemands) {
      list = list.where((s) => s.pendingOrders >= 3).toList();
      list.sort((a, b) => b.pendingOrders.compareTo(a.pendingOrders));
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(_searchQuery) ||
          s.area.toLowerCase().contains(_searchQuery) ||
          s.ownerName.toLowerCase().contains(_searchQuery)).toList();
    }

    state = list;
  }
}

final shopsProvider = NotifierProvider<ShopsNotifier, List<Shop>>(ShopsNotifier.new);

// Demand Provider
class DemandState {
  final String timeRange; // Today, This Week, This Month
  final int forecastUnits;
  final int requestedUnits;
  final int confirmedUnits;
  final int allocatedUnits;
  final List<DemandProduct> topProducts;

  const DemandState({
    this.timeRange = 'Today',
    this.forecastUnits = 420,
    this.requestedUnits = 360,
    this.confirmedUnits = 280,
    this.allocatedUnits = 240,
    required this.topProducts,
  });

  DemandState copyWith({
    String? timeRange,
    int? forecastUnits,
    int? requestedUnits,
    int? confirmedUnits,
    int? allocatedUnits,
    List<DemandProduct>? topProducts,
  }) {
    return DemandState(
      timeRange: timeRange ?? this.timeRange,
      forecastUnits: forecastUnits ?? this.forecastUnits,
      requestedUnits: requestedUnits ?? this.requestedUnits,
      confirmedUnits: confirmedUnits ?? this.confirmedUnits,
      allocatedUnits: allocatedUnits ?? this.allocatedUnits,
      topProducts: topProducts ?? this.topProducts,
    );
  }
}

class DemandNotifier extends Notifier<DemandState> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  DemandState build() {
    return DemandState(topProducts: _repository.getTopDemandProducts());
  }

  void setTimeRange(String range) {
    final baseProducts = _repository.getTopDemandProducts();
    double multiplier = 1.0;
    int forecast = 420;
    int requested = 360;
    int confirmed = 280;
    int allocated = 240;

    if (range == 'Last 7 Days' || range == 'This Week') {
      multiplier = 6.8;
      forecast = 2850;
      requested = 2410;
      confirmed = 1980;
      allocated = 1720;
    } else if (range == 'Last 30 Days' || range == 'This Month') {
      multiplier = 27.14;
      forecast = 11400;
      requested = 9650;
      confirmed = 8200;
      allocated = 7550;
    }

    final scaledProducts = baseProducts.map((p) {
      if (multiplier == 1.0) return p;
      final scaled = (p.totalDemand * multiplier).round();
      return p.copyWith(totalDemand: scaled);
    }).toList();

    state = state.copyWith(
      timeRange: range,
      forecastUnits: forecast,
      requestedUnits: requested,
      confirmedUnits: confirmed,
      allocatedUnits: allocated,
      topProducts: scaledProducts,
    );
  }
}

final demandProvider = NotifierProvider<DemandNotifier, DemandState>(DemandNotifier.new);

// Inventory Provider
class InventoryNotifier extends Notifier<List<InventoryItem>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  List<InventoryItem> build() {
    return _repository.getInventoryItems();
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  int get totalStockUnits => state.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockItemCount => state.where((item) => item.isLowStock).length;

  void setSearchQuery(String q) {
    _searchQuery = q.toLowerCase();
    _apply();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _apply();
  }

  void _apply() {
    var items = _repository.getInventoryItems();
    if (_selectedCategory != 'All') {
      items = items.where((i) => i.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
    }
    state = items;
  }

  void adjustStock(String itemId, int delta) {
    state = state.map((item) {
      if (item.id == itemId) {
        final newQty = (item.quantity + delta).clamp(0, 999999);
        return item.copyWith(quantity: newQty);
      }
      return item;
    }).toList();
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<InventoryItem>>(InventoryNotifier.new);

// Orders Provider
class OrdersNotifier extends Notifier<List<DistributorOrder>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);
  String _statusFilter = 'All';

  @override
  List<DistributorOrder> build() {
    return _repository.getOrders();
  }

  String get statusFilter => _statusFilter;

  void setFilter(String status) {
    _statusFilter = status;
    if (status == 'All') {
      state = _repository.getOrders();
    } else {
      state = _repository.getOrders().where((o) => o.status == status).toList();
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<DistributorOrder>>(OrdersNotifier.new);

// Dispatch Provider
class DispatchNotifier extends Notifier<List<DispatchRoute>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  List<DispatchRoute> build() {
    return _repository.getDispatchRoutes();
  }

  void markRouteInTransit(String routeId) {
    state = state.map((route) {
      if (route.id == routeId) {
        return route.copyWith(status: 'In Transit');
      }
      return route;
    }).toList();
  }

  void markRouteCompleted(String routeId) {
    state = state.map((route) {
      if (route.id == routeId) {
        return route.copyWith(status: 'Completed');
      }
      return route;
    }).toList();
  }
}

final dispatchProvider = NotifierProvider<DispatchNotifier, List<DispatchRoute>>(DispatchNotifier.new);

// Shipments Provider
class ShipmentsNotifier extends Notifier<List<Shipment>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);
  String _awbSearch = '';

  @override
  List<Shipment> build() {
    return _repository.getShipments();
  }

  void searchAwb(String query) {
    _awbSearch = query.trim().toLowerCase();
    if (_awbSearch.isEmpty) {
      state = _repository.getShipments();
    } else {
      state = _repository.getShipments().where((s) =>
          s.awbNumber.toLowerCase().contains(_awbSearch) ||
          s.orderId.toLowerCase().contains(_awbSearch) ||
          s.shopName.toLowerCase().contains(_awbSearch)).toList();
    }
  }
}

final shipmentsProvider = NotifierProvider<ShipmentsNotifier, List<Shipment>>(ShipmentsNotifier.new);

// Notifications Provider
class NotificationsNotifier extends Notifier<List<AppAlertNotification>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  List<AppAlertNotification> build() {
    return _repository.getNotifications();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, List<AppAlertNotification>>(NotificationsNotifier.new);

// Active User Role Provider (Section 9: Role-based navigation)
enum AppRole { distributor, salesman }

class RoleNotifier extends Notifier<AppRole> {
  @override
  AppRole build() => AppRole.distributor;

  void setRole(AppRole role) => state = role;
  void toggleRole() => state = state == AppRole.distributor ? AppRole.salesman : AppRole.distributor;
}

final roleProvider = NotifierProvider<RoleNotifier, AppRole>(RoleNotifier.new);

// Suppliers Provider (Section 6)
class SuppliersNotifier extends Notifier<List<Supplier>> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);
  String _filterCategory = 'All';
  String _searchQuery = '';

  @override
  List<Supplier> build() {
    return _repository.getSuppliers();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  void setCategoryFilter(String category) {
    _filterCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    var list = _repository.getSuppliers();
    if (_filterCategory != 'All') {
      list = list.where((s) => s.category.toLowerCase().contains(_filterCategory.toLowerCase())).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(_searchQuery) ||
          s.contactPerson.toLowerCase().contains(_searchQuery) ||
          s.category.toLowerCase().contains(_searchQuery)).toList();
    }
    state = list;
  }

  void addSupplier(Supplier supplier) {
    _repository.addSupplier(supplier);
    _applyFilters();
  }

  void updateSupplier(Supplier supplier) {
    _repository.updateSupplier(supplier);
    _applyFilters();
  }

  void toggleStatus(String supplierId) {
    final s = _repository.getSuppliers().firstWhere((item) => item.id == supplierId);
    final newStatus = s.status == 'Active' ? 'Inactive' : 'Active';
    _repository.updateSupplier(s.copyWith(status: newStatus));
    _applyFilters();
  }

  void deleteSupplier(String id) {
    _repository.deleteSupplier(id);
    _applyFilters();
  }
}

final suppliersProvider = NotifierProvider<SuppliersNotifier, List<Supplier>>(SuppliersNotifier.new);

// Salesman Coordination Provider (Section 8)
class SalesmanState {
  final SalesmanProfile profile;
  final List<SalesmanVisit> visits;

  const SalesmanState({
    required this.profile,
    required this.visits,
  });

  SalesmanState copyWith({
    SalesmanProfile? profile,
    List<SalesmanVisit>? visits,
  }) {
    return SalesmanState(
      profile: profile ?? this.profile,
      visits: visits ?? this.visits,
    );
  }
}

class SalesmanNotifier extends Notifier<SalesmanState> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  SalesmanState build() {
    return SalesmanState(
      profile: _repository.getSalesmanProfile(),
      visits: _repository.getSalesmanVisits(),
    );
  }

  void updateStatus(String status) {
    _repository.updateSalesmanStatus(status);
    state = state.copyWith(profile: _repository.getSalesmanProfile());
  }

  void completeVisit(String visitId, {String? notes, double? orderAmount}) {
    _repository.updateSalesmanVisit(visitId, 'Visited', notes: notes, orderAmount: orderAmount);
    state = state.copyWith(visits: _repository.getSalesmanVisits());
  }

  void markPending(String visitId) {
    _repository.updateSalesmanVisit(visitId, 'Pending');
    state = state.copyWith(visits: _repository.getSalesmanVisits());
  }
}

final salesmanProvider = NotifierProvider<SalesmanNotifier, SalesmanState>(SalesmanNotifier.new);

// Reports Provider (Section 7)
class ReportsState {
  final StockReportSummary stockReport;
  final SalesReportSummary salesReport;
  final PurchaseReportSummary purchaseReport;
  final ProfitLossSummary profitLossReport;
  final String selectedPeriod;

  const ReportsState({
    required this.stockReport,
    required this.salesReport,
    required this.purchaseReport,
    required this.profitLossReport,
    this.selectedPeriod = 'This Month',
  });

  ReportsState copyWith({
    StockReportSummary? stockReport,
    SalesReportSummary? salesReport,
    PurchaseReportSummary? purchaseReport,
    ProfitLossSummary? profitLossReport,
    String? selectedPeriod,
  }) {
    return ReportsState(
      stockReport: stockReport ?? this.stockReport,
      salesReport: salesReport ?? this.salesReport,
      purchaseReport: purchaseReport ?? this.purchaseReport,
      profitLossReport: profitLossReport ?? this.profitLossReport,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  DistributorRepository get _repository => ref.read(distributorRepositoryProvider);

  @override
  ReportsState build() {
    return ReportsState(
      stockReport: _repository.getStockReport(),
      salesReport: _repository.getSalesReport(),
      purchaseReport: _repository.getPurchaseReport(),
      profitLossReport: _repository.getProfitLossReport(),
    );
  }

  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }

  void refreshReports() {
    state = ReportsState(
      stockReport: _repository.getStockReport(),
      salesReport: _repository.getSalesReport(),
      purchaseReport: _repository.getPurchaseReport(),
      profitLossReport: _repository.getProfitLossReport(),
      selectedPeriod: state.selectedPeriod,
    );
  }
}

final reportsProvider = NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);

// Cart Provider for Product Catalogue (Section 5)
class CartItem {
  final DemandProduct product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({DemandProduct? product, int? quantity}) =>
      CartItem(product: product ?? this.product, quantity: quantity ?? this.quantity);
}

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() => {};

  void addItem(DemandProduct product, {int qty = 1}) {
    final current = state[product.id];
    if (current != null) {
      state = {
        ...state,
        product.id: current.copyWith(quantity: current.quantity + qty),
      };
    } else {
      state = {
        ...state,
        product.id: CartItem(product: product, quantity: qty),
      };
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else {
      final current = state[productId];
      if (current != null) {
        state = {
          ...state,
          productId: current.copyWith(quantity: quantity),
        };
      }
    }
  }

  void removeItem(String productId) {
    final map = Map<String, CartItem>.from(state);
    map.remove(productId);
    state = map;
  }

  void clear() => state = {};

  int get totalItemCount => state.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => state.values.fold(0.0, (sum, item) => sum + item.subtotal);
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(CartNotifier.new);

