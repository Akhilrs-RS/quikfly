import 'package:flutter/material.dart';
import 'package:quikfly_core/quikfly_core.dart';
import '../../../../app/theme/app_colors.dart';

class ServicesGridWidget extends StatelessWidget {
  final List<ServiceItem> services;
  final ValueChanged<ServiceItem>? onServiceSelected;
  final VoidCallback? onViewAllTap;

  const ServicesGridWidget({
    super.key,
    required this.services,
    this.onServiceSelected,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'What do you need?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length > 8 ? 8 : services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              final styling = _getServiceStyling(service.code);

              return GestureDetector(
                onTap: () => onServiceSelected?.call(service),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: AppColors.cardShadow,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: styling.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          styling.icon,
                          color: styling.iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _ServiceStyle _getServiceStyling(String code) {
    switch (code) {
      case 'bike_taxi':
        return const _ServiceStyle(
          icon: Icons.two_wheeler_rounded,
          iconColor: Color(0xFF2B66F6),
          bgColor: Color(0xFFEFF4FF),
        );
      case 'car_taxi':
        return const _ServiceStyle(
          icon: Icons.directions_car_rounded,
          iconColor: Color(0xFF2B66F6),
          bgColor: Color(0xFFEFF4FF),
        );
      case 'food':
        return const _ServiceStyle(
          icon: Icons.restaurant_rounded,
          iconColor: Color(0xFFF79009),
          bgColor: Color(0xFFFEF0C7),
        );
      case 'grocery':
        return const _ServiceStyle(
          icon: Icons.shopping_basket_rounded,
          iconColor: Color(0xFF12B76A),
          bgColor: Color(0xFFD1FADF),
        );
      case 'bus':
        return const _ServiceStyle(
          icon: Icons.directions_bus_rounded,
          iconColor: Color(0xFF7A5AF8),
          bgColor: Color(0xFFF4EBFF),
        );
      case 'delivery':
        return const _ServiceStyle(
          icon: Icons.send_rounded,
          iconColor: Color(0xFF0BA5EC),
          bgColor: Color(0xFFE0F2FE),
        );
      case 'rentals':
        return const _ServiceStyle(
          icon: Icons.key_rounded,
          iconColor: Color(0xFFF04438),
          bgColor: Color(0xFFFEE4E2),
        );
      case 'marketplace':
      default:
        return const _ServiceStyle(
          icon: Icons.storefront_rounded,
          iconColor: Color(0xFFEE46BC),
          bgColor: Color(0xFFFCE7F6),
        );
    }
  }
}

class _ServiceStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _ServiceStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
