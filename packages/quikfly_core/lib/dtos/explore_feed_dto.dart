import '../models/banner_item.dart';
import '../models/service_item.dart';

class ExploreFeedDTO {
  final List<String> categories;
  final List<ServiceItem> services;
  final BannerItem? weekendInspiration;
  final List<ServiceItem> travelOfferings;

  const ExploreFeedDTO({
    required this.categories,
    required this.services,
    this.weekendInspiration,
    required this.travelOfferings,
  });

  factory ExploreFeedDTO.fromJson(Map<String, dynamic> json) {
    return ExploreFeedDTO(
      categories: (json['categories'] as List? ?? ['all', 'everyday', 'travel', 'shopping'])
          .map((e) => e.toString())
          .toList(),
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekendInspiration: json['weekend_inspiration'] != null
          ? BannerItem.fromJson(json['weekend_inspiration'] as Map<String, dynamic>)
          : (json['weekendInspiration'] != null
              ? BannerItem.fromJson(json['weekendInspiration'] as Map<String, dynamic>)
              : null),
      travelOfferings: (json['travel_offerings'] as List? ?? json['travelOfferings'] as List? ?? [])
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'services': services.map((e) => e.toJson()).toList(),
      'weekend_inspiration': weekendInspiration?.toJson(),
      'travel_offerings': travelOfferings.map((e) => e.toJson()).toList(),
    };
  }
}
