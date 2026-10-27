import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quikfly_core/quikfly_core.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final ordersProvider = FutureProvider.autoDispose.family<List<OrderItem>, String?>((ref, status) async {
  final client = ref.watch(apiClientProvider);
  return client.fetchOrders(status: status);
});

final bookingsProvider = FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.fetchBookings();
});

final userProfileProvider = FutureProvider.autoDispose<UserModel>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.fetchUserProfile();
});

class ApiClient {
  final Dio _dio;

  static const String _defaultUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8085/api/v1',
  );

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultUrl,
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  Future<HomeFeedDTO> fetchHomeFeed() async {
    try {
      final response = await _dio.get('/home/feed');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return HomeFeedDTO.fromJson(data);
      }
    } catch (e) {
      print('⚠️ API Client notice: Live backend request failed ($e). Using cached local core fallback.');
    }

    // High fidelity fallback so the app is always functional
    return HomeFeedDTO(
      user: const UserModel(
        id: 1,
        phone: '+919876543210',
        fullName: 'Akhil R S',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        activeLocality: 'Indiranagar',
        activeCity: 'Bengaluru',
      ),
      heroBanners: [
        const BannerItem(
          id: 1,
          type: BannerType.hero,
          tagline: 'ONE APP, EVERY DAY.',
          title: 'Move smarter. Live easier.',
          subtitle: 'Bikes, food, shopping and multi-vendor delivery wherever you are.',
          buttonLabel: 'Explore services',
          imageUrl: 'assets/images/h.jpg',
          actionRoute: '/explore',
        ),
      ],
      services: _defaultFeaturedServices,
      popularMerchants: _defaultMerchants,
      safetyBanner: const BannerItem(
        id: 3,
        type: BannerType.safety,
        title: 'Your safety comes first',
        subtitle: '24/7 support & emergency buddy services',
        imageUrl: '',
        actionRoute: '/safety',
      ),
    );
  }

  Future<ExploreFeedDTO> fetchExploreFeed({String category = 'all'}) async {
    try {
      final response = await _dio.get('/explore', queryParameters: {'category': category});
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ExploreFeedDTO.fromJson(data);
      }
    } catch (e) {
      print('⚠️ API Client notice: Live backend request failed ($e). Using cached local core fallback.');
    }

    final services = category.toLowerCase() == 'all'
        ? _allServices
        : _allServices.where((s) => s.category.name == category.toLowerCase()).toList();

    return ExploreFeedDTO(
      categories: ['all', 'everyday', 'travel', 'shopping'],
      services: services,
      weekendInspiration: const BannerItem(
        id: 2,
        type: BannerType.story,
        tagline: 'CURATED GETAWAYS',
        title: 'Breathe in the hills',
        subtitle: 'Curated weekend escapes from Bengaluru.',
        buttonLabel: 'Explore trips',
        imageUrl: 'assets/images/ex.jpg',
        actionRoute: '/trips/hills',
      ),
      travelOfferings: _allServices.where((s) => s.category == ServiceCategory.travel).toList(),
    );
  }

  Future<List<OrderItem>> fetchOrders({String? status}) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'] as List;
        return list.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('⚠️ API Client notice: Live /orders request failed ($e). Using cached local core fallback.');
    }

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      return _defaultOrders.where((o) => o.status.toLowerCase() == status.toLowerCase()).toList();
    }
    return _defaultOrders;
  }

  Future<List<BookingItem>> fetchBookings() async {
    try {
      final response = await _dio.get('/bookings');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'] as List;
        return list.map((item) => BookingItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('⚠️ API Client notice: Live /bookings request failed ($e). Using cached local core fallback.');
    }

    return _defaultBookings;
  }

  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _dio.get('/profile');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      print('⚠️ API Client notice: Live /profile request failed ($e). Using cached local core fallback.');
    }

    return const UserModel(
      id: 1,
      phone: '+91 98765 43210',
      fullName: 'Arjun Kumar',
      avatarUrl: 'assets/images/user.jpg',
      activeLocality: 'Indiranagar',
      activeCity: 'Bengaluru',
    );
  }

  static const List<OrderItem> _defaultOrders = [
    OrderItem(
      id: 1,
      orderNumber: 'QF-071833',
      vendorName: 'Spice & Co.',
      category: 'FOOD',
      status: 'PREPARING',
      arrivalTimeLabel: 'Arriving in 18 mins',
      totalAmount: 438.0,
      itemsSummary: '1x Hyderabadi Chicken Biryani, 1x Mirchi Ka Salan, 1x Double Ka Meetha',
      orderDate: 'Today, 1:15 PM',
    ),
    OrderItem(
      id: 2,
      orderNumber: 'QF-071720',
      vendorName: 'Fresh Basket',
      category: 'GROCERY',
      status: 'DELIVERED',
      arrivalTimeLabel: 'Delivered',
      totalAmount: 782.0,
      itemsSummary: 'Organic Farm Milk (1L), Country Eggs (12), Fresh Spinach (500g)',
      orderDate: '16 Jul',
    ),
    OrderItem(
      id: 3,
      orderNumber: 'QF-071599',
      vendorName: 'Nova Audio',
      category: 'MARKETPLACE',
      status: 'DELIVERED',
      arrivalTimeLabel: 'Delivered',
      totalAmount: 2499.0,
      itemsSummary: 'Wireless ANC Earbuds Pro (Graphite Black)',
      orderDate: '14 Jul',
    ),
  ];

  static const List<BookingItem> _defaultBookings = [
    BookingItem(
      id: 1,
      bookingCode: 'BK-8842',
      title: 'Bus to Mysuru',
      subtitle: 'Departs 06:30 AM • Majestic Terminal 1',
      price: 450.0,
      route: 'Bengaluru → Mysuru',
      seatNo: '14A (Window)',
      status: 'CONFIRMED',
      bookingDate: 'Tomorrow',
    ),
    BookingItem(
      id: 2,
      bookingCode: 'BK-7721',
      title: 'Tata Nexon EV Rental',
      subtitle: 'Self-drive • 24 Hours • Unlimited km',
      price: 2199.0,
      route: 'Indiranagar Hub',
      seatNo: 'KA-04-ME-2044',
      status: 'CONFIRMED',
      bookingDate: '20 Jul',
    ),
  ];

  static const List<ServiceItem> _defaultFeaturedServices = [
    ServiceItem(id: 1, code: 'bike_taxi', title: 'Bike Taxi', subtitle: 'Fast pickup', iconName: 'two_wheeler', category: ServiceCategory.everyday),
    ServiceItem(id: 2, code: 'car_taxi', title: 'Car Taxi', subtitle: 'City rides', iconName: 'directions_car', category: ServiceCategory.everyday),
    ServiceItem(id: 3, code: 'food', title: 'Food', subtitle: 'Near you', iconName: 'restaurant', category: ServiceCategory.everyday),
    ServiceItem(id: 4, code: 'grocery', title: 'Grocery', subtitle: 'Daily needs', iconName: 'local_grocery_store', category: ServiceCategory.everyday),
    ServiceItem(id: 5, code: 'bus', title: 'Bus', subtitle: 'Intercity', iconName: 'directions_bus', category: ServiceCategory.travel),
    ServiceItem(id: 6, code: 'delivery', title: 'Delivery', subtitle: 'Send parcels', iconName: 'local_shipping', category: ServiceCategory.everyday),
    ServiceItem(id: 7, code: 'rentals', title: 'Rentals', subtitle: 'Drive your way', iconName: 'car_rental', category: ServiceCategory.travel),
    ServiceItem(id: 8, code: 'marketplace', title: 'Marketplace', subtitle: 'Shop local', iconName: 'storefront', category: ServiceCategory.shopping),
  ];

  static const List<ServiceItem> _allServices = [
    ..._defaultFeaturedServices,
    ServiceItem(id: 9, code: 'buy_sell', title: 'Buy & Sell', subtitle: 'Used items', iconName: 'swap_horiz', category: ServiceCategory.shopping, isFeatured: false),
    ServiceItem(id: 10, code: 'travel', title: 'Travel', subtitle: 'Getaways', iconName: 'flight_takeoff', category: ServiceCategory.travel, isFeatured: false),
    ServiceItem(id: 11, code: 'flights_hotels', title: 'Flights & Hotels', subtitle: 'Getaway partner packs', iconName: 'hotel', category: ServiceCategory.travel, isFeatured: false),
  ];

  static const List<MerchantItem> _defaultMerchants = [
    MerchantItem(
      id: 1,
      name: 'Spice & Co.',
      category: 'North Indian & Biryani',
      rating: 4.7,
      deliveryTimeMin: 25,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
      latitude: 12.9716,
      longitude: 77.6412,
    ),
    MerchantItem(
      id: 2,
      name: 'Fresh Basket',
      category: 'Farm Fresh Groceries & Dairy',
      rating: 4.9,
      deliveryTimeMin: 18,
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      latitude: 12.9730,
      longitude: 77.6430,
    ),
  ];
}
