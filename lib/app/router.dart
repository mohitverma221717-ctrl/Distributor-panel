import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/demand/demand_screen.dart';
import '../features/dispatch/dispatch_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/products/product_catalogue_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/salesman/salesman_coordination_screen.dart';
import '../features/shipments/shipments_screen.dart';
import '../features/shops/shop_directory_screen.dart';
import '../features/suppliers/supplier_management_screen.dart';
import '../providers/distributor_provider.dart';
import 'shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = ref.read(authProvider).isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuth && !isAuthRoute) {
        return '/login';
      }
      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Authenticated Shell with 5 bottom tabs matching reference image:
      // Home (0) | Demand (1) | Products (2) | Orders (3) | More (4)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final loc = state.uri.path;
          int index = 0;
          if (loc.startsWith('/demand')) {
            index = 1;
          } else if (loc.startsWith('/products')) {
            index = 2;
          } else if (loc.startsWith('/orders')) {
            index = 3;
          } else if (loc.startsWith('/more') || loc.startsWith('/profile')) {
            index = 4;
          }
          return MainShellScreen(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/demand',
            builder: (context, state) => const DemandScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductCatalogueScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Specialized Feature Routes
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SupplierManagementScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
          return KeyReportsScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/salesman',
        builder: (context, state) => const SalesmanCoordinationScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/shops',
        builder: (context, state) => const ShopDirectoryScreen(),
      ),
      GoRoute(
        path: '/dispatch',
        builder: (context, state) => const DispatchScreen(),
      ),
      GoRoute(
        path: '/shipments',
        builder: (context, state) => const ShipmentsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
