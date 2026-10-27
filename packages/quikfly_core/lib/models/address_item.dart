class AddressItem {
  final int id;
  final int userId;
  final String label;
  final String addressLine;
  final String locality;
  final String city;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
    required this.locality,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  String get formattedTitle => '$locality, $city';

  String get fullDisplayAddress => '$addressLine, $locality, $city';

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      label: json['label'] as String? ?? 'Home',
      addressLine: json['address_line'] as String? ?? '',
      locality: json['locality'] as String? ?? 'Indiranagar',
      city: json['city'] as String? ?? 'Bengaluru',
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : double.tryParse(json['latitude']?.toString() ?? '12.9784') ?? 12.9784,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : double.tryParse(json['longitude']?.toString() ?? '77.6408') ?? 77.6408,
      isDefault: json['is_default'] == true || json['is_default'] == 1 || json['is_default'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address_line': addressLine,
      'locality': locality,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  AddressItem copyWith({
    int? id,
    int? userId,
    String? label,
    String? addressLine,
    String? locality,
    String? city,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
