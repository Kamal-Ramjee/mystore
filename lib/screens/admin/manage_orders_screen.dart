import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

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
              var order = orders[index];
              var orderData = order.data() as Map<String, dynamic>;

              final orderId = order.id;
              final total = orderData['totalAmount'] ?? 0;
              final status = orderData['orderStatus'] ?? "Pending";
              final items = orderData['items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("Order #$orderId"),
                  subtitle: Text("Total: \$${total.toStringAsFixed(2)}"),
                  children: [
                    // Show items in the order
                    ...items.map((item) {
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text(
                          "Qty: ${item['quantity']} × \$${item['price']}",
                        ),
                      );
                    }).toList(),
                    // Status Dropdown
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: status,
                            items: ["Pending", "Shipped", "Delivered"]
                                .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                FirebaseFirestore.instance
                                    .collection("orders")
                                    .doc(orderId)
                                    .update({"orderStatus": value});
                              }
                            },
                          ),
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
