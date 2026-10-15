import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/location_header_widget.dart';
import '../widgets/popular_merchants_widget.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/quick_ride_card.dart';
import '../widgets/safety_banner_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/services_grid_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      onLocationTap: () => _showLocationPicker(context, ref),
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
      _showDestinationDialog(context);
    } else {
      context.go('/explore');
    }
  }

  void _showDestinationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Select Destination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search drop-off location...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.work_outline_rounded, color: AppColors.primary),
              title: const Text('Office / Tech Park', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Manyata Tech Park, Nagavara'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flight_takeoff_rounded, color: AppColors.accentOrange),
              title: const Text('Kempegowda Int. Airport (BLR)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Devanahalli, Bengaluru'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: AppColors.primary),
              title: const Text('Indiranagar, Bengaluru', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('100ft Road, Defence Colony'),
              onTap: () {
                ref.read(selectedLocationProvider.notifier).state = 'Indiranagar, Bengaluru';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.apartment_rounded, color: AppColors.textSecondary),
              title: const Text('Koramangala, Bengaluru', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('80ft Road, 4th Block'),
              onTap: () {
                ref.read(selectedLocationProvider.notifier).state = 'Koramangala, Bengaluru';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
