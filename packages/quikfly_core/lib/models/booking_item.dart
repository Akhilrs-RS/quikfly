class BookingItem {
  final int id;
  final String bookingCode;
  final String title;
  final String subtitle;
  final double price;
  final String? route;
  final String? seatNo;
  final String status;
  final String bookingDate;

  const BookingItem({
    required this.id,
    required this.bookingCode,
    required this.title,
    required this.subtitle,
    required this.price,
    this.route,
    this.seatNo,
    required this.status,
    required this.bookingDate,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      bookingCode: (json['booking_code'] ?? json['bookingCode']) as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      route: json['route'] as String?,
      seatNo: (json['seat_no'] ?? json['seatNo']) as String?,
      status: json['status'] as String? ?? 'CONFIRMED',
      bookingDate: (json['booking_date'] ?? json['bookingDate']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'route': route,
      'seat_no': seatNo,
      'status': status,
      'booking_date': bookingDate,
    };
  }
}
