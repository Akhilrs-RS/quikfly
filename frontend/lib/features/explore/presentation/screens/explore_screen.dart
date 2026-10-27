import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/explore_controller.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          onPressed: () {},
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
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search all services',
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 18),
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
                  const Text(
                    'All services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2-Column Services Grid with Chevrons
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feed.services.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final service = feed.services[index];
                      final style = _getServiceStyle(service.code);

                      return Container(
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
                    Container(
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

                  const SizedBox(height: 14),

                  // Flights & Hotels Card
                  Container(
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
                                'Curated partner partner escapes',
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

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
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
