import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
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
    final ordersAsync = ref.watch(ordersProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ordersAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text('Could not load orders: $err', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(ordersProvider(null)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (allOrders) {
            // Filter by search query
            final filteredOrders = allOrders.where((o) {
              if (query.isEmpty) return true;
              return o.vendorName.toLowerCase().contains(query) ||
                  o.orderNumber.toLowerCase().contains(query) ||
                  o.category.toLowerCase().contains(query) ||
                  o.status.toLowerCase().contains(query) ||
                  o.itemsSummary.toLowerCase().contains(query);
            }).toList();

            final activeOrders = filteredOrders
                .where((o) => o.status == 'PREPARING' || o.status == 'SHIPPED')
                .toList();

            final pastOrders = filteredOrders
                .where((o) => o.status == 'DELIVERED' || o.status == 'CANCELLED')
                .toList();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(ordersProvider(null));
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

                    // 2. Header Row: "Orders" + Search Action Button
                    _buildHeaderRow(),

                    // Animated Inline Search Bar
                    if (_isSearchOpen) ...[
                      const SizedBox(height: 12),
                      _buildSearchField(),
                    ],

                    const SizedBox(height: 16),

                    // 3. Filter Pills: Active, Upcoming, Past
                    _buildFilterPills(),

                    const SizedBox(height: 18),

                    // 4. Active Order Card
                    if (_selectedFilter == 'Active' || _selectedFilter == 'All') ...[
                      if (activeOrders.isNotEmpty)
                        _buildActiveOrderCard(context, activeOrders.first)
                      else if (_selectedFilter == 'Active')
                        _buildEmptyActiveCard(context),
                      const SizedBox(height: 24),
                    ],

                    // 5. Recent Orders Section
                    if (_selectedFilter != 'Upcoming') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedFilter == 'Active' ? 'Recent orders' : 'Past orders',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            '${pastOrders.length} orders',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (pastOrders.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const Text(
                            'No past orders match your search',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        ...pastOrders.map((order) {
                          final itemsList = order.itemsSummary
                              .split(',')
                              .map((s) => s.trim())
                              .where((s) => s.isNotEmpty)
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildRecentOrderCard(
                              order: order,
                              items: itemsList,
                              onTap: () => _showOrderReceiptSheet(context, order, itemsList),
                            ),
                          );
                        }),
                    ] else ...[
                      // Upcoming Tab
                      _buildUpcomingDeliveriesSection(context),
                    ],

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          },
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
                onPressed: () => _showNotificationsDialog(context),
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

  // --- 4. Active Order Card ---
  Widget _buildActiveOrderCard(BuildContext context, OrderItem order) {
    final isFood = order.category.toUpperCase() == 'FOOD';
    final isGrocery = order.category.toUpperCase() == 'GROCERY';

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
                child: Icon(
                  isFood
                      ? Icons.restaurant_rounded
                      : (isGrocery ? Icons.shopping_basket_rounded : Icons.inventory_2_rounded),
                  color: const Color(0xFFF95738),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.category} • ${order.orderNumber}',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.vendorName,
                      style: const TextStyle(
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
                child: Text(
                  order.status,
                  style: const TextStyle(
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
            children: [
              const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                order.arrivalTimeLabel,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showActiveOrderDetailsSheet(context, order),
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

  Widget _buildEmptyActiveCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.fastfood_outlined, size: 36, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text(
            'No active orders right now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Order delicious food or groceries from nearby stores',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () async {
              final newOrder = await ref.read(apiClientProvider).createOrder(
                vendorName: 'Spice & Co.',
                category: 'FOOD',
                totalAmount: 436.0,
                itemsSummary: 'Butter Chicken Boneless, 2x Garlic Naan, Jeera Rice',
              );
              ref.invalidate(ordersProvider(null));
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF071B2F),
                  content: Text('Placed Order #${newOrder.orderNumber} with Spice & Co.!'),
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.white),
            label: const Text('Order from Spice & Co. (₹436)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Recent Order Card ---
  Widget _buildRecentOrderCard({
    required OrderItem order,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    final isCancelled = order.status == 'CANCELLED';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vendorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.arrivalTimeLabel} • ${order.orderDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(height: 1, color: AppColors.border),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  isCancelled ? Icons.cancel_outlined : Icons.check_circle_rounded,
                  size: 14,
                  color: isCancelled ? const Color(0xFFEF4444) : AppColors.accentGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isCancelled ? const Color(0xFFEF4444) : AppColors.accentGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Receipt & reorder',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Upcoming Deliveries Section ---
  Widget _buildUpcomingDeliveriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Scheduled Deliveries',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Farm Basket Subscription', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('Delivery tomorrow between 7:00 AM - 9:00 AM', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Indiranagar, Bengaluru', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subscription active. Slot confirmed for tomorrow.')),
                      );
                    },
                    child: const Text('Manage Slot', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Modal Bottom Sheet: Active Order Details ---
  void _showActiveOrderDetailsSheet(BuildContext context, OrderItem order) {
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
                        order.vendorName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order ID: ${order.orderNumber} • ${order.category}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: const TextStyle(
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
                      time: order.orderDate,
                      isCompleted: true,
                      isCurrent: false,
                    ),
                    _buildTrackingStep(
                      title: 'Store is preparing your order',
                      time: order.arrivalTimeLabel,
                      isCompleted: true,
                      isCurrent: true,
                    ),
                    _buildTrackingStep(
                      title: 'Valet assigned & heading to store',
                      time: 'Next step',
                      isCompleted: false,
                      isCurrent: false,
                    ),
                    _buildTrackingStep(
                      title: 'Delivered at Indiranagar, Bengaluru',
                      time: 'ETA 25 mins',
                      isCompleted: false,
                      isCurrent: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Items Ordered',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...order.itemsSummary.split(',').map((it) => _buildBillRow(it.trim(), '')),
              const Divider(height: 20, color: AppColors.border),
              _buildBillRow('Delivery Fee & Taxes', 'Included'),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCallDialog(context, order.vendorName, '+91 80 4920 1100');
                      },
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: const Text('Call Store'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showLiveTrackingDialog(context, order);
                      },
                      icon: const Icon(Icons.navigation_outlined, size: 18, color: Colors.white),
                      label: const Text('Track Live', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Cancel Order Button
              Center(
                child: TextButton(
                  onPressed: () => _confirmCancelOrder(context, order),
                  child: const Text('Cancel Order', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Modal Bottom Sheet: Past Order Receipt ---
  void _showOrderReceiptSheet(
    BuildContext context,
    OrderItem order,
    List<String> items,
  ) {
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
                        order.vendorName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.orderNumber} • ${order.category}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: order.status == 'CANCELLED' ? const Color(0xFFFEE2E2) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: order.status == 'CANCELLED' ? const Color(0xFFDC2626) : AppColors.textPrimary,
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
                  Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tax invoice #${order.orderNumber}.pdf downloaded to device.'),
                            action: SnackBarAction(label: 'View', onPressed: () {}),
                          ),
                        );
                      },
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
                      onPressed: () async {
                        Navigator.pop(context);
                        final newOrder = await ref.read(apiClientProvider).createOrder(
                          vendorName: order.vendorName,
                          category: order.category,
                          totalAmount: order.totalAmount,
                          itemsSummary: order.itemsSummary,
                        );
                        ref.invalidate(ordersProvider(null));
                        setState(() => _selectedFilter = 'Active');
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF071B2F),
                            content: Text('Reordered from ${order.vendorName}! Order #${newOrder.orderNumber} is now preparing.'),
                          ),
                        );
                      },
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

  void _confirmCancelOrder(BuildContext context, OrderItem order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Order?'),
        content: Text('Are you sure you want to cancel order #${order.orderNumber} with ${order.vendorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close sheet
              await ref.read(apiClientProvider).cancelOrder(order.id);
              ref.invalidate(ordersProvider(null));
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFFDC2626),
                  content: Text('Order #${order.orderNumber} cancelled successfully.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String vendor, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFD1FADF), shape: BoxShape.circle),
              child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF027A48), size: 36),
            ),
            const SizedBox(height: 16),
            Text('Calling $vendor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Text(phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Connected • 00:04', style: TextStyle(color: Color(0xFF027A48), fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.call_end_rounded, color: Colors.white),
              label: const Text('End Call', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveTrackingDialog(BuildContext context, OrderItem order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text('Live Delivery Tracking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF071B2F),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.two_wheeler_rounded, color: Color(0xFF38BDF8), size: 36),
                  SizedBox(height: 6),
                  Text('Driver Ramesh K. is 1.4 km away', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('TVS Apache • KA-05-JK-1922', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Estimated arrival: ${order.arrivalTimeLabel}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Destination: 100ft Road, Indiranagar, Bengaluru', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Orders', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.local_offer_rounded, color: AppColors.primary),
              title: Text('WELCOME50 Promo applied!'),
              subtitle: Text('Flat 50% discount active on your food order.'),
            ),
            ListTile(
              leading: Icon(Icons.check_circle_rounded, color: AppColors.accentGreen),
              title: Text('Live MySQL sync connected'),
              subtitle: Text('Orders and bookings persist in real-time.'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? (isCurrent ? AppColors.primary : AppColors.accentGreen)
                    : Colors.white,
                border: Border.all(
                  color: isCompleted
                      ? (isCurrent ? AppColors.primary : AppColors.accentGreen)
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.accentGreen : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
