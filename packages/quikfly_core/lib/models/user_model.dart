class UserModel {
  final int id;
  final String phone;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final String activeLocality;
  final String activeCity;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    this.avatarUrl,
    this.activeLocality = 'Indiranagar',
    this.activeCity = 'Bengaluru',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] ?? json['fullName'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] as String?,
      activeLocality: json['active_locality'] ?? json['activeLocality'] as String? ?? 'Indiranagar',
      activeCity: json['active_city'] ?? json['activeCity'] as String? ?? 'Bengaluru',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'active_locality': activeLocality,
      'active_city': activeCity,
    };
  }
}
