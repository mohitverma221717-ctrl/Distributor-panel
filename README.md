# ShopEasy — Distributor & Salesman Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-blueviolet)](https://riverpod.dev)
[![Design](https://img.shields.io/badge/UI-Frosted%20Glassmorphism-FF7A00)](lib/app/theme/)
[![Tests](https://img.shields.io/badge/Tests-35%20Passed-brightgreen)](test/distributor_app_test.dart)
[![Analysis](https://img.shields.io/badge/Analyzer-0%20Issues-brightgreen)](lib/)

ShopEasy is a production-oriented, mobile-first Flutter application engineered for distributors and field sales executives (Feri Wala / Salesman). The interface precisely replicates the reference glassmorphic design language—complete with frosted glass cards, dynamic background gradients, vivid glowing orange accents, and responsive touch layouts.

---

## 📱 Replicated Reference Screens & Features

### 1. Shipment Tracking (`/shipments`) — *Pixel-Accurate Reference Implementation*
* **Visual Match to Reference**: Exact replication of the supplied Shipment Tracking screenshot.
* **Header**: ShopEasy orange 3D bag logo with curved 'S', bold *"ShopEasy"* title, *"Your Local Shop, Our Priority"* tagline, frosted circular glass notification button with red unread indicator, and frosted circular profile avatar.
* **Title & Subtitle**: Large translucent glass panel with *"Shipment Tracking"* (22px w800 white) and *"Track your orders in real-time"*.
* **Search & Filter Controls**:
  * Wide rounded translucent search bar (*"Search by AWB / Order ID..."*) supporting real-time case-insensitive search by AWB, order ID, product name, or shop name with a clear button.
  * Separate rounded glass filter button opening a status filter bottom sheet (*All, Scheduled, In Transit, Out for Delivery, Delivered*).
* **Reference Demonstration Shipments (GlassShipmentCard)**:
  * **Shipment 1**: `AWB0012345` — Cyan/blue circular truck icon — `Rice (25kg) • 12 units` — `Sharma Gen. Store` — `● Delivered` (Green badge) — `Today, 10:24 AM` — Trailing chevron.
  * **Shipment 2**: `AWB0012356` — Cyan/blue circular truck icon — `Cooking Oil (1L) • 10 units` — `Gupta Kirana Store` — `● In Transit` (Blue badge) — `Today, 08:45 AM` — Trailing chevron.
  * **Shipment 3**: `AWB0012367` — Amber/orange circular truck icon — `Wheat Flour (10kg) • 8 units` — `Verma Provision Store` — `● Out for Delivery` (Orange badge) — `Today, 07:25 AM` — Trailing chevron.
  * **Shipment 4**: `AWB0012378` — Pink/red circular truck icon — `Sugar (1kg) • 20 units` — `Singh Traders` — `● Scheduled` (Muted blue/gray badge) — `Today, 06:30 PM` — Trailing chevron.
* **Interactive Shipment Details & Tracking Timeline**:
  * Tapping any shipment card opens the **Shipment Details Modal Sheet** with cargo details, delivery address, assigned driver & contact, delivery van number, step-by-step vertical tracking timeline with milestone icons, and authorized workflow transitions:
    * *Scheduled*: `Dispatch (Mark In Transit)`.
    * *In Transit*: `Mark Out for Delivery`.
    * *Out for Delivery*: `Confirm Handover (Delivered)`.
* **Bottom Navigation Dock**:
  * 5 items: **Home** (`/dashboard`), **Demand** (`/demand`), **Orders** (`/orders`), **Inventory** (`/inventory`), and **More** (`/more`).
  * Orders tab selected with orange highlight and neon underline indicator matching the reference screenshot.

### 2. Dispatch Planning (`/dispatch`) — *Pixel-Accurate Reference Implementation*
* **Visual Match to Reference**: Exact replication of the supplied Dispatch Planning screenshot.
* **Header**: ShopEasy orange 3D bag logo with curved 'S', bold *"ShopEasy"* title, *"Your Local Shop, Our Priority"* tagline, frosted circular glass notification button with red unread indicator, and frosted circular profile avatar.
* **Dispatch Planning Heading & Date Selector**:
  * Title: *"Dispatch Planning"* & Subtitle: *"Plan routes, deliver faster"*.
  * Date selector: Translucent rounded glass container with calendar icon, selected date (*24 Apr 2025*), and dropdown chevron opening a full date picker with dynamic route reloading.
* **Three Dispatch Summary Cards**:
  * **Card A (Total Orders)**: Orange cube package icon, *"Total Orders"*, bold **`12`**, right-side chevron leading to orders.
  * **Card B (Assigned Routes)**: Mint-green person/assignment icon, *"Assigned Routes"*, bold **`4`**, right-side chevron.
  * **Card C (Pending Dispatch)**: Violet/purple box icon, *"Pending Dispatch"*, bold **`6`**, right-side chevron.
* **Routes Section & View All**:
  * *"Routes"* heading with horizontal frosted divider line and translucent rounded *"View All >"* button opening all active routes.
* **Reference Route Cards (GlassRouteCard)**:
  * **Route A - Main Market**: Amber/orange location badge, 5 Stops, 18 km, 2h 30m, `● On Route` (Green badge), orange gradient **View >** button.
  * **Route B - Mubarikabad**: Gold/yellow location badge, 5 Stops, 18 km, 2h 10m, `● Ready` (Blue badge), orange gradient **View >** button.
  * **Route C - Deotgaon**: Pink/red location badge, 4 Stops, 16 km, 1h 45m, `● Pending` (Orange badge), orange gradient **View >** button.
  * **Route D - Kochbazar**: Purple location badge, 5 Stops, 24 km, 3h 20m, `● Not Started` (Muted gray/blue badge), orange gradient **View >** button.
* **Interactive Route Details & Authorized Workflow**:
  * Tapping **View** opens the **Route Details Modal Sheet** featuring assigned driver information (*Manoj Yadav, Suresh Verma, etc.*), driver contact, vehicle registration number, stop-by-stop delivery sequence with linked order IDs and amounts, complete audit history, and status progression actions:
    * *Not Started / Pending*: `Mark as Ready` (moves to Ready).
    * *Ready*: `Start Route (Depart)` (moves to On Route).
    * *On Route*: `Complete All Deliveries` (moves to Completed).
* **Bottom Navigation Dock**:
  * 5 items: **Home** (`/dashboard`), **Demand** (`/demand`), **Orders** (`/orders`), **Inventory** (`/inventory`), and **More** (`/more`).
  * Orders tab selected with orange highlight and neon underline indicator matching the reference screenshot.

### 2. Orders Management (`/orders`) — *Pixel-Accurate Reference Implementation*
* **Visual Match to Reference**: Exact replication of the supplied Orders Panel screenshot.
* **Header**: ShopEasy orange 3D bag logo with curved 'S', bold *"ShopEasy"* title, *"Your Local Shop, Our Priority"* tagline, frosted circular glass notification button with red unread indicator, and frosted circular profile avatar.
* **Dynamic Status Filter Tabs (with Live Counts)**:
  * **Tab 1: All (12)**: Grid icon, vibrant orange gradient background in active state, white text/icon.
  * **Tab 2: Pending (4)**: Clock icon, translucent frosted glass background, dynamic pending count.
  * **Tab 3: Processing (4)**: Settings/gear icon, translucent frosted glass background, dynamic processing count.
  * **Tab 4: Delivered (2)**: Checkmark icon, translucent frosted glass background, dynamic delivered count.
* **Translucent Orders Table Panel**:
  * Large translucent frosted glass card containing column headings: **Shop**, **Items**, **Amount**, **Status**.
  * Reusable `GlassOrderCard` with shop icon circle (custom gradients for each shop), shop name, location pin with location name, item count, Indian Rupee currency amount, status pill badge, and navigation chevron.
* **Reference Demonstration Orders**:
  * **Order 1**: `Sharma Gen. Store` — Deoganj — 2 items — **₹ 2,460** — `Pending` (Orange clock badge).
  * **Order 2**: `Gupta Kirana Store` — Main Bazar — 4 items — **₹ 4,120** — `Processing` (Blue gear badge).
  * **Order 3**: `Verma Provision Store` — Kachhpura — 3 items — **₹ 2,780** — `Processing` (Blue gear badge).
  * **Order 4**: `Singh Traders` — Nawabganj — 5 items — **₹ 6,000** — `Delivered` (Green check badge).
* **Interactive Order Details & Authorized Actions**:
  * Tapping any order opens the **Order Details Modal Sheet** featuring order ID, timestamp, shop contact information, line-by-line item breakdown with unit prices and subtotals, full status audit trail, and state-machine transitions:
    * *Pending*: `Confirm Order` (moves to Processing), `Cancel Order`
    * *Processing*: `Dispatch Order` (moves to Dispatched)
    * *Dispatched*: `Mark as Delivered` (automatically updates inventory and records stock deduction)
* **Bottom Navigation Dock**:
  * 5 items: **Home** (`/dashboard`), **Demand** (`/demand`), **Orders** (`/orders`), **Inventory** (`/inventory`), and **More** (`/more`).
  * **Orders Tab Highlight**: Active orange highlighted frosted glass card, orange shopping bag icon, bold orange label, and neon orange horizontal underline bar indicator.

### 2. Warehouse Inventory (`/inventory`) — *Critical Reference Requirement*
* **Pixel-Accurate Visual Replication**: Exact recreation of the supplied reference screenshot.
* **Header**: ShopEasy orange 3D bag logo with white curved 'S', white bold *"ShopEasy"* title, *"Your Local Shop, Our Priority"* tagline, frosted circular glass notification button with red unread indicator dot, and frosted circular profile avatar.
* **Heading & Subtitle**: *"Warehouse Inventory"* (24px w800 white) and *"Manage your stock, keep business moving"*.
* **Dual Summary Cards**:
  * **Total Stock**: Circular glowing cyan/blue cube badge, *"Total Stock"*, bold **`8,420` units**, and navigation chevron `>` leading to detailed inventory reports.
  * **Low Stock Items**: Circular glowing red warning badge, *"Low Stock Items"*, bold **`12` items**, and navigation chevron `>` toggling low-stock filters.
* **Frosted Search & Filter**:
  * Pill-shaped frosted search bar with live text search across product names, SKUs, and categories with clear button.
  * Rounded square frosted glass filter button opening a comprehensive filter bottom sheet (Status: *All, In Stock, Low Stock, Out of Stock*; Categories: *Grains, Oils, Flour, Sweeteners, Beverages, Pulses, etc.*; Sort: *Default, High to Low, Low to High, A-Z*).
* **Reference Product Table (Frosted Glass Panel)**:
  * Headers: Blue glowing 3D cube icon + **Product**, **Stock**, and **Status**.
  * **Product 1**: `Rice (25kg)` — Stock: **420** — Status: `● In Stock` (Mint-green pill badge) — Trailing chevron.
  * **Product 2**: `Cooking Oil (1L)` — Stock: **360** — Status: `● In Stock` (Mint-green pill badge) — Trailing chevron.
  * **Product 3**: `Wheat Flour (10kg)` — Stock: **280** — Status: `● In Stock` (Mint-green pill badge) — Trailing chevron.
  * **Product 4**: `Sugar (1kg)` — Stock: **240** — Status: `● Low Stock` (Salmon/peach pill badge) — Trailing chevron.
  * **Product 5**: `Tea (1kg)` — Stock: **227** — Status: `● In Stock` (Mint-green pill badge) — Trailing chevron.
* **Interactive Operations & Movement Log**:
  * Tapping any row opens the **Inventory Details Sheet** with SKU, warehouse bay location, and unit price.
  * Fast stock adjustment buttons (`-10`, `-1`, `+1`, `+10`) with live feedback.
  * Custom adjustment dialog (Receipt vs Issue with reference note) and reorder threshold editor.
  * Real-time **Stock Movement History** auditing every adjustment with operator, timestamp, and balance tracking.
* **Bottom Navigation Dock**:
  * 5 items: **Home** (`/dashboard`), **Demand** (`/demand`), **Orders** (`/orders`), **Inventory** (`/inventory`), and **More** (`/more`).
  * **Inventory Tab Highlight**: Active orange highlighted frosted glass card, orange 3D cube icon, bold orange label, and neon orange horizontal underline bar indicator.

### 2. Product Catalogue (`/products`)
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

### 4. Salesman Coordination / Field Beat Management (`/salesman`) — *Pixel-Accurate Reference Implementation*
* **Visual Match to Reference**: Complete reproduction of the supplied Salesman Coordination reference screenshot.
* **Atmospheric Glassmorphic Background**: Layered soft sky blue, peach, orange, and light blue gradient background with ambient radial glow orbs and subtle frosted glass blur.
* **Brand Header**:
  * ShopEasy 3D orange shopping bag logo with white curved 'S' icon.
  * Crisp bold *"ShopEasy"* branding in pure white typography (`26px, w800`).
* **Title & Segmented Tab Panel**:
  * Large frosted glass card with *"Salesman Coordination"* heading (`20px, w800, white`).
  * Two-option segmented tab control:
    * **Today's Visits**: Active orange text (`#FF7A00`), subtle translucent selected pill background, and orange horizontal underline indicator bar.
    * **Visit History**: Muted slate-blue text (`#5A7596`), displaying historical completed visits.
* **Salesman Profile Card**:
  * Circular portrait photograph of **Rohit Kumar** with crisp white circular border.
  * Salesman details:
    * Name: **Rohit Kumar** in bold dark navy text (`#162544`, `18px, w800`).
    * Role: **Salesman** in muted slate-blue (`#5A7596`).
    * Stats: **Assigned Shops: 5  |  22 km** in muted slate-blue (`#5A7596`).
  * Right status badge: **`● On Route`** with green location-pin icon in a soft mint-green translucent pill badge (`#D4F7DF`, `#16A34A`).
  * Tappable to open field status update modal (`On Route`, `At Shop`, `Completed`, `Off Duty`).
* **Today's Schedule Panel & Reference Rows**:
  * Large frosted glass card with heading *"Today's Schedule"*.
  * Reusable `GlassScheduleRow` widget supporting flexible layout, overflow prevention, and custom status pills:
    * **Row 1**: `Sharma Gen. Store` — Circular green shop icon — `✔ Visited` (green checkmark badge) — `9:30 AM`.
    * **Row 2**: `Gupta Kirana Store` — Circular green shop icon — `✔ Visited` (green checkmark badge) — `11:45 AM`.
    * **Row 3**: `Verma Provision Store` — Circular orange shop icon — `◆ Pending` (orange diamond badge) — `2:00 PM`.
    * **Row 4**: `Singh Traders` — Circular orange shop icon — `◆ Pending` (orange diamond badge) — `4:30 PM`.
* **Interactive Visit Workflow**:
  * Tapping any schedule row opens the **Visit Action Bottom Sheet** to inspect visit details, input collected demand/order amounts (₹), record field observations, and toggle between *Complete Visit* and *Mark as Pending*.
* **Bottom Navigation Dock**:
  * 5 destinations: **Home**, **Demand**, **Orders**, **Inventory**, **More**.
  * **Home** tab selected with dark navy icon, label, and orange horizontal underline indicator.

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

# 4. Run automated test suite (39 tests)
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
* **Automated Tests**: **39/39 passed** in `test/distributor_app_test.dart` and `test/widget_test.dart`:
  * `DistributorRepository` unit tests (Authentication, Registration, Validation, Mock Persistence).
  * `ProductCatalogueScreen` UI, search, category chip filtering, and Add-to-cart tests.
  * `SupplierManagementScreen` CRUD operations, search, and Key Reports navigation.
  * `SalesmanCoordinationScreen` profile, segmented tabs, reference schedule rows, visit action modal, and history.
  * `KeyReportsScreen` mathematical consistency across Stock, Sales, Purchase, and P&L.
  * `OrdersScreen` reference UI, status counts, line items, fulfillment workflow, and narrow screen responsiveness (375x812 & 360x800).
  * `DispatchScreen` 4 reference routes, stops, metrics, and route departure transitions.
  * `ShipmentsScreen` reference shipments, AWB tracking, and live search.
  * `GlassComponents` touch target and rendering tests.
