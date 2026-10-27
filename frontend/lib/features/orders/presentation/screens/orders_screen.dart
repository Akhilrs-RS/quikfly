import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'Active';
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Top Bar: Logo, Name, Notification Bell, User Avatar
              _buildTopBar(context),

              const SizedBox(height: 18),

              // 2. Header Row: "Orders" + Search Action Button
              _buildHeaderRow(),

              // Animated Inline Search Bar (expands when search icon tapped)
              if (_isSearchOpen) ...[
                const SizedBox(height: 12),
                _buildSearchField(),
              ],

              const SizedBox(height: 16),

              // 3. Filter Pills: Active, Upcoming, Past
              _buildFilterPills(),

              const SizedBox(height: 18),

              // 4. Active Order Card (Spice & Co.)
              if ((_selectedFilter == 'Active' || _selectedFilter == 'All') &&
                  (query.isEmpty ||
                      'spice & co.'.contains(query) ||
                      'food'.contains(query) ||
                      'qf-071833'.contains(query) ||
                      'preparing'.contains(query))) ...[
                _buildActiveOrderCard(context),
                const SizedBox(height: 24),
              ],

              // 5. Recent Orders Section
              if (_selectedFilter != 'Upcoming') ...[
                const Text(
                  'Recent orders',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Item 1: Fresh Basket
                if (query.isEmpty ||
                    'fresh basket'.contains(query) ||
                    'delivered'.contains(query) ||
                    'grocery'.contains(query))
                  _buildRecentOrderCard(
                    title: 'Fresh Basket',
                    subtitle: 'Delivered • 16 Jul',
                    price: '₹782',
                    status: 'Delivered',
                    items: const [
                      'Organic Farm Milk (1L)',
                      'Country Eggs (Pack of 12)',
                      'Fresh Spinach (500g)',
                      'Kashmiri Apples (1kg)',
                    ],
                    onTap: () => _showOrderReceiptSheet(
                      context,
                      title: 'Fresh Basket',
                      orderId: 'QF-068912',
                      category: 'GROCERY',
                      status: 'Delivered • 16 Jul',
                      price: '₹782',
                      items: const [
                        'Organic Farm Milk (1L)',
                        'Country Eggs (Pack of 12)',
                        'Fresh Spinach (500g)',
                        'Kashmiri Apples (1kg)',
                      ],
                    ),
                  ),

                if (query.isEmpty ||
                    'nova audio'.contains(query) ||
                    'shipped'.contains(query) ||
                    'electronics'.contains(query)) ...[
                  const SizedBox(height: 10),

                  // Item 2: Nova Audio
                  _buildRecentOrderCard(
                    title: 'Nova Audio',
                    subtitle: 'Shipped • 14 Jul',
                    price: '₹2,849',
                    status: 'Shipped',
                    items: const [
                      'Nova Wireless ANC Earbuds Pro',
                      'Braided USB-C Fast Cable',
                    ],
                    onTap: () => _showOrderReceiptSheet(
                      context,
                      title: 'Nova Audio',
                      orderId: 'QF-065401',
                      category: 'ELECTRONICS',
                      status: 'Shipped • 14 Jul',
                      price: '₹2,849',
                      items: const [
                        'Nova Wireless ANC Earbuds Pro',
                        'Braided USB-C Fast Cable',
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // When Upcoming filter is selected
                const Text(
                  'Upcoming Deliveries',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentOrderCard(
                  title: 'Nova Audio',
                  subtitle: 'In Transit • Expected Tomorrow, 2 PM',
                  price: '₹2,849',
                  status: 'Shipped',
                  items: const [
                    'Nova Wireless ANC Earbuds Pro',
                    'Braided USB-C Fast Cable',
                  ],
                  onTap: () => _showOrderReceiptSheet(
                    context,
                    title: 'Nova Audio',
                    orderId: 'QF-065401',
                    category: 'ELECTRONICS',
                    status: 'Shipped • Arriving Tomorrow',
                    price: '₹2,849',
                    items: const [
                      'Nova Wireless ANC Earbuds Pro',
                      'Braided USB-C Fast Cable',
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
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
        // Notification Bell with Badge
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 22),
                color: AppColors.textPrimary,
                onPressed: () {},
                splashRadius: 20,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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

  // --- 2. Header Row ---
  Widget _buildHeaderRow() {
    return Row(
      children: [
        const Text(
          'Orders',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchOpen = !_isSearchOpen;
              if (!_isSearchOpen) {
                _searchController.clear();
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isSearchOpen ? AppColors.primary : AppColors.border,
                width: _isSearchOpen ? 1.5 : 1,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: _isSearchOpen ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // --- Search Input Field ---
  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
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
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search orders, items or order ID...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
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

  // --- 3. Filter Pills ---
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

  // --- 4. Active Order Card (Spice & Co.) ---
  Widget _buildActiveOrderCard(BuildContext context) {
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
          // Top Row: Cutlery Icon + Category/ID + Title + "PREPARING" Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // White icon container with orange cutlery
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Color(0xFFF95738),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'FOOD • QF-071833',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Spice & Co.',
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
              // "PREPARING" Status Badge
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
                  'PREPARING',
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

          // Thin Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),

          const SizedBox(height: 12),

          // Details Row: Arrival Time & Total Price
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              const Text(
                'Arrives in 24-28 min',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Text(
                '₹436',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom Action Link: "View details ->"
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showActiveOrderDetailsSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View details',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF38BDF8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Recent Order Card ---
  Widget _buildRecentOrderCard({
    required String title,
    required String subtitle,
    required String price,
    required String status,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Package / Box Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              price,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Modal Bottom Sheet: Active Order Live Tracker ---
  void _showActiveOrderDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
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
              const SizedBox(height: 18),

              // Title and Order ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Spice & Co.',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Order ID: QF-071833 • Food Delivery',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PREPARING',
                      style: TextStyle(
                        color: Color(0xFF027A48),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Live Status Stepper
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildTrackingStep(
                      title: 'Order Confirmed',
                      time: '12:45 PM',
                      isCompleted: true,
                      isCurrent: false,
                    ),
                    _buildTrackingStep(
                      title: 'Kitchen is Preparing your order',
                      time: 'Estimated 15 mins',
                      isCompleted: true,
                      isCurrent: true,
                    ),
                    _buildTrackingStep(
                      title: 'Valet Assigned & Heading to Store',
                      time: 'Next step',
                      isCompleted: false,
                      isCurrent: false,
                    ),
                    _buildTrackingStep(
                      title: 'Delivered at Indiranagar, Bengaluru',
                      time: 'ETA 1:15 PM',
                      isCompleted: false,
                      isCurrent: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Order Items Breakdown
              const Text(
                'Items Ordered',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _buildBillRow('1x Butter Chicken Boneless', '₹260'),
              _buildBillRow('2x Garlic Naan', '₹96'),
              _buildBillRow('1x Jeera Rice', '₹80'),
              const Divider(height: 20, color: AppColors.border),
              _buildBillRow('Delivery Fee & Taxes', 'Included'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Total Paid', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('₹436', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 22),

              // Action buttons: Track Live & Support
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: const Text('Call Restaurant'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
                      label: const Text('Track Delivery', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Modal Bottom Sheet: Past Order Receipt ---
  void _showOrderReceiptSheet(
    BuildContext context, {
    required String title,
    required String orderId,
    required String category,
    required String status,
    required String price,
    required List<String> items,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$orderId • $category',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.split('•').first.trim().toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Items Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accentGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24, color: AppColors.border),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.receipt_outlined, size: 18),
                      label: const Text('Download Invoice'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.repeat_rounded, size: 18, color: Colors.white),
                      label: const Text('Reorder', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Tracking Stepper Helper ---
  Widget _buildTrackingStep({
    required String title,
    required String time,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    final dotColor = isCurrent
        ? AppColors.primary
        : (isCompleted ? AppColors.accentGreen : AppColors.border);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.primaryLight : Colors.white,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.accentGreen.withOpacity(0.5) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Bill Row Helper ---
  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
