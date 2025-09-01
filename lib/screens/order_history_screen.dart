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
        body: Center(
          child: Text(
            "Please log in to view your orders",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF397CA9),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user.uid)
            // .orderBy("createdAt", descending: true)
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
            return const Center(
              child: Text(
                "No orders found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
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
                elevation: 5,
                shadowColor: Colors.black26,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  title: Text(
                    "Order #$orderId",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF397CA9)),
                      ),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: status == "Delivered"
                              ? Colors.green
                              : (status == "Pending"
                              ? Colors.orange
                              : Colors.redAccent),
                        ),
                      ),
                      Text(
                        "Date: ${dateTime.toLocal().toString().substring(0, 16)}",
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7EC8E3), Color(0xFFFBC7A9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: items.map((item) {
                          final name = item["name"] ?? "Unknown item";
                          final price = (item["price"] ?? 0).toDouble();
                          final quantity = item["quantity"] ?? 1;
                          final imageUrl = item["imageUrl"] ?? ""; // <-- get product image



                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                  )
                                      : const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Qty: $quantity",
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\$${(price * quantity).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF397CA9),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
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
