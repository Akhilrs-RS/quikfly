class OrderItem {
  final int id;
  final String orderNumber;
  final String vendorName;
  final String category;
  final String status;
  final String arrivalTimeLabel;
  final double totalAmount;
  final String itemsSummary;
  final String orderDate;

  const OrderItem({
    required this.id,
    required this.orderNumber,
    required this.vendorName,
    required this.category,
    required this.status,
    required this.arrivalTimeLabel,
    required this.totalAmount,
    required this.itemsSummary,
    required this.orderDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      orderNumber: (json['order_number'] ?? json['orderNumber']) as String? ?? '',
      vendorName: (json['vendor_name'] ?? json['vendorName']) as String? ?? '',
      category: json['category'] as String? ?? 'FOOD',
      status: json['status'] as String? ?? 'PREPARING',
      arrivalTimeLabel: (json['arrival_time_label'] ?? json['arrivalTimeLabel']) as String? ?? '',
      totalAmount: json['total_amount'] is num
          ? (json['total_amount'] as num).toDouble()
          : (json['totalAmount'] is num
              ? (json['totalAmount'] as num).toDouble()
              : double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0),
      itemsSummary: (json['items_summary'] ?? json['itemsSummary']) as String? ?? '',
      orderDate: (json['order_date'] ?? json['orderDate']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'vendor_name': vendorName,
      'category': category,
      'status': status,
      'arrival_time_label': arrivalTimeLabel,
      'total_amount': totalAmount,
      'items_summary': itemsSummary,
      'order_date': orderDate,
    };
  }
}
