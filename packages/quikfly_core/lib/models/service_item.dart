enum ServiceCategory {
  everyday,
  travel,
  shopping;

  static ServiceCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'travel':
        return ServiceCategory.travel;
      case 'shopping':
        return ServiceCategory.shopping;
      case 'everyday':
      default:
        return ServiceCategory.everyday;
    }
  }
}

class ServiceItem {
  final int id;
  final String code;
  final String title;
  final String subtitle;
  final String iconName;
  final ServiceCategory category;
  final bool isFeatured;
  final int sortOrder;

  const ServiceItem({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.category,
    this.isFeatured = true,
    this.sortOrder = 0,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      code: json['code'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['icon_name'] ?? json['iconName'] ?? 'local_taxi',
      category: ServiceCategory.fromString(json['category'] as String? ?? 'everyday'),
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true || json['isFeatured'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'subtitle': subtitle,
      'icon_name': iconName,
      'category': category.name,
      'is_featured': isFeatured,
      'sort_order': sortOrder,
    };
  }
}
