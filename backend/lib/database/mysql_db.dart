import 'dart:io';
import 'package:mysql_client/mysql_client.dart';
import 'package:quikfly_core/quikfly_core.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  MySQLConnectionPool? _pool;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    final host = Platform.environment['MYSQL_HOST'] ?? '127.0.0.1';
    final port = int.tryParse(Platform.environment['MYSQL_PORT'] ?? '3306') ?? 3306;
    final user = Platform.environment['MYSQL_USER'] ?? 'quikfly';
    final password = Platform.environment['MYSQL_PASSWORD'] ?? 'quikfly_password';
    final database = Platform.environment['MYSQL_DATABASE'] ?? 'quikfly_db';

    int attempts = 0;
    const maxAttempts = 6;
    while (attempts < maxAttempts) {
      attempts++;
      try {
        print('🔄 Connecting to MySQL at $host:$port (DB: $database, User: $user, attempt $attempts/$maxAttempts)...');
        _pool = MySQLConnectionPool(
          host: host,
          port: port,
          userName: user,
          password: password,
          databaseName: database,
          maxConnections: 5,
        );

        // Test connection with a simple query
        await _pool!.execute('SELECT 1;');
        _isConnected = true;
        print('✅ Successfully connected to MySQL database: $database');
        return;
      } catch (e) {
        _isConnected = false;
        if (attempts < maxAttempts) {
          print('⏳ MySQL not ready yet ($e). Retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
        } else {
          print('⚠️ Notice: Could not connect to live MySQL after $maxAttempts attempts ($e).');
          print('💡 Running in development fallback mode using high-fidelity Figma demo data.');
          print('👉 Set MYSQL_USER & MYSQL_PASSWORD in environment or run docker compose to use live MySQL.');
        }
      }
    }
  }

  // --- Catalog Queries ---

  Future<List<ServiceItem>> getServices({String? category, bool? featuredOnly}) async {
    if (_isConnected && _pool != null) {
      try {
        final query = StringBuffer('SELECT * FROM services WHERE is_active = TRUE');
        final params = <String, dynamic>{};

        if (category != null && category.toLowerCase() != 'all') {
          query.write(' AND category = :cat');
          params['cat'] = category.toLowerCase();
        }
        if (featuredOnly == true) {
          query.write(' AND is_featured = TRUE');
        }
        query.write(' ORDER BY sort_order ASC;');

        final results = await _pool!.execute(query.toString(), params);
        final list = <ServiceItem>[];
        for (final row in results.rows) {
          list.add(ServiceItem.fromJson(row.assoc()));
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        print('Error querying services from MySQL: $e');
      }
    }

    // High fidelity fallback matching Figma
    return _mockServices.where((s) {
      if (category != null && category.toLowerCase() != 'all') {
        if (s.category.name != category.toLowerCase()) return false;
      }
      if (featuredOnly == true && !s.isFeatured) return false;
      return true;
    }).toList();
  }

  Future<List<BannerItem>> getBanners({String? type}) async {
    if (_isConnected && _pool != null) {
      try {
        final query = StringBuffer('SELECT * FROM banners WHERE is_active = TRUE');
        final params = <String, dynamic>{};
        if (type != null) {
          query.write(' AND type = :type');
          params['type'] = type;
        }
        query.write(' ORDER BY sort_order ASC;');

        final results = await _pool!.execute(query.toString(), params);
        final list = <BannerItem>[];
        for (final row in results.rows) {
          list.add(BannerItem.fromJson(row.assoc()));
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        print('Error querying banners from MySQL: $e');
      }
    }

    // High fidelity fallback
    return _mockBanners.where((b) {
      if (type != null && b.type.name != type) return false;
      return true;
    }).toList();
  }

  Future<List<MerchantItem>> getPopularMerchants() async {
    if (_isConnected && _pool != null) {
      try {
        final results = await _pool!.execute('SELECT * FROM merchants WHERE is_open = TRUE LIMIT 10;');
        final list = <MerchantItem>[];
        for (final row in results.rows) {
          list.add(MerchantItem.fromJson(row.assoc()));
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        print('Error querying merchants from MySQL: $e');
      }
    }

    return _mockMerchants;
  }

  Future<UserModel> getUserProfile() async {
    if (_isConnected && _pool != null) {
      try {
        final results = await _pool!.execute(
          'SELECT u.*, a.locality as active_locality, a.city as active_city '
          'FROM users u '
          'LEFT JOIN addresses a ON a.user_id = u.id AND a.is_default = TRUE '
          'WHERE u.id = 1 LIMIT 1;',
        );
        if (results.rows.isNotEmpty) {
          return UserModel.fromJson(results.rows.first.assoc());
        }
      } catch (e) {
        print('Error querying user from MySQL: $e');
      }
    }

    return const UserModel(
      id: 1,
      phone: '+919876548219',
      fullName: 'Arjun Kumar',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      activeLocality: 'Indiranagar',
      activeCity: 'Bengaluru',
      walletBalance: 1450.00,
    );
  }

  Future<List<OrderItem>> getOrders({String? status}) async {
    if (_isConnected && _pool != null) {
      try {
        final query = status != null && status.isNotEmpty && status.toLowerCase() != 'all'
            ? 'SELECT * FROM orders WHERE status = :status ORDER BY id DESC;'
            : 'SELECT * FROM orders ORDER BY id DESC;';
        final results = await _pool!.execute(query, {'status': status ?? ''});
        final list = <OrderItem>[];
        for (final row in results.rows) {
          list.add(OrderItem.fromJson(row.assoc()));
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        print('Error querying orders from MySQL: $e');
      }
    }

    return _mockOrders.where((o) => status == null || status.toLowerCase() == 'all' || o.status.toLowerCase() == status.toLowerCase()).toList();
  }

  Future<OrderItem> createOrder({
    required String vendorName,
    required String category,
    required double totalAmount,
    required String itemsSummary,
  }) async {
    final orderNum = 'QF-${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    final orderDate = 'Today, $hour:$minute $period';
    const status = 'PREPARING';
    const arrivalTimeLabel = 'Arrives in 22-26 min';

    if (_isConnected && _pool != null) {
      try {
        final insertResult = await _pool!.execute(
          'INSERT INTO orders (order_number, user_id, vendor_name, category, status, arrival_time_label, total_amount, items_summary, order_date) '
          'VALUES (:order_number, 1, :vendor_name, :category, :status, :arrival_time_label, :total_amount, :items_summary, :order_date);',
          {
            'order_number': orderNum,
            'vendor_name': vendorName,
            'category': category.toUpperCase(),
            'status': status,
            'arrival_time_label': arrivalTimeLabel,
            'total_amount': totalAmount,
            'items_summary': itemsSummary,
            'order_date': orderDate,
          },
        );
        final newId = insertResult.lastInsertID.toInt();
        return OrderItem(
          id: newId,
          orderNumber: orderNum,
          vendorName: vendorName,
          category: category.toUpperCase(),
          status: status,
          arrivalTimeLabel: arrivalTimeLabel,
          totalAmount: totalAmount,
          itemsSummary: itemsSummary,
          orderDate: orderDate,
        );
      } catch (e) {
        print('Error inserting order into MySQL: $e');
      }
    }

    final newMock = OrderItem(
      id: _mockOrders.length + 1,
      orderNumber: orderNum,
      vendorName: vendorName,
      category: category.toUpperCase(),
      status: status,
      arrivalTimeLabel: arrivalTimeLabel,
      totalAmount: totalAmount,
      itemsSummary: itemsSummary,
      orderDate: orderDate,
    );
    _mockOrders.insert(0, newMock);
    return newMock;
  }

  Future<OrderItem?> cancelOrder(int orderId) async {
    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'UPDATE orders SET status = "CANCELLED", arrival_time_label = "Cancelled" WHERE id = :id;',
          {'id': orderId},
        );
        final results = await _pool!.execute(
          'SELECT * FROM orders WHERE id = :id;',
          {'id': orderId},
        );
        if (results.rows.isNotEmpty) {
          return OrderItem.fromJson(results.rows.first.assoc());
        }
      } catch (e) {
        print('Error cancelling order in MySQL: $e');
      }
    }

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = _mockOrders[index];
      final updated = OrderItem(
        id: old.id,
        orderNumber: old.orderNumber,
        vendorName: old.vendorName,
        category: old.category,
        status: 'CANCELLED',
        arrivalTimeLabel: 'Cancelled',
        totalAmount: old.totalAmount,
        itemsSummary: old.itemsSummary,
        orderDate: old.orderDate,
      );
      _mockOrders[index] = updated;
      return updated;
    }
    return null;
  }

  Future<List<BookingItem>> getBookings() async {
    if (_isConnected && _pool != null) {
      try {
        final results = await _pool!.execute('SELECT * FROM bookings ORDER BY id DESC;');
        final list = <BookingItem>[];
        for (final row in results.rows) {
          list.add(BookingItem.fromJson(row.assoc()));
        }
        if (list.isNotEmpty) return list;
      } catch (e) {
        print('Error querying bookings from MySQL: $e');
      }
    }

    return _mockBookings;
  }

  Future<BookingItem> createBooking({
    required String title,
    required String subtitle,
    required double price,
    String? route,
    String? seatNo,
  }) async {
    final bookingCode = 'BK-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
    const status = 'CONFIRMED';
    const bookingDate = 'Today';

    if (_isConnected && _pool != null) {
      try {
        final insertResult = await _pool!.execute(
          'INSERT INTO bookings (booking_code, user_id, title, subtitle, price, route, seat_no, status, booking_date) '
          'VALUES (:code, 1, :title, :subtitle, :price, :route, :seat_no, :status, :booking_date);',
          {
            'code': bookingCode,
            'title': title,
            'subtitle': subtitle,
            'price': price,
            'route': route ?? '',
            'seat_no': seatNo ?? '',
            'status': status,
            'booking_date': bookingDate,
          },
        );
        final newId = insertResult.lastInsertID.toInt();
        return BookingItem(
          id: newId,
          bookingCode: bookingCode,
          title: title,
          subtitle: subtitle,
          price: price,
          route: route,
          seatNo: seatNo,
          status: status,
          bookingDate: bookingDate,
        );
      } catch (e) {
        print('Error inserting booking into MySQL: $e');
      }
    }

    final newMock = BookingItem(
      id: _mockBookings.length + 1,
      bookingCode: bookingCode,
      title: title,
      subtitle: subtitle,
      price: price,
      route: route,
      seatNo: seatNo,
      status: status,
      bookingDate: bookingDate,
    );
    _mockBookings.insert(0, newMock);
    return newMock;
  }

  Future<BookingItem?> cancelBooking(int bookingId) async {
    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'UPDATE bookings SET status = "CANCELLED" WHERE id = :id;',
          {'id': bookingId},
        );
        final results = await _pool!.execute(
          'SELECT * FROM bookings WHERE id = :id;',
          {'id': bookingId},
        );
        if (results.rows.isNotEmpty) {
          return BookingItem.fromJson(results.rows.first.assoc());
        }
      } catch (e) {
        print('Error cancelling booking in MySQL: $e');
      }
    }
    return null;
  }

  Future<BookingItem> bookRide({
    required String pickupAddress,
    required String dropAddress,
    required double fare,
    String serviceCode = 'car_taxi',
  }) async {
    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'INSERT INTO rides (user_id, service_code, pickup_lat, pickup_lng, pickup_address, drop_lat, drop_lng, drop_address, fare, status) '
          'VALUES (1, :service_code, 12.9784, 77.6408, :pickup, 12.9716, 77.6412, :drop, :fare, "accepted");',
          {
            'service_code': serviceCode,
            'pickup': pickupAddress,
            'drop': dropAddress,
            'fare': fare,
          },
        );
      } catch (e) {
        print('Error inserting ride into MySQL: $e');
      }
    }

    return createBooking(
      title: serviceCode == 'bike_taxi' ? 'Bike Taxi Ride' : 'City Car Ride',
      subtitle: 'Driver Assigned • TVS Apache',
      price: fare,
      route: '$pickupAddress → $dropAddress',
      seatNo: 'Driver: Ramesh K. (4.9★)',
    );
  }

  Future<UserModel> updateUserProfile({
    required String fullName,
    required String phone,
    required String email,
    String? activeLocality,
  }) async {
    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'UPDATE users SET full_name = :fullName, phone = :phone, email = :email WHERE id = 1;',
          {
            'fullName': fullName,
            'phone': phone,
            'email': email,
          },
        );
        if (activeLocality != null && activeLocality.isNotEmpty) {
          await _pool!.execute(
            'UPDATE addresses SET locality = :locality, address_line = :address '
            'WHERE user_id = 1 AND is_default = TRUE;',
            {
              'locality': activeLocality,
              'address': '100ft Road, $activeLocality',
            },
          );
        }
        return getUserProfile();
      } catch (e) {
        print('Error updating user in MySQL: $e');
      }
    }

    return UserModel(
      id: 1,
      phone: phone,
      email: email,
      fullName: fullName,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      activeLocality: activeLocality ?? 'Indiranagar',
      activeCity: 'Bengaluru',
      walletBalance: 1450.00,
    );
  }

  Future<double> topupWallet(double amount) async {
    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'UPDATE users SET wallet_balance = wallet_balance + :amount WHERE id = 1;',
          {'amount': amount},
        );
        final results = await _pool!.execute('SELECT wallet_balance FROM users WHERE id = 1;');
        if (results.rows.isNotEmpty) {
          final row = results.rows.first.assoc();
          return double.tryParse(row['wallet_balance']?.toString() ?? '1450') ?? 1450.0;
        }
      } catch (e) {
        print('Error topping up wallet in MySQL: $e');
      }
    }
    return 1450.0 + amount;
  }

  Future<UserPreferences> getUserPreferences() async {
    if (_isConnected && _pool != null) {
      try {
        final results = await _pool!.execute('SELECT * FROM user_preferences WHERE user_id = 1;');
        if (results.rows.isNotEmpty) {
          return UserPreferences.fromJson(results.rows.first.assoc());
        }
      } catch (e) {
        print('Error querying preferences from MySQL: $e');
      }
    }
    return const UserPreferences();
  }

  Future<UserPreferences> updateUserPreferences({
    bool? pushNotifications,
    bool? promotionalAlerts,
    bool? biometricLock,
    String? language,
  }) async {
    final current = await getUserPreferences();
    final updated = current.copyWith(
      pushNotifications: pushNotifications,
      promotionalAlerts: promotionalAlerts,
      biometricLock: biometricLock,
      language: language,
    );

    if (_isConnected && _pool != null) {
      try {
        await _pool!.execute(
          'INSERT INTO user_preferences (user_id, push_notifications, promotional_alerts, biometric_lock, language) '
          'VALUES (1, :push, :promo, :bio, :lang) '
          'ON DUPLICATE KEY UPDATE push_notifications = :push, promotional_alerts = :promo, biometric_lock = :bio, language = :lang;',
          {
            'push': updated.pushNotifications ? 1 : 0,
            'promo': updated.promotionalAlerts ? 1 : 0,
            'bio': updated.biometricLock ? 1 : 0,
            'lang': updated.language,
          },
        );
        return updated;
      } catch (e) {
        print('Error updating preferences in MySQL: $e');
      }
    }

    return updated;
  }

  static final List<OrderItem> _mockOrders = [
    const OrderItem(
      id: 1,
      orderNumber: 'QF-071833',
      vendorName: 'Spice & Co.',
      category: 'FOOD',
      status: 'PREPARING',
      arrivalTimeLabel: 'Arrives in 24-28 min',
      totalAmount: 436.0,
      itemsSummary: 'Butter Chicken Boneless, 2x Garlic Naan, Jeera Rice',
      orderDate: '22 Oct',
    ),
    const OrderItem(
      id: 2,
      orderNumber: 'QF-068912',
      vendorName: 'Fresh Basket',
      category: 'GROCERY',
      status: 'DELIVERED',
      arrivalTimeLabel: 'Delivered • 16 Jul',
      totalAmount: 782.0,
      itemsSummary: 'Organic Farm Milk (1L), Country Eggs, Fresh Spinach, Kashmiri Apples',
      orderDate: '16 Jul',
    ),
    const OrderItem(
      id: 3,
      orderNumber: 'QF-065401',
      vendorName: 'Nova Audio',
      category: 'ELECTRONICS',
      status: 'SHIPPED',
      arrivalTimeLabel: 'Shipped • 14 Jul',
      totalAmount: 2849.0,
      itemsSummary: 'Nova Wireless ANC Earbuds Pro, Braided USB-C Fast Cable',
      orderDate: '14 Jul',
    ),
  ];

  static final List<BookingItem> _mockBookings = [
    const BookingItem(
      id: 1,
      bookingCode: 'BK-89211',
      title: 'Bus to Mysuru',
      subtitle: '20 Jul • Confirmed',
      price: 1240.0,
      route: 'Indiranagar, BLR → Suburb Bus Stand, Mysuru',
      seatNo: 'Seat 14A (Window)',
      status: 'CONFIRMED',
      bookingDate: '20 Jul',
    ),
    const BookingItem(
      id: 2,
      bookingCode: 'BK-77402',
      title: 'Tata Nexon rental',
      subtitle: '12-14 Jul • Reserved',
      price: 4800.0,
      route: 'Self-Drive Pickup: Indiranagar Hub',
      seatNo: 'Vehicle: Tata Nexon EV Max',
      status: 'RESERVED',
      bookingDate: '12 Jul',
    ),
  ];

  // Fallback Mock Data matching Figma Exactly
  static final List<ServiceItem> _mockServices = [
    const ServiceItem(
      id: 1,
      code: 'bike_taxi',
      title: 'Bike Taxi',
      subtitle: 'Fast pickup',
      iconName: 'two_wheeler',
      category: ServiceCategory.everyday,
      isFeatured: true,
      sortOrder: 1,
    ),
    const ServiceItem(
      id: 2,
      code: 'car_taxi',
      title: 'Car Taxi',
      subtitle: 'City rides',
      iconName: 'directions_car',
      category: ServiceCategory.everyday,
      isFeatured: true,
      sortOrder: 2,
    ),
    const ServiceItem(
      id: 3,
      code: 'food',
      title: 'Food',
      subtitle: 'Near you',
      iconName: 'restaurant',
      category: ServiceCategory.everyday,
      isFeatured: true,
      sortOrder: 3,
    ),
    const ServiceItem(
      id: 4,
      code: 'grocery',
      title: 'Grocery',
      subtitle: 'Daily needs',
      iconName: 'local_grocery_store',
      category: ServiceCategory.everyday,
      isFeatured: true,
      sortOrder: 4,
    ),
    const ServiceItem(
      id: 5,
      code: 'bus',
      title: 'Bus',
      subtitle: 'Intercity',
      iconName: 'directions_bus',
      category: ServiceCategory.travel,
      isFeatured: true,
      sortOrder: 5,
    ),
    const ServiceItem(
      id: 6,
      code: 'delivery',
      title: 'Delivery',
      subtitle: 'Send parcels',
      iconName: 'local_shipping',
      category: ServiceCategory.everyday,
      isFeatured: true,
      sortOrder: 6,
    ),
    const ServiceItem(
      id: 7,
      code: 'rentals',
      title: 'Rentals',
      subtitle: 'Drive your way',
      iconName: 'car_rental',
      category: ServiceCategory.travel,
      isFeatured: true,
      sortOrder: 7,
    ),
    const ServiceItem(
      id: 8,
      code: 'marketplace',
      title: 'Marketplace',
      subtitle: 'Shop local',
      iconName: 'storefront',
      category: ServiceCategory.shopping,
      isFeatured: true,
      sortOrder: 8,
    ),
    const ServiceItem(
      id: 9,
      code: 'buy_sell',
      title: 'Buy & Sell',
      subtitle: 'Used items',
      iconName: 'swap_horiz',
      category: ServiceCategory.shopping,
      isFeatured: false,
      sortOrder: 9,
    ),
    const ServiceItem(
      id: 10,
      code: 'travel',
      title: 'Travel',
      subtitle: 'Getaways',
      iconName: 'flight_takeoff',
      category: ServiceCategory.travel,
      isFeatured: false,
      sortOrder: 10,
    ),
    const ServiceItem(
      id: 11,
      code: 'flights_hotels',
      title: 'Flights & Hotels',
      subtitle: 'Getaway partner packs',
      iconName: 'hotel',
      category: ServiceCategory.travel,
      isFeatured: false,
      sortOrder: 11,
    ),
  ];

  static final List<BannerItem> _mockBanners = [
    const BannerItem(
      id: 1,
      type: BannerType.hero,
      tagline: 'ONE APP, EVERY DAY.',
      title: 'Move smarter. Live easier.',
      subtitle: 'Bikes, food, shopping and multi-vendor delivery wherever you are.',
      buttonLabel: 'Explore services',
      imageUrl: 'assets/images/h.jpg',
      actionRoute: '/explore',
      sortOrder: 1,
    ),
    const BannerItem(
      id: 2,
      type: BannerType.story,
      tagline: 'CURATED GETAWAYS',
      title: 'Breathe in the hills',
      subtitle: 'Curated weekend escapes from Bengaluru.',
      buttonLabel: 'Explore trips',
      imageUrl: 'assets/images/ex.jpg',
      actionRoute: '/explore',
      sortOrder: 2,
    ),
    const BannerItem(
      id: 3,
      type: BannerType.safety,
      title: 'Your safety comes first',
      subtitle: '24/7 support & emergency buddy services',
      imageUrl: '',
      actionRoute: '/safety',
      sortOrder: 3,
    ),
  ];

  static final List<MerchantItem> _mockMerchants = [
    const MerchantItem(
      id: 1,
      name: 'Spice & Co.',
      category: 'North Indian & Biryani',
      rating: 4.7,
      deliveryTimeMin: 25,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
      latitude: 12.9716,
      longitude: 77.6412,
      isOpen: true,
    ),
    const MerchantItem(
      id: 2,
      name: 'Fresh Basket',
      category: 'Farm Fresh Groceries & Dairy',
      rating: 4.9,
      deliveryTimeMin: 18,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      latitude: 12.9730,
      longitude: 77.6430,
      isOpen: true,
    ),
    const MerchantItem(
      id: 3,
      name: 'The Roastery',
      category: 'Artisanal Coffee & Bakery',
      rating: 4.8,
      deliveryTimeMin: 20,
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
      latitude: 12.9745,
      longitude: 77.6455,
      isOpen: true,
    ),
  ];
}
