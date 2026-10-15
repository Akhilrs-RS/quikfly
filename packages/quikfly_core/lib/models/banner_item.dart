enum BannerType {
  hero,
  story,
  safety;

  static BannerType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'story':
        return BannerType.story;
      case 'safety':
        return BannerType.safety;
      case 'hero':
      default:
        return BannerType.hero;
    }
  }
}

class BannerItem {
  final int id;
  final BannerType type;
  final String? tagline;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final String imageUrl;
  final String? actionRoute;
  final int sortOrder;

  const BannerItem({
    required this.id,
    required this.type,
    this.tagline,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    required this.imageUrl,
    this.actionRoute,
    this.sortOrder = 0,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      type: BannerType.fromString(json['type'] as String? ?? 'hero'),
      tagline: json['tagline'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      buttonLabel: json['button_label'] ?? json['buttonLabel'] as String?,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      actionRoute: json['action_route'] ?? json['actionRoute'] as String?,
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'tagline': tagline,
      'title': title,
      'subtitle': subtitle,
      'button_label': buttonLabel,
      'image_url': imageUrl,
      'action_route': actionRoute,
      'sort_order': sortOrder,
    };
  }
}
