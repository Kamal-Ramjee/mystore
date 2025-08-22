import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection("orders");

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: ordersRef.doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading order details"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!.data() as Map<String, dynamic>;

          // User details
          final userName = order["userName"] ?? "Unknown";
          final userEmail = order["userEmail"] ?? "";
          final userPhone = order["userPhone"] ?? "";

          // Order details
          final status = order["status"] ?? "Pending";
          final total = (order["total"] is int)
              ? (order["total"] as int).toDouble()
              : (order["total"] ?? 0.0) as double;

          // Date
          DateTime dateTime = DateTime.now();
          final createdAt = order["createdAt"];
          if (createdAt is Timestamp) {
            dateTime = createdAt.toDate();
          } else if (createdAt is String) {
            dateTime = DateTime.tryParse(createdAt) ?? DateTime.now();
          }
          final formattedDate =
              "${dateTime.day}/${dateTime.month}/${dateTime.year}  ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

          // Items
          final List items = order["items"] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text("Order ID: $orderId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("User Name: $userName"),
                Text("Email: $userEmail"),
                Text("Phone: $userPhone"),
                const SizedBox(height: 16),
                Text("Order Date: $formattedDate"),
                Text("Status: $status"),
                const SizedBox(height: 16),
                const Text("Items:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final name = item["name"] ?? "";
                  final quantity = item["quantity"] ?? 0;
                  final price = (item["price"] is int)
                      ? (item["price"] as int).toDouble()
                      : (item["price"] ?? 0.0) as double;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text("Qty: $quantity"),
                    trailing: Text("\$${(price * quantity).toStringAsFixed(2)}"),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Text("Total: \$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
