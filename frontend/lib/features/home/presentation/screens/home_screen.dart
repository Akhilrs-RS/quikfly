import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/home_controller.dart';
import '../widgets/location_header_widget.dart';
import '../widgets/popular_merchants_widget.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/quick_ride_card.dart';
import '../widgets/safety_banner_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/services_grid_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeFeedAsync = ref.watch(homeFeedProvider);
    final location = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: homeFeedAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text('Could not load feed: $error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(homeFeedProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (feed) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                return ref.refresh(homeFeedProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Header with Location & Profile
                    LocationHeaderWidget(
                      location: location,
                      userInitials: 'AK',
                      onLocationTap: () => _showLocationPicker(context),
                      onNotificationTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications (No unread messages)')),
                        );
                      },
                      onProfileTap: () {
                        context.go('/account');
                      },
                    ),

                    // 2. Global Search Bar
                    SearchBarWidget(
                      onTap: () {
                        context.go('/explore');
                      },
                      onFilterTap: () {
                        context.go('/explore');
                      },
                    ),

                    const SizedBox(height: 10),

                    // 3. Hero Promotional Banner Carousel
                    PromoBannerCarousel(
                      banners: feed.heroBanners,
                      onBannerAction: (banner) {
                        context.go(banner.actionRoute ?? '/explore');
                      },
                    ),

                    const SizedBox(height: 18),

                    // 4. "What do you need?" 8-Grid Services
                    ServicesGridWidget(
                      services: feed.services,
                      onViewAllTap: () => context.go('/explore'),
                      onServiceSelected: (service) {
                        _handleServiceNavigation(context, service);
                      },
                    ),

                    const SizedBox(height: 14),

                    // 5. Quick Ride Card
                    QuickRideCard(
                      currentLocation: location,
                      onDestinationTap: () => _showDestinationDialog(context),
                    ),

                    const SizedBox(height: 16),

                    // 6. Popular Near You (Spice & Co., Fresh Basket)
                    PopularMerchantsWidget(
                      merchants: feed.popularMerchants,
                      onSeeMoreTap: () => context.go('/explore'),
                      onMerchantTap: (merchant) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected ${merchant.name}')),
                        );
                      },
                    ),

                    // 7. Safety Banner
                    if (feed.safetyBanner != null)
                      SafetyBannerWidget(
                        title: feed.safetyBanner!.title,
                        subtitle: feed.safetyBanner!.subtitle ?? '',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('QuikFly 24/7 Safety Support Active')),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleServiceNavigation(BuildContext context, ServiceItem service) {
    if (service.code == 'bike_taxi' || service.code == 'car_taxi') {
      _showDestinationDialog(context, serviceCode: service.code);
    } else if (service.code == 'food') {
      _showFoodOrderModal(context);
    } else if (service.code == 'grocery') {
      _showGroceryOrderModal(context);
    } else if (service.code == 'bus' || service.code == 'rentals') {
      _showTravelBookingModal(context, service.title);
    } else {
      context.go('/explore');
    }
  }

  void _showDestinationDialog(BuildContext context, {String serviceCode = 'car_taxi'}) {
    final location = ref.read(selectedLocationProvider);
    final destinations = [
      {'name': 'Kempegowda Int. Airport (BLR)', 'sub': 'Devanahalli, Bengaluru', 'fare': 540.0},
      {'name': 'Manyata Tech Park', 'sub': 'Outer Ring Road, Nagavara', 'fare': 220.0},
      {'name': 'MG Road Metro Station', 'sub': 'Central Business District', 'fare': 150.0},
      {'name': 'Whitefield ITPL Hub', 'sub': 'ITPB Main Road, Whitefield', 'fare': 320.0},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(serviceCode == 'bike_taxi' ? Icons.two_wheeler_rounded : Icons.directions_car_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(serviceCode == 'bike_taxi' ? 'Book Bike Taxi' : 'Book City Ride', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Pickup: $location', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Choose Destination:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 10),
            ...destinations.map((dest) {
              final fare = (dest['fare'] as double) * (serviceCode == 'bike_taxi' ? 0.45 : 1.0);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: Text(dest['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  subtitle: Text(dest['sub'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  trailing: Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(apiClientProvider).bookRide(
                      pickupAddress: location,
                      dropAddress: dest['name'] as String,
                      fare: fare,
                      serviceCode: serviceCode,
                    );
                    ref.invalidate(bookingsProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF071B2F),
                        content: Text('Ride Booked to ${dest['name']}! Driver assigned.'),
                        action: SnackBarAction(
                          label: 'View in Bookings',
                          textColor: const Color(0xFF38BDF8),
                          onPressed: () => this.context.go('/bookings'),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showFoodOrderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Fast Food Delivery near Indiranagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Order in 1-tap with real-time MySQL persistence', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            _buildQuickMenuItem(
              title: 'Butter Chicken & 2x Garlic Naan',
              vendor: 'Spice & Co.',
              price: 340.0,
              onOrder: () async {
                Navigator.pop(ctx);
                final o = await ref.read(apiClientProvider).createOrder(
                  vendorName: 'Spice & Co.',
                  category: 'FOOD',
                  totalAmount: 340.0,
                  itemsSummary: '1x Butter Chicken, 2x Garlic Naan',
                );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF071B2F),
                    content: Text('Order #${o.orderNumber} placed with Spice & Co.!'),
                    action: SnackBarAction(label: 'View Orders', textColor: const Color(0xFF38BDF8), onPressed: () => this.context.go('/orders')),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              title: 'Hyderabadi Dum Biryani Handi',
              vendor: 'Bawarchi Express',
              price: 299.0,
              onOrder: () async {
                Navigator.pop(ctx);
                final o = await ref.read(apiClientProvider).createOrder(
                  vendorName: 'Bawarchi Express',
                  category: 'FOOD',
                  totalAmount: 299.0,
                  itemsSummary: '1x Hyderabadi Dum Biryani, 1x Raita',
                );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF071B2F),
                    content: Text('Order #${o.orderNumber} placed!'),
                    action: SnackBarAction(label: 'View Orders', textColor: const Color(0xFF38BDF8), onPressed: () => this.context.go('/orders')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGroceryOrderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('10-Minute Grocery Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _buildQuickMenuItem(
              title: 'Farm Fresh Essentials Kit (Milk, Eggs, Spinach)',
              vendor: 'Fresh Basket',
              price: 220.0,
              onOrder: () async {
                Navigator.pop(ctx);
                final o = await ref.read(apiClientProvider).createOrder(
                  vendorName: 'Fresh Basket',
                  category: 'GROCERY',
                  totalAmount: 220.0,
                  itemsSummary: 'Organic Milk 1L, Farm Eggs 6pcs, Spinach 250g',
                );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF071B2F),
                    content: Text('Grocery Order #${o.orderNumber} confirmed! Packing now.'),
                    action: SnackBarAction(label: 'Track', textColor: const Color(0xFF38BDF8), onPressed: () => this.context.go('/orders')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTravelBookingModal(BuildContext context, String serviceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Quick $serviceName Booking', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _buildQuickMenuItem(
              title: serviceName.contains('Bus') ? 'Intercity AC Bus to Mysuru' : 'Tata Nexon EV (24h Rental)',
              vendor: 'QuikFly Mobility',
              price: serviceName.contains('Bus') ? 450.0 : 2199.0,
              onOrder: () async {
                Navigator.pop(ctx);
                final b = await ref.read(apiClientProvider).createBooking(
                  title: serviceName.contains('Bus') ? 'Bus to Mysuru' : 'Tata Nexon EV Rental',
                  subtitle: 'Confirmed • Indiranagar Hub',
                  price: serviceName.contains('Bus') ? 450.0 : 2199.0,
                  route: 'Indiranagar Hub → Mysuru',
                  seatNo: 'Confirmed',
                );
                ref.invalidate(bookingsProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF071B2F),
                    content: Text('Booking #${b.bookingCode} confirmed!'),
                    action: SnackBarAction(label: 'View Ticket', textColor: const Color(0xFF38BDF8), onPressed: () => this.context.go('/bookings')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required String title,
    required String vendor,
    required double price,
    required VoidCallback onOrder,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(vendor, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Order Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    final localities = [
      {'name': 'Indiranagar, Bengaluru', 'sub': '100ft Road, Defence Colony'},
      {'name': 'Koramangala, Bengaluru', 'sub': '80ft Road, 4th Block'},
      {'name': 'Whitefield, Bengaluru', 'sub': 'ITPB Main Road, Palm Meadows'},
      {'name': 'HSR Layout, Bengaluru', 'sub': '27th Main, Sector 1'},
      {'name': 'MG Road, Bengaluru', 'sub': 'Brigade Road Junction'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose delivery location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text('Updates address and local restaurants in real time', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            ...localities.map((loc) => ListTile(
              leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
              title: Text(loc['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text(loc['sub']!, style: const TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                ref.read(selectedLocationProvider.notifier).state = loc['name']!;
                await ref.read(apiClientProvider).updateUserProfile(
                  fullName: 'Arjun Kumar',
                  phone: '+919876548219',
                  email: 'arjun.kumar@quikfly.app',
                  activeLocality: loc['name']!.split(',').first.trim(),
                );
                ref.invalidate(userProfileProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Active location set to ${loc['name']!}')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
