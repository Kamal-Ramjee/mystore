import 'package:mystore/models/cart_item.dart';

class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status; // pending, shipped, delivered

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = "pending",
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
