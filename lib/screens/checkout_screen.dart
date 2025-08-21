import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CheckoutScreen extends StatelessWidget {
  final cart = CartService();
  final orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Order Summary", style: TextStyle(fontSize: 20)),
            Expanded(
              child: ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cart.cartItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("Qty: ${item.quantity}"),
                    trailing: Text("\$${item.price * item.quantity}"),
                  );
                },
              ),
            ),
            Text("Total: \$${cart.total.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await orderService.placeOrder(cart.cartItems, cart.total);
                cart.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Order placed successfully!")));
                Navigator.pop(context);
              },
              child: Text("Place Order"),
            )
          ],
        ),
      ),
    );
  }
}
