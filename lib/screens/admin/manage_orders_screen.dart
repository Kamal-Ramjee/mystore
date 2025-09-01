import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final Color primaryColor = const Color(0xFF397CA9);
  final Color accentColor = const Color(0xFF7EC8E3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
            return const Center(
              child: Text(
                "No orders yet.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              final orderId = orderData["orderId"] ?? orderDoc.id;
              final total = (orderData["total"] is int)
                  ? (orderData["total"] as int).toDouble()
                  : (orderData["total"] ?? 0.0) as double;

              String status = orderData["status"] ?? "Pending";
              final List<String> validStatuses = ["Pending", "Shipped", "Delivered"];
              if (!validStatuses.contains(status)) status = "Pending";

              final userName = orderData["userName"] ?? "Unknown";
              final userEmail = orderData["userEmail"] ?? "";
              final userPhone = orderData["userPhone"] ?? "";

              final items = orderData["items"] as List<dynamic>? ?? [];

              DateTime dateTime = DateTime.now();
              final createdAt = orderData["createdAt"];
              if (createdAt is Timestamp) {
                dateTime = createdAt.toDate();
              }
              final formattedDate =
                  "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  collapsedBackgroundColor: accentColor.withOpacity(0.15),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

                  title: Text(
                    "Order #$orderId",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              status,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: status == "Pending"
                                ? Colors.orange
                                : status == "Shipped"
                                ? Colors.blue
                                : Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Total: \$${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  children: [
                    Divider(color: Colors.grey[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Customer Info:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(formattedDate, style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Email: $userEmail"),
                    Text("Phone: $userPhone"),
                    const SizedBox(height: 12),

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
                        dense: true,
                        leading: const Icon(Icons.shopping_bag, color: Colors.grey),
                        title: Text(name),
                        subtitle: Text("Qty: $quantity × \$${price.toStringAsFixed(2)}"),
                      );
                    }).toList(),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Update Status:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: status,
                              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                              items: validStatuses
                                  .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
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
                          ),
                        ),
                      ],
                    ),
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
