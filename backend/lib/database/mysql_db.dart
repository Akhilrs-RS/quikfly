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

    try {
      print('🔄 Connecting to MySQL at $host:$port (DB: $database, User: $user)...');
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
    } catch (e) {
      _isConnected = false;
      print('⚠️ Notice: Could not connect to live MySQL ($e).');
      print('💡 Running in development fallback mode using high-fidelity Figma demo data.');
      print('👉 Set MYSQL_USER & MYSQL_PASSWORD in environment or run docker compose to use live MySQL.');
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
        final results = await _pool!.execute('SELECT * FROM users LIMIT 1;');
        if (results.rows.isNotEmpty) {
          return UserModel.fromJson(results.rows.first.assoc());
        }
      } catch (e) {
        print('Error querying user from MySQL: $e');
      }
    }

    return const UserModel(
      id: 1,
      phone: '+919876543210',
      fullName: 'Akhil R S',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      activeLocality: 'Indiranagar',
      activeCity: 'Bengaluru',
    );
  }

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
      imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=800',
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
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
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
