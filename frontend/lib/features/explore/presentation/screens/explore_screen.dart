import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/explore_controller.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreAsync = ref.watch(exploreFeedProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: exploreAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.refresh(exploreFeedProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (feed) {
            final filteredServices = feed.services.where((s) {
              if (_searchQuery.isEmpty) return true;
              return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  s.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Top bar with Logo, Bell, Avatar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.electric_bolt_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'QuikFly',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, size: 22),
                          onPressed: () => _showNotificationsPreview(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => context.go('/account'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'AK',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Screen Title
                  const Text(
                    'Explore QuikFly',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search all services input
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim());
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search all services',
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          )
                        else
                          const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Category Filter Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: feed.categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = feed.categories[index];
                        final isSelected = selectedCategory.toLowerCase() == cat.toLowerCase();

                        return ChoiceChip(
                          label: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.darkCard,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.darkCard : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          showCheckmark: false,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(selectedCategoryProvider.notifier).state = cat;
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Title: All services
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${filteredServices.length} available',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2-Column Services Grid with Chevrons and Click Actions
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredServices.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      final style = _getServiceStyle(service.code);

                      return InkWell(
                        onTap: () => _handleServiceTap(context, service),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: style.bgColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(style.icon, color: style.iconColor, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      service.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      service.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Weekend Inspiration Section
                  const Text(
                    'Weekend Inspiration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (feed.weekendInspiration != null)
                    GestureDetector(
                      onTap: () => _showWeekendInspirationBooking(context),
                      child: Container(
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: _resolveExploreImage(feed.weekendInspiration?.imageUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              debugPrint('Explore banner image load error: $exception');
                            },
                          ),
                          boxShadow: AppColors.elevatedShadow,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  feed.weekendInspiration!.tagline ?? 'CURATED GETAWAYS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                feed.weekendInspiration!.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feed.weekendInspiration!.subtitle ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    feed.weekendInspiration!.buttonLabel ?? 'Explore trips',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Flights & Hotels Card
                  InkWell(
                    onTap: () => _showFlightsAndHotelsBooking(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.flight_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flights & Hotels',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Curated partner escapes • 1-tap booking',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleServiceTap(BuildContext context, ServiceItem service) {
    if (service.code == 'bike_taxi' || service.code == 'car_taxi') {
      _showDestinationDialog(context, service.code);
    } else if (service.code == 'food') {
      _showQuickFoodSheet(context);
    } else if (service.code == 'grocery') {
      _showQuickGrocerySheet(context);
    } else if (service.code == 'bus' || service.code == 'travel' || service.code == 'rentals') {
      _showTravelBookingSheet(context, service.title);
    } else {
      _showGenericServiceSheet(context, service);
    }
  }

  void _showDestinationDialog(BuildContext context, String serviceCode) {
    final isBike = serviceCode == 'bike_taxi';
    final destinations = [
      {'name': 'Kempegowda Intl Airport', 'fare': isBike ? 340.0 : 680.0, 'time': '42 min'},
      {'name': 'Manyata Tech Park', 'fare': isBike ? 140.0 : 280.0, 'time': '20 min'},
      {'name': 'Indiranagar 100ft Road', 'fare': isBike ? 55.0 : 110.0, 'time': '10 min'},
      {'name': 'Whitefield ITPL', 'fare': isBike ? 190.0 : 390.0, 'time': '32 min'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Book ${isBike ? "Bike Taxi" : "Car Taxi"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select destination (instantly stores live ride in MySQL database):',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ...destinations.map((dest) {
              final fare = dest['fare'] as double;
              final name = dest['name'] as String;
              final time = dest['time'] as String;
              return ListTile(
                leading: const Icon(Icons.location_on_rounded, color: AppColors.accentRed),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('ETA: $time'),
                trailing: Text(
                  '₹${fare.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await ref.read(apiClientProvider).bookRide(
                          pickupAddress: 'Indiranagar 12th Main',
                          dropAddress: name,
                          fare: fare,
                          serviceCode: serviceCode,
                        );
                    ref.invalidate(bookingsProvider);
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Ride to $name confirmed & saved to MySQL!'),
                        backgroundColor: AppColors.darkCard,
                        action: SnackBarAction(
                          label: 'VIEW BOOKINGS',
                          textColor: AppColors.primaryLight,
                          onPressed: () => this.context.go('/bookings'),
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Booking error: $e')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showQuickFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_rounded, color: Color(0xFFF79009)),
                SizedBox(width: 10),
                Text('Order Food • Spice & Co.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Instant 1-tap food order saved to MySQL:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hyderabadi Chicken Biryani Meal', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Served with Mirchi Ka Salan & Raita'),
              trailing: const Text('₹349', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createOrder(
                      vendorName: 'Spice & Co.',
                      category: 'Food & Dining',
                      totalAmount: 349.0,
                      itemsSummary: '1x Hyderabadi Chicken Biryani Meal',
                    );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Food order placed & saved to MySQL in real time!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW ORDERS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/orders'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickGrocerySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_basket_rounded, color: Color(0xFF12B76A)),
                SizedBox(width: 10),
                Text('Fresh Basket Groceries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Instant farm-fresh essentials saved to MySQL:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Farm Fresh Organic Vegetable Box', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('5kg Assorted Seasonal Veggies & Greens'),
              trailing: const Text('₹450', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createOrder(
                      vendorName: 'Fresh Basket',
                      category: 'Groceries & Essentials',
                      totalAmount: 450.0,
                      itemsSummary: '1x Farm Fresh Organic Vegetable Box (5kg)',
                    );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Grocery order placed & saved to MySQL in real time!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW ORDERS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/orders'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTravelBookingSheet(BuildContext context, String serviceTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus_rounded, color: Color(0xFF7A5AF8)),
                const SizedBox(width: 10),
                Text('Book $serviceTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Curated intercity route stored to MySQL:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Bengaluru → Mysore Electric Volvo', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Departure: 07:00 AM • Seat 14A'),
              trailing: const Text('₹480', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createBooking(
                      title: 'Bengaluru → Mysore Volvo',
                      subtitle: 'Confirmed • Seat 14A',
                      price: 480.0,
                      route: 'Bengaluru (Majestic) → Mysore Suburb',
                      seatNo: 'Seat 14A (Window)',
                    );
                ref.invalidate(bookingsProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Bus travel ticket confirmed & stored in MySQL!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW PASS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/bookings'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekendInspirationBooking(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.terrain_rounded, color: AppColors.accentGreen),
                SizedBox(width: 10),
                Text('Weekend Getaway: Coorg Escape', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Curated weekend package with luxury stay & transfer:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.hotel_rounded, color: AppColors.primary),
              title: const Text('Coorg Coffee Estate Villa (2 Nights)', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Includes AC Cab Transfer from Bengaluru'),
              trailing: const Text('₹2,800', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createBooking(
                      title: 'Coorg Coffee Estate Escape',
                      subtitle: 'Confirmed • 2 Nights Villa Stay',
                      price: 2800.0,
                      route: 'Bengaluru ↔ Coorg Luxury Cab Transfer',
                      seatNo: 'Villa #102 • Coffee Plantation View',
                    );
                ref.invalidate(bookingsProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Weekend getaway booked and stored in MySQL!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW BOOKINGS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/bookings'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFlightsAndHotelsBooking(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flight_takeoff_rounded, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Flights & Hotels Partner Pack', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('1-tap partner booking with live MySQL database sync:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.beach_access_rounded, color: AppColors.accentOrange),
              title: const Text('Goa Coastal Resort & Return Flight', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Confirmed Flight + 3 Days Beachfront Resort'),
              trailing: const Text('₹5,400', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.accentGreen)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createBooking(
                      title: 'Goa Coastal Villa & Flight Pass',
                      subtitle: 'Confirmed • Indigo + Heritage Resort',
                      price: 5400.0,
                      route: 'BLR ↔ GOI Flight + Resort Cab',
                      seatNo: 'Flight: 6E-421 (Seat 4F)',
                    );
                ref.invalidate(bookingsProvider);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Flight & Hotel escape confirmed and stored in MySQL!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW BOOKINGS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/bookings'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGenericServiceSheet(BuildContext context, ServiceItem service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick ${service.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(service.subtitle, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(sheetContext);
                await ref.read(apiClientProvider).createOrder(
                      vendorName: 'QuikFly ${service.title}',
                      category: service.category.name,
                      totalAmount: 199.0,
                      itemsSummary: '1x ${service.title} standard request',
                    );
                ref.invalidate(ordersProvider(null));
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('${service.title} request submitted to MySQL!'),
                    backgroundColor: AppColors.darkCard,
                    action: SnackBarAction(
                      label: 'VIEW ORDERS',
                      textColor: AppColors.primaryLight,
                      onPressed: () => this.context.go('/orders'),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Request ${service.title} (₹199)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.local_shipping_rounded, color: AppColors.primary),
              title: const Text('Order QF-071833 Delivered'),
              subtitle: const Text('Spice & Co. meal delivered • Today'),
              onTap: () => Navigator.pop(sheetContext),
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_rounded, color: AppColors.accentOrange),
              title: const Text('Weekend Hills Flash Sale'),
              subtitle: const Text('Save 20% on Coorg & Ooty bus rides'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  _ServiceStyle _getServiceStyle(String code) {
    switch (code) {
      case 'bike_taxi':
        return const _ServiceStyle(Icons.two_wheeler_rounded, Color(0xFF2B66F6), Color(0xFFEFF4FF));
      case 'car_taxi':
        return const _ServiceStyle(Icons.directions_car_rounded, Color(0xFF2B66F6), Color(0xFFEFF4FF));
      case 'food':
        return const _ServiceStyle(Icons.restaurant_rounded, Color(0xFFF79009), Color(0xFFFEF0C7));
      case 'grocery':
        return const _ServiceStyle(Icons.shopping_basket_rounded, Color(0xFF12B76A), Color(0xFFD1FADF));
      case 'bus':
        return const _ServiceStyle(Icons.directions_bus_rounded, Color(0xFF7A5AF8), Color(0xFFF4EBFF));
      case 'delivery':
        return const _ServiceStyle(Icons.send_rounded, Color(0xFF0BA5EC), Color(0xFFE0F2FE));
      case 'rentals':
        return const _ServiceStyle(Icons.key_rounded, Color(0xFFF04438), Color(0xFFFEE4E2));
      case 'buy_sell':
        return const _ServiceStyle(Icons.swap_horiz_rounded, Color(0xFF7A5AF8), Color(0xFFF4EBFF));
      case 'travel':
        return const _ServiceStyle(Icons.flight_takeoff_rounded, Color(0xFF0BA5EC), Color(0xFFE0F2FE));
      case 'marketplace':
      default:
        return const _ServiceStyle(Icons.storefront_rounded, Color(0xFFEE46BC), Color(0xFFFCE7F6));
    }
  }

  ImageProvider _resolveExploreImage(String? imageUrl) {
    if (imageUrl == null ||
        imageUrl.isEmpty ||
        imageUrl == 'assets/images/ex.jpg' ||
        imageUrl == 'ex.jpg' ||
        imageUrl.contains('photo-1506744038136')) {
      return const AssetImage('assets/images/ex.jpg');
    }
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    return const AssetImage('assets/images/ex.jpg');
  }
}

class _ServiceStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _ServiceStyle(this.icon, this.iconColor, this.bgColor);
}

