# ShopEasy — Distributor & Salesman Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-blueviolet)](https://riverpod.dev)
[![Design](https://img.shields.io/badge/UI-Frosted%20Glassmorphism-FF7A00)](lib/app/theme/)
[![Tests](https://img.shields.io/badge/Tests-31%20Passed-brightgreen)](test/distributor_app_test.dart)
[![Analysis](https://img.shields.io/badge/Analyzer-0%20Issues-brightgreen)](lib/)

ShopEasy is a production-oriented, mobile-first Flutter application engineered for distributors and field sales executives (Feri Wala / Salesman). The interface precisely replicates the reference glassmorphic design language—complete with frosted glass cards, dynamic background gradients, vivid glowing orange accents, and responsive touch layouts.

---

## 📱 Replicated Reference Screens & Features

### 1. Product Catalogue (`/products`)
* **Visual Fidelity**: Frosted top app bar with ShopEasy logo bag, title (*"ShopEasy - Your Local Shop, Our Priority"*), live unread notification badge, and profile avatar.
* **Search & Filters**: Frosted glass search field with clear action, filter modal dialog with sorting by price/stock, and category chips (*All, Grocery, Household, Personal Care*).
* **Reference Inventory Products**:
  * **Rice (25kg)** — ₹1,250 | Stock: 420 | `In Stock`
  * **Cooking Oil (1L)** — ₹160 | Stock: 360 | `In Stock`
  * **Wheat Flour (10kg)** — ₹280 | Stock: 280 | `In Stock`
  * **Sugar (1kg)** — ₹45 | Stock: 500 | `In Stock`
* **Interactive Actions**: Glowing orange **+ Add** buttons with tactile quantity increment, stock limits, and a frosted glass order drawer bottom sheet for immediate requisition review.

### 2. Supplier Management (`/suppliers`)
* **Branded Interface**: Tabbed view (*Suppliers, Reports & Analytics, Settings*).
* **Demonstration Suppliers**:
  * **ABC Foods Ltd.** — ₹2,50,000 Total Purchases — `Active`
  * **Sunrise FMCG** — ₹1,65,000 Total Purchases — `Active`
  * **Global Partners** — ₹1,20,000 Total Purchases — `Active`
* **Operations**: Add Supplier glass modal form with form validation, real-time supplier search, status toggle (Active/Inactive), and detailed purchase history bottom sheet.

### 3. Key Financial & Inventory Reports (`/reports`)
* **Stock Report**: Total warehouse valuation (₹18.4L), total SKUs (48), low-stock warning count (6), category breakdowns.
* **Sales Report**: Total revenue (₹12.85L), completed delivery orders (142), average order ticket (₹9,049).
* **Purchase Report**: Total procurement purchases (₹9.40L), pending bills, and active supplier order metrics.
* **Profit & Loss**: Gross Profit (₹3.45L), COGS (₹9.40L), Operating Expenses (₹85,000), and Net Distribution Profit (₹2.60L, 20.2% Net Margin).
* **Interactive Filters**: Period filter chips (*Today, This Week, This Month, This Quarter*) and report export action.

### 4. Salesman Coordination / Field Panel (`/salesman`)
* **Field Executive Profile**: Rohit Kumar (Role: Salesman, 5 Assigned Shops, 22 km Route Distance, Status: `On Route`).
* **Route Status Controls**: On-tap dialog to update status (*On Route, At Shop, Break, Finished Route*).
* **Today's Schedule & Visits**:
  * **Sharma Gen. Store** — Visited (9:30 AM)
  * **Gupta Kirana Store** — Visited (11:45 AM)
  * **Verma Provision Store** — Pending (2:00 PM)
  * **Singh Traders** — Pending (4:30 PM)
* **Visit Operations**: Modal check-in sheet to record visit notes, capture order demand amount (₹), and mark pending visits as complete.

### 5. Distributor Dashboard & Aggregated Demand
* Real-time metrics: Total Demand (₹1,58,400), Warehouse Stock (82%), Active Retailers (42), Out for Delivery (18).
* Quick action shortcuts to Requisition, Stock Allocation, Field Route map, and Invoice generation.

---

## 🎨 Centralized Glassmorphism Design System

Located in `lib/app/theme/` and `lib/shared/widgets/`:

| File | Purpose |
|------|---------|
| [`lib/app/theme/app_colors.dart`](lib/app/theme/app_colors.dart) | Curated color palette: vibrant orange glow gradients, translucent whites, borders, and semantic status indicators. |
| [`lib/app/theme/app_typography.dart`](lib/app/theme/app_typography.dart) | Google Fonts (*Plus Jakarta Sans*) typographic scale. |
| [`lib/app/theme/app_dimensions.dart`](lib/app/theme/app_dimensions.dart) | Centralized border radii (16, 20, 24, 28), padding tokens, and blur sigmas (12–25px). |
| [`lib/app/theme/glass_theme.dart`](lib/app/theme/glass_theme.dart) | Reusable `BoxDecoration` definitions for frosted cards, translucent borders, and search inputs. |
| [`lib/shared/widgets/glass_components.dart`](lib/shared/widgets/glass_components.dart) | Production widgets: `GlassContainer`, `GlassCard`, `GlassButton`, `GlassSearchBar`, `GlassTabBar`, `GlassInputField`, `GlassStatusBadge`, `GlassIconButton`, `showGlassDialog`, `showGlassBottomSheet`. |

---

## 🗄️ Backend Architecture & Supabase Integration

### Database Schema Migration
A complete PostgreSQL migration script with Row-Level Security (RLS) is provided at:
👉 [`supabase/migrations/20261025000000_shopeasy_schema.sql`](supabase/migrations/20261025000000_shopeasy_schema.sql)

**Entities Defined**:
1. `profiles` — User identity, role (`distributor`, `salesman`, `retailer`, `admin`).
2. `organizations` — Distributor entity and multi-tenant scoping.
3. `categories` — Product categories (`Grocery`, `Household`, `Personal Care`, etc.).
4. `products` — SKU details, unit prices, warehouse inventory quantities.
5. `suppliers` — Vendor profiles, payment records, and procurement totals.
6. `shops` — Assigned retail accounts with geo-coordinates and contact details.
7. `salesman_profiles` — Route assignments, active vehicles, and live duty statuses.
8. `salesman_visits` — Daily beat schedules, visit timestamps, and collected demand orders.
9. `orders` & `order_items` — Wholesale distribution orders and fulfillment lifecycle.
10. `financial_transactions` — Debit/credit ledger and payment reconciliation.
11. `audit_logs` — Immutable audit trail of critical distributor transactions.

### Offline-First Fallback
[`lib/core/services/supabase_service.dart`](lib/core/services/supabase_service.dart) and [`lib/data/repositories/distributor_repository.dart`](lib/data/repositories/distributor_repository.dart) implement a graceful offline-first fallback. If Supabase credentials (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) are not supplied via environment variables, the application runs persistently against local `SharedPreferences` cache without crashing.

---

## 🚀 Getting Started & Build Instructions

### Prerequisites
* Flutter SDK (3.13.0 or higher)
* Dart SDK (3.0.0 or higher)
* Android Studio / Xcode (for native compilation)

### Setup & Run
```bash
# 1. Clone repository & change directory
cd "Distributor pannel of D2P"

# 2. Install dependencies
flutter pub get

# 3. Verify static analysis (0 warnings / 0 errors)
flutter analyze

# 4. Run automated test suite (31 tests)
flutter test

# 5. Run on device / emulator
flutter run
```

### Running with Live Supabase Backend
To connect to your cloud Supabase instance:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

### Building Release APK
```bash
flutter build apk --release
```

---

## 🧪 Verification & QA Results

* **Analyzer**: `flutter analyze` completed with **0 issues found**.
* **Automated Tests**: **31/31 passed** in `test/distributor_app_test.dart` and `test/widget_test.dart`:
  * `DistributorRepository` unit tests (Authentication, Registration, Validation, Mock Persistence).
  * `ProductCatalogueScreen` UI, search, category chip filtering, and Add-to-cart tests.
  * `SupplierManagementScreen` CRUD operations, search, and Key Reports navigation.
  * `SalesmanCoordinationScreen` schedule updates, visit completion dialog, and route status.
  * `KeyReportsScreen` mathematical consistency across Stock, Sales, Purchase, and P&L.
  * `GlassComponents` touch target and rendering tests.
