import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quikfly_core/quikfly_core.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? 'http://127.0.0.1:8080/api/v1',
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
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
        actionRoute: '/trips/hills',
      ),
      travelOfferings: _allServices.where((s) => s.category == ServiceCategory.travel).toList(),
    );
  }

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
