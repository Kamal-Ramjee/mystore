import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your orders")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;

              final orderId = data["orderId"] ?? orders[index].id;
              final total = (data["total"] ?? 0).toDouble();
              final status = data["status"] ?? "Pending";

              DateTime dateTime = DateTime.now();
              if (data["createdAt"] is Timestamp) {
                dateTime = (data["createdAt"] as Timestamp).toDate();
              }

              final items = (data["items"] as List<dynamic>? ?? []);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Order #$orderId"),
                  subtitle: Text(
                    "Total: \$${total.toStringAsFixed(2)}\n"
                        "Status: $status\n"
                        "Date: ${dateTime.toLocal()}",
                  ),
                  children: [
                    ...items.map((item) {
                      final name = item["name"] ?? "Unknown item";
                      final price = (item["price"] ?? 0).toDouble();
                      final quantity = item["quantity"] ?? 1;

                      return ListTile(
                        dense: true,
                        title: Text(name),
                        subtitle: Text("Quantity: $quantity"),
                        trailing: Text("\$${(price * quantity).toStringAsFixed(2)}"),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
