-- ==============================================================================
-- SHOPEASY DATABASE SCHEMA MIGRATION
-- Migration Version: 20261025000000
-- Description: Production PostgreSQL schema with Row Level Security (RLS)
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Organizations (Distributor & Enterprise Hubs)
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    trade_name VARCHAR(255),
    gst_number VARCHAR(20) UNIQUE,
    business_type VARCHAR(100) DEFAULT 'Wholesaler / Distributor',
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Profiles (Extended Auth Users)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    org_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    full_name VARCHAR(150) NOT NULL,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    role VARCHAR(50) DEFAULT 'distributor' CHECK (role IN ('distributor', 'salesman', 'supplier', 'admin')),
    avatar_url TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Product Categories
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Products Catalogue
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    sku VARCHAR(100),
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    unit VARCHAR(50) DEFAULT 'units',
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Suppliers Management
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(150),
    phone VARCHAR(20),
    email VARCHAR(255),
    category VARCHAR(100),
    total_purchases NUMERIC(14, 2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Active', 'Pending', 'Inactive')),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Retail Customers / Shops Directory
CREATE TABLE IF NOT EXISTS shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    owner_name VARCHAR(150),
    phone VARCHAR(20),
    area VARCHAR(100),
    address TEXT,
    distance_km NUMERIC(6, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Salesman Profiles & Routes
CREATE TABLE IF NOT EXISTS salesman_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    assigned_shops_count INT DEFAULT 0,
    route_distance_km NUMERIC(6, 2) DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'On Route' CHECK (status IN ('On Route', 'At Shop', 'Completed', 'Off Duty')),
    vehicle_number VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Salesman Visits & Field Coordination
CREATE TABLE IF NOT EXISTS salesman_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    salesman_id UUID REFERENCES salesman_profiles(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    scheduled_time VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Visited', 'Skipped')),
    visit_notes TEXT,
    collected_demand_amount NUMERIC(12, 2) DEFAULT 0.00,
    visited_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. Orders Requisitions
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE SET NULL,
    salesman_id UUID REFERENCES salesman_profiles(id) ON DELETE SET NULL,
    total_amount NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Processing', 'Dispatched', 'Delivered', 'Cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Order Items
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(14, 2) NOT NULL
);

-- 11. Financial Transactions & Key Reports Accounting
CREATE TABLE IF NOT EXISTS financial_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Sale', 'Purchase', 'Expense', 'Payment_Received', 'Payment_Made')),
    amount NUMERIC(14, 2) NOT NULL,
    reference_id VARCHAR(100),
    description TEXT,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_products_org_id ON products(org_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_org_id ON suppliers(org_id);
CREATE INDEX IF NOT EXISTS idx_shops_org_id ON shops(org_id);
CREATE INDEX IF NOT EXISTS idx_visits_salesman ON salesman_visits(salesman_id);
CREATE INDEX IF NOT EXISTS idx_orders_org_id ON orders(org_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_transactions_org ON financial_transactions(org_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE salesman_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE salesman_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;

-- Tenant Isolation Policies: Users can only view & edit records from their own organization
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Org members can view org products"
    ON products FOR ALL
    USING (org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Org members can view and manage suppliers"
    ON suppliers FOR ALL
    USING (org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Org members can view and manage shops"
    ON shops FOR ALL
    USING (org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Org members can view and manage visits"
    ON salesman_visits FOR ALL
    USING (salesman_id IN (
        SELECT sp.id FROM salesman_profiles sp
        JOIN profiles p ON p.id = sp.user_id
        WHERE p.org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid())
    ));

CREATE POLICY "Org members can view and manage orders"
    ON orders FOR ALL
    USING (org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Org members can view transactions"
    ON financial_transactions FOR ALL
    USING (org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid()));

-- ==============================================================================
-- SEED DEMONSTRATION DATA (Matching Prompt Reference Specifications)
-- ==============================================================================
INSERT INTO categories (name, slug, icon) VALUES
('Grocery', 'grocery', 'shopping_basket'),
('Household', 'household', 'home'),
('Personal Care', 'personal_care', 'person')
ON CONFLICT (slug) DO NOTHING;
