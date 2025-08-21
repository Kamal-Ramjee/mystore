import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> placeOrder(List<CartItem> items, double total) async {
    final orderRef = _firestore.collection("orders").doc();

    final order = Order(
      orderId: orderRef.id,
      userId: userId!,
      items: items,
      total: total,
      createdAt: DateTime.now(),
    );

    await orderRef.set(order.toMap());
  }
}
