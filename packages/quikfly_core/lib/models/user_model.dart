class UserModel {
  final int id;
  final String phone;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final String activeLocality;
  final String activeCity;
  final double walletBalance;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    this.avatarUrl,
    this.activeLocality = 'Indiranagar',
    this.activeCity = 'Bengaluru',
    this.walletBalance = 1450.00,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      phone: json['phone'] as String? ?? '+919876548219',
      email: json['email'] as String?,
      fullName: json['full_name'] ?? json['fullName'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] as String?,
      activeLocality: json['active_locality'] ?? json['activeLocality'] as String? ?? 'Indiranagar',
      activeCity: json['active_city'] ?? json['activeCity'] as String? ?? 'Bengaluru',
      walletBalance: json['wallet_balance'] is num
          ? (json['wallet_balance'] as num).toDouble()
          : (json['walletBalance'] is num
              ? (json['walletBalance'] as num).toDouble()
              : double.tryParse(json['wallet_balance']?.toString() ?? '1450') ?? 1450.0),
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
      'wallet_balance': walletBalance,
    };
  }
}
