import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Place an order for current user with all user details
  Future<void> placeOrder(List<CartItem> items, double total) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final orderRef = _db.collection("orders").doc();

    // Get user profile from Firestore
    final userDoc = await _db.collection("users").doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    await orderRef.set({
      "orderId": orderRef.id,
      "userId": user.uid,
      "userName": userData["name"] ?? user.displayName ?? "Unknown",
      "userEmail": user.email ?? "",
      "userPhone": userData["phone"] ?? "",
      "items": items.map((e) => {
        "name": e.name,
        "price": e.price,
        "quantity": e.quantity,
      }).toList(),
      "total": total,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Get orders of current user
  Stream<QuerySnapshot> getOrdersByUser() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    return _db
        .collection("orders")
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Get all orders for admin
  Stream<QuerySnapshot> getAllOrders() {
    return _db
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Update order status (Admin)
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection("orders").doc(orderId).update({
      "status": status,
    });
  }
}
