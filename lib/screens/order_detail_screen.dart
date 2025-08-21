import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  OrderDetailScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("orders").doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error loading order"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final order = snapshot.data!.data() as Map<String, dynamic>;
          final items = order["items"] as List<dynamic>;
          final total = order["total"];
          final status = order["status"];
          final createdAt = DateTime.parse(order["createdAt"]);

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order ID: $orderId", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("Status: $status", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("Date: ${createdAt.toLocal()}"),
                Divider(),
                Text("Items:", style: TextStyle(fontSize: 18)),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item["name"]),
                        subtitle: Text("Qty: ${item["quantity"]}"),
                        trailing: Text("\$${item["price"] * item["quantity"]}"),
                      );
                    },
                  ),
                ),
                Divider(),
                Text("Total: \$${total.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
