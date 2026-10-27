CREATE DATABASE IF NOT EXISTS quikfly_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE quikfly_db;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(255),
    wallet_balance DECIMAL(10, 2) DEFAULT 1450.00,
    role ENUM('customer', 'driver', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. User Saved Addresses
CREATE TABLE IF NOT EXISTS addresses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    label VARCHAR(50) DEFAULT 'Home',
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) DEFAULT 'Bengaluru',
    locality VARCHAR(100) DEFAULT 'Indiranagar',
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Services Catalog (8-Grid on Home and Services directory on Explore)
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    subtitle VARCHAR(100) NOT NULL,
    icon_name VARCHAR(50) NOT NULL,
    category ENUM('everyday', 'travel', 'shopping') NOT NULL,
    is_featured BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 4. Promotional Banners (Hero carousel, Weekend Inspiration, Safety)
CREATE TABLE IF NOT EXISTS banners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('hero', 'story', 'safety') NOT NULL,
    tagline VARCHAR(100),
    title VARCHAR(150) NOT NULL,
    subtitle TEXT,
    button_label VARCHAR(50),
    image_url VARCHAR(255) NOT NULL,
    action_route VARCHAR(100),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 5. Merchants (Popular Near You)
CREATE TABLE IF NOT EXISTS merchants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL,
    rating DECIMAL(2, 1) DEFAULT 4.8,
    delivery_time_min INT DEFAULT 25,
    image_url VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    is_open BOOLEAN DEFAULT TRUE
);

-- 6. Rides
CREATE TABLE IF NOT EXISTS rides (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    driver_id BIGINT NULL,
    service_code VARCHAR(50) NOT NULL,
    status ENUM('pending', 'accepted', 'arrived', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    pickup_lat DECIMAL(10, 8) NOT NULL,
    pickup_lng DECIMAL(11, 8) NOT NULL,
    pickup_address VARCHAR(255) NOT NULL,
    drop_lat DECIMAL(10, 8) NOT NULL,
    drop_lng DECIMAL(11, 8) NOT NULL,
    drop_address VARCHAR(255) NOT NULL,
    fare DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 7. Orders (Food, Grocery, Marketplace)
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    vendor_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    status ENUM('PREPARING', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL DEFAULT 'PREPARING',
    arrival_time_label VARCHAR(100),
    total_amount DECIMAL(10, 2) NOT NULL,
    items_summary TEXT NOT NULL,
    order_date VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 8. Bookings (Buses, Rentals, Flights)
CREATE TABLE IF NOT EXISTS bookings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_code VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    subtitle VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    route VARCHAR(255),
    seat_no VARCHAR(100),
    status ENUM('CONFIRMED', 'RESERVED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    booking_date VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ========================================================
-- SEED DATA (Based on Figma QuikFly Design)
-- ========================================================

-- Demo User (Arjun Kumar)
INSERT INTO users (id, phone, email, full_name, avatar_url, role)
VALUES (1, '+919876548219', 'arjun.kumar@quikfly.app', 'Arjun Kumar', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'customer')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name), phone=VALUES(phone);

-- Default Address for Indiranagar
INSERT INTO addresses (user_id, label, address_line, city, locality, latitude, longitude, is_default)
VALUES (1, 'Home', '100ft Road, Indiranagar', 'Bengaluru', 'Indiranagar', 12.9784, 77.6408, TRUE);

-- Services
INSERT INTO services (code, title, subtitle, icon_name, category, is_featured, sort_order) VALUES
('bike_taxi', 'Bike Taxi', 'Fast pickup', 'two_wheeler', 'everyday', TRUE, 1),
('car_taxi', 'Car Taxi', 'City rides', 'directions_car', 'everyday', TRUE, 2),
('food', 'Food', 'Near you', 'restaurant', 'everyday', TRUE, 3),
('grocery', 'Grocery', 'Daily needs', 'local_grocery_store', 'everyday', TRUE, 4),
('bus', 'Bus', 'Intercity', 'directions_bus', 'travel', TRUE, 5),
('delivery', 'Delivery', 'Send parcels', 'local_shipping', 'everyday', TRUE, 6),
('rentals', 'Rentals', 'Drive your way', 'car_rental', 'travel', TRUE, 7),
('marketplace', 'Marketplace', 'Shop local', 'storefront', 'shopping', TRUE, 8),
('buy_sell', 'Buy & Sell', 'Used items', 'swap_horiz', 'shopping', FALSE, 9),
('travel', 'Travel', 'Getaways', 'flight_takeoff', 'travel', FALSE, 10),
('flights_hotels', 'Flights & Hotels', 'Getaway partner packs', 'hotel', 'travel', FALSE, 11)
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- Banners
INSERT INTO banners (type, tagline, title, subtitle, button_label, image_url, action_route, sort_order) VALUES
('hero', 'ONE APP, EVERY DAY.', 'Move smarter. Live easier.', 'Bikes, food, shopping and multi-vendor delivery wherever you are.', 'Explore services', 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=800', '/explore', 1),
('story', 'CURATED GETAWAYS', 'Breathe in the hills', 'Curated weekend escapes from Bengaluru.', 'Explore trips', 'assets/images/ex.jpg', '/trips/hills', 2),
('safety', NULL, 'Your safety comes first', '24/7 support & emergency buddy services', NULL, '', '/safety', 3);

-- Popular Merchants
INSERT INTO merchants (name, category, rating, delivery_time_min, image_url, latitude, longitude) VALUES
('Spice & Co.', 'North Indian & Biryani', 4.7, 25, 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400', 12.9716, 77.6412),
('Fresh Basket', 'Farm Fresh Groceries & Dairy', 4.9, 18, 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400', 12.9730, 77.6430),
('The Roastery', 'Artisanal Coffee & Bakery', 4.8, 20, 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400', 12.9745, 77.6455);

-- Orders Seed
INSERT INTO orders (order_number, user_id, vendor_name, category, status, arrival_time_label, total_amount, items_summary, order_date) VALUES
('QF-071833', 1, 'Spice & Co.', 'FOOD', 'PREPARING', 'Arrives in 24-28 min', 436.00, 'Butter Chicken Boneless, 2x Garlic Naan, Jeera Rice', '22 Oct'),
('QF-068912', 1, 'Fresh Basket', 'GROCERY', 'DELIVERED', 'Delivered • 16 Jul', 782.00, 'Organic Farm Milk (1L), Country Eggs, Fresh Spinach, Kashmiri Apples', '16 Jul'),
('QF-065401', 1, 'Nova Audio', 'ELECTRONICS', 'SHIPPED', 'Shipped • 14 Jul', 2849.00, 'Nova Wireless ANC Earbuds Pro, Braided USB-C Fast Cable', '14 Jul')
ON DUPLICATE KEY UPDATE status=VALUES(status), total_amount=VALUES(total_amount);

-- Bookings Seed
INSERT INTO bookings (booking_code, user_id, title, subtitle, price, route, seat_no, status, booking_date) VALUES
('BK-89211', 1, 'Bus to Mysuru', '20 Jul • Confirmed', 1240.00, 'Indiranagar, BLR → Suburb Bus Stand, Mysuru', 'Seat 14A (Window)', 'CONFIRMED', '20 Jul'),
('BK-77402', 1, 'Tata Nexon rental', '12-14 Jul • Reserved', 4800.00, 'Self-Drive Pickup: Indiranagar Hub', 'Vehicle: Tata Nexon EV Max', 'RESERVED', '12 Jul')
ON DUPLICATE KEY UPDATE price=VALUES(price), status=VALUES(status);

-- 9. User Preferences Table
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id BIGINT PRIMARY KEY,
    push_notifications BOOLEAN DEFAULT TRUE,
    promotional_alerts BOOLEAN DEFAULT FALSE,
    biometric_lock BOOLEAN DEFAULT TRUE,
    language VARCHAR(50) DEFAULT 'English (US)',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO user_preferences (user_id, push_notifications, promotional_alerts, biometric_lock, language)
VALUES (1, TRUE, FALSE, TRUE, 'English (US)')
ON DUPLICATE KEY UPDATE language=VALUES(language);


