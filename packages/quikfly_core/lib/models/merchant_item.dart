class MerchantItem {
  final int id;
  final String name;
  final String category;
  final double rating;
  final int deliveryTimeMin;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final bool isOpen;

  const MerchantItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.deliveryTimeMin,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
  });

  factory MerchantItem.fromJson(Map<String, dynamic> json) {
    return MerchantItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String,
      category: json['category'] as String,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : double.parse(json['rating'].toString()),
      deliveryTimeMin: json['delivery_time_min'] is int
          ? json['delivery_time_min'] as int
          : int.tryParse(json['delivery_time_min']?.toString() ?? '25') ?? 25,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : double.parse(json['latitude'].toString()),
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : double.parse(json['longitude'].toString()),
      isOpen: json['is_open'] == 1 || json['is_open'] == true || json['isOpen'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'delivery_time_min': deliveryTimeMin,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'is_open': isOpen,
    };
  }
}
