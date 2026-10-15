import '../models/banner_item.dart';
import '../models/merchant_item.dart';
import '../models/service_item.dart';
import '../models/user_model.dart';

class HomeFeedDTO {
  final UserModel user;
  final List<BannerItem> heroBanners;
  final List<ServiceItem> services;
  final List<MerchantItem> popularMerchants;
  final BannerItem? safetyBanner;

  const HomeFeedDTO({
    required this.user,
    required this.heroBanners,
    required this.services,
    required this.popularMerchants,
    this.safetyBanner,
  });

  factory HomeFeedDTO.fromJson(Map<String, dynamic> json) {
    return HomeFeedDTO(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      heroBanners: (json['hero_banners'] as List? ?? json['heroBanners'] as List? ?? [])
          .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularMerchants: (json['popular_merchants'] as List? ?? json['popularMerchants'] as List? ?? [])
          .map((e) => MerchantItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      safetyBanner: json['safety_banner'] != null
          ? BannerItem.fromJson(json['safety_banner'] as Map<String, dynamic>)
          : (json['safetyBanner'] != null ? BannerItem.fromJson(json['safetyBanner'] as Map<String, dynamic>) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'hero_banners': heroBanners.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'popular_merchants': popularMerchants.map((e) => e.toJson()).toList(),
      'safety_banner': safetyBanner?.toJson(),
    };
  }
}
