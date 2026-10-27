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
    final addressesAsync = ref.read(addressesProvider);
    final savedAddresses = addressesAsync.value ?? [
      const AddressItem(
        id: 1,
        userId: 1,
        label: 'Home',
        addressLine: '100ft Road, Indiranagar',
        locality: 'Indiranagar',
        city: 'Bengaluru',
        latitude: 12.9784,
        longitude: 77.6408,
        isDefault: true,
      ),
    ];
    final currentLocation = ref.read(selectedLocationProvider);

    final popularLocalities = [
      {'name': 'Indiranagar, Bengaluru', 'sub': '100ft Road, Defence Colony'},
      {'name': 'Koramangala, Bengaluru', 'sub': '80ft Road, 4th Block'},
      {'name': 'Whitefield, Bengaluru', 'sub': 'ITPB Main Road, Palm Meadows'},
      {'name': 'HSR Layout, Bengaluru', 'sub': '27th Main, Sector 1'},
      {'name': 'MG Road, Bengaluru', 'sub': 'Brigade Road Junction'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(pickerCtx).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Location',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(pickerCtx);
                      _showAddCustomLocationSheet(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_location_alt_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            '+ Add Custom',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a saved address or add your custom destination:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Saved Addresses Section (from MySQL)
              const Text(
                'SAVED ADDRESSES (MYSQL)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...savedAddresses.map((addr) {
                final isSelected = currentLocation.toLowerCase().contains(addr.locality.toLowerCase()) || addr.isDefault;
                final icon = addr.label.toLowerCase() == 'work'
                    ? Icons.work_outline_rounded
                    : addr.label.toLowerCase() == 'gym'
                        ? Icons.fitness_center_rounded
                        : Icons.home_outlined;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0F5FF) : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          addr.formattedTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            addr.label.toUpperCase(),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      addr.addressLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                        : null,
                    onTap: () async {
                      Navigator.pop(pickerCtx);
                      ref.read(selectedLocationProvider.notifier).state = addr.formattedTitle;
                      await ref.read(apiClientProvider).setDefaultAddress(addr.id);
                      await ref.read(apiClientProvider).updateUserProfile(
                            fullName: 'Arjun Kumar',
                            phone: '+919876548219',
                            email: 'arjun.kumar@quikfly.app',
                            activeLocality: addr.locality,
                          );
                      ref.invalidate(addressesProvider);
                      ref.invalidate(userProfileProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Switched active delivery location to ${addr.formattedTitle}!'),
                          backgroundColor: AppColors.darkCard,
                        ),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Button to Add Custom Address
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(pickerCtx);
                  _showAddCustomLocationSheet(context);
                },
                icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
                label: const Text(
                  'Add New Custom Location',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              // Popular Bengaluru Neighborhoods
              const Text(
                'POPULAR AREAS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...popularLocalities.map((loc) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                    title: Text(loc['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    subtitle: Text(loc['sub']!, style: const TextStyle(fontSize: 11)),
                    onTap: () async {
                      Navigator.pop(pickerCtx);
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
      ),
    );
  }

  void _showAddCustomLocationSheet(BuildContext context) {
    String selectedLabel = 'Home';
    final addressLineController = TextEditingController();
    final localityController = TextEditingController();
    final cityController = TextEditingController(text: 'Bengaluru');
    bool setAsDefault = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (formCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(formCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Custom Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Save your exact house/office address directly to MySQL:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Label selector pills
                const Text('Address Label:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['Home', 'Work', 'Gym', 'Custom'].map((lbl) {
                    final isSel = selectedLabel == lbl;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          lbl,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedLabel = lbl);
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Street Address Field
                TextField(
                  controller: addressLineController,
                  decoration: const InputDecoration(
                    labelText: 'House / Flat / Street / Landmark',
                    hintText: 'e.g. #304, Green Glen Layout, Outer Ring Rd',
                    prefixIcon: Icon(Icons.home_work_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                // Locality Field
                TextField(
                  controller: localityController,
                  decoration: const InputDecoration(
                    labelText: 'Locality / Area',
                    hintText: 'e.g. Bellandur, Jayanagar, Electronic City',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                // City Field
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 12),

                // Set as Active Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as current active delivery location', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  value: setAsDefault,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setModalState(() => setAsDefault = val);
                  },
                ),

                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    final street = addressLineController.text.trim();
                    final area = localityController.text.trim();
                    final city = cityController.text.trim();

                    if (street.isEmpty || area.isEmpty) {
                      ScaffoldMessenger.of(formCtx).showSnackBar(
                        const SnackBar(content: Text('Please enter both street address and locality.')),
                      );
                      return;
                    }

                    Navigator.pop(formCtx);

                    try {
                      final newAddr = await ref.read(apiClientProvider).addCustomAddress(
                            label: selectedLabel,
                            addressLine: street,
                            locality: area,
                            city: city.isEmpty ? 'Bengaluru' : city,
                            isDefault: setAsDefault,
                          );

                      if (setAsDefault) {
                        ref.read(selectedLocationProvider.notifier).state = newAddr.formattedTitle;
                        await ref.read(apiClientProvider).updateUserProfile(
                              fullName: 'Arjun Kumar',
                              phone: '+919876548219',
                              email: 'arjun.kumar@quikfly.app',
                              activeLocality: newAddr.locality,
                            );
                      }

                      ref.invalidate(addressesProvider);
                      ref.invalidate(userProfileProvider);

                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text("Custom location '${newAddr.formattedTitle}' saved to MySQL & set as active!"),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Error saving location: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Save Location to MySQL',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
