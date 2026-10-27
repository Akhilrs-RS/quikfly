import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _selectedFilter = 'Active';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuickTripBookingSheet(context),
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Book New Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text('Could not load bookings: $err', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(bookingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (allBookings) {
            final filteredBookings = allBookings.where((b) {
              if (query.isEmpty) return true;
              return b.title.toLowerCase().contains(query) ||
                  b.bookingCode.toLowerCase().contains(query) ||
                  b.subtitle.toLowerCase().contains(query) ||
                  b.status.toLowerCase().contains(query) ||
                  (b.route?.toLowerCase().contains(query) ?? false);
            }).toList();

            final confirmedBookings = filteredBookings
                .where((b) => b.status == 'CONFIRMED' || b.status == 'RESERVED')
                .toList();

            final pastBookings = filteredBookings
                .where((b) => b.status == 'COMPLETED' || b.status == 'CANCELLED')
                .toList();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(bookingsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 1. Top Bar: Logo, Name, Notification Bell, User Avatar
                    _buildTopBar(context),

                    const SizedBox(height: 18),

                    // 2. Screen Title: Bookings
                    const Text(
                      'Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. Search Bar
                    _buildSearchBar(),

                    const SizedBox(height: 16),

                    // 4. Filter Pills: Active, Upcoming, Past
                    _buildFilterPills(),

                    const SizedBox(height: 18),

                    // 5. Active Card (Dark Navy Hero Card from Figma)
                    if (_selectedFilter == 'Active' || _selectedFilter == 'All') ...[
                      _buildActiveRideCard(context),
                      const SizedBox(height: 24),
                    ],

                    // 6. Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedFilter == 'Past' ? 'Past Bookings' : 'Upcoming Trips & Rentals',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_selectedFilter == 'Past' ? pastBookings.length : confirmedBookings.length} bookings',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 7. Dynamic Bookings List from MySQL
                    if (_selectedFilter == 'Past') ...[
                      if (pastBookings.isEmpty)
                        _buildEmptyState('No past bookings recorded.')
                      else
                        ...pastBookings.map((b) => _buildBookingCard(b)),
                    ] else ...[
                      if (confirmedBookings.isEmpty)
                        _buildEmptyState('No upcoming bookings right now.')
                      else
                        ...confirmedBookings.map((b) => _buildBookingCard(b)),
                    ],

                    const SizedBox(height: 70),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingItem booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildUpcomingItem(
        booking: booking,
        onTap: () => _showBookingDetails(context, booking),
      ),
    );
  }

  // --- 1. Top Bar ---
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.electric_bolt_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'QuikFly',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        // Notification Bell
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            color: AppColors.textPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All trips are confirmed and synced with MySQL')),
              );
            },
            splashRadius: 20,
          ),
        ),
        const SizedBox(width: 10),
        // User Avatar
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Search Bar ---
  Widget _buildSearchBar() {
    return Container(
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
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search bus, car rentals, or booking ID...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Icon(Icons.cancel_rounded, color: AppColors.textMuted, size: 18),
            ),
        ],
      ),
    );
  }

  // --- 4. Filter Pills ---
  Widget _buildFilterPills() {
    final filters = ['Active', 'Upcoming', 'Past'];

    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF09182B) : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF09182B) : AppColors.border,
                  width: 1,
                ),
                boxShadow: isSelected ? AppColors.cardShadow : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 5. Active Ride Card (Dark Navy Hero) ---
  Widget _buildActiveRideCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF071B2F),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071B2F).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: Color(0xFF38BDF8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ACTIVE TRIP • QF-828591',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Airport Express Ride',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF063A2F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'CONFIRMED',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),

          Row(
            children: const [
              Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF94A3B8)),
              SizedBox(width: 6),
              Text(
                'Pickup at 7:30 PM • Driver 1.4 km away',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text('₹ 542', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showActiveRideDetails(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('View details', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12.5, fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF38BDF8)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Upcoming Item Card ---
  Widget _buildUpcomingItem({
    required BookingItem booking,
    required VoidCallback onTap,
  }) {
    final isCancelled = booking.status == 'CANCELLED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: booking.title.toLowerCase().contains('bus')
                    ? AppColors.primary.withOpacity(0.1)
                    : const Color(0xFFF95738).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                booking.title.toLowerCase().contains('bus')
                    ? Icons.directions_bus_rounded
                    : Icons.car_rental_rounded,
                color: booking.title.toLowerCase().contains('bus')
                    ? AppColors.primary
                    : const Color(0xFFF95738),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${booking.subtitle} • ${booking.bookingCode}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCancelled ? const Color(0xFFDC2626) : AppColors.accentGreen,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹ ${booking.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'View Ticket',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Modal Bottom Sheet: Quick Trip Booking ---
  void _showQuickTripBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
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
            const SizedBox(height: 18),
            const Text('Book an Instant Getaway / Trip', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Select an offering to reserve in real time', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),

            _buildQuickTripOption(
              title: 'Luxury Sleeper Bus to Ooty',
              subtitle: 'Departs Tomorrow 07:00 AM • Indiranagar Hub',
              price: 850.0,
              route: 'Indiranagar, BLR → Ooty Bus Stand',
              seatNo: 'Seat 12B (Lower Deck)',
            ),
            const SizedBox(height: 10),
            _buildQuickTripOption(
              title: 'Mahindra Thar 4x4 Rental',
              subtitle: 'Self-drive • 24 Hours • Free Fuel',
              price: 3499.0,
              route: 'Self-Drive Pickup: Indiranagar Hub',
              seatNo: 'KA-05-MM-4402',
            ),
            const SizedBox(height: 10),
            _buildQuickTripOption(
              title: 'Coorg Hill Resort Partner Pack',
              subtitle: '2 Days / 1 Night • Resort Stay + Travel',
              price: 4999.0,
              route: 'Bengaluru → Madikeri, Coorg',
              seatNo: 'Cottage #204 • Deluxe Suite',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTripOption({
    required String title,
    required String subtitle,
    required double price,
    required String route,
    required String seatNo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final newBooking = await ref.read(apiClientProvider).createBooking(
                title: title,
                subtitle: subtitle,
                price: price,
                route: route,
                seatNo: seatNo,
              );
              ref.invalidate(bookingsProvider);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF071B2F),
                  content: Text('Trip Confirmed! Booking Code: ${newBooking.bookingCode}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Book Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- Modal Bottom Sheet Details ---
  void _showActiveRideDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
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
            const SizedBox(height: 18),
            Row(
              children: [
                const Text('Ride Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DRIVER ASSIGNED', style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Booking ID: QF-828591', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            _buildRouteRow(Icons.circle, AppColors.accentGreen, '100ft Road, Indiranagar', 'Pickup at 7:30 PM'),
            const SizedBox(height: 12),
            _buildRouteRow(Icons.location_on, AppColors.accentOrange, 'Kempegowda Int. Airport Terminal 1', 'Drop-off'),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Total Fare', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('₹ 542.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live map tracking active. Driver is arriving in 8 minutes.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Live Track Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingItem booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.status == 'CANCELLED' ? const Color(0xFFFEE2E2) : AppColors.accentGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: booking.status == 'CANCELLED' ? const Color(0xFFDC2626) : AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(booking.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 16),
            const Text('Route / Hub:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(booking.route ?? 'Bengaluru Center', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text('Details: ${booking.seatNo ?? 'Reserved'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fare Paid', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('₹ ${booking.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showTicketPassDialog(context, booking);
                    },
                    icon: const Icon(Icons.qr_code_rounded, size: 18),
                    label: const Text('View Ticket Pass'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (booking.status != 'CANCELLED') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(apiClientProvider).cancelBooking(booking.id);
                        ref.invalidate(bookingsProvider);
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFDC2626),
                            content: Text('Cancelled booking ${booking.bookingCode}. Refund initiated to Wallet.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.white),
                      label: const Text('Cancel Trip', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketPassDialog(BuildContext context, BookingItem booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(booking.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 4),
            Text('Booking Code: ${booking.bookingCode}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Text(booking.route ?? 'Bengaluru Route', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(booking.seatNo ?? 'Seat Confirmed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
