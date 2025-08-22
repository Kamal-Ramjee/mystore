import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              final orderId = orderData["orderId"] ?? orderDoc.id;
              final total = (orderData["total"] is int)
                  ? (orderData["total"] as int).toDouble()
                  : (orderData["total"] ?? 0.0) as double;

              String status = orderData["status"] ?? "Pending";

              // Ensure the status is one of the valid options, as you requested.
              final List<String> validStatuses = ["Pending", "Shipped", "Delivered"];
              if (!validStatuses.contains(status)) {
                status = "Pending";
              }

              // User details
              final userName = orderData["userName"] ?? "Unknown";
              final userEmail = orderData["userEmail"] ?? "";
              final userPhone = orderData["userPhone"] ?? "";

              // Items
              final items = orderData["items"] as List<dynamic>? ?? [];

              // Order Date
              DateTime dateTime = DateTime.now();
              final createdAt = orderData["createdAt"];
              if (createdAt is Timestamp) {
                dateTime = createdAt.toDate();
              }
              final formattedDate =
                  "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("Order #$orderId - $userName"),
                  subtitle: Text(
                      "Total: \$${total.toStringAsFixed(2)}\nStatus: $status"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: $userEmail"),
                          Text("Phone: $userPhone"),
                          Text("Order Date: $formattedDate"),
                          const SizedBox(height: 8),
                          const Text(
                            "Items:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...items.map((item) {
                            final name = item["name"] ?? "";
                            final quantity = item["quantity"] ?? 0;
                            final price = (item["price"] is int)
                                ? (item["price"] as int).toDouble()
                                : (item["price"] ?? 0.0) as double;
                            return ListTile(
                              title: Text(name),
                              subtitle: Text("Qty: $quantity × \$${price.toStringAsFixed(2)}"),
                              dense: true,
                            );
                          }).toList(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Update Status:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              DropdownButton<String>(
                                value: status,
                                items: validStatuses
                                    .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    FirebaseFirestore.instance
                                        .collection("orders")
                                        .doc(orderDoc.id)
                                        .update({"status": newValue});
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
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