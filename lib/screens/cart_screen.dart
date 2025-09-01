import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cart = CartService();

  void updateQuantity(CartItem item, int change) {
    setState(() {
      final newQty = item.quantity + change;
      if (newQty > 0) {
        item.quantity = newQty;
      } else {
        // remove item if qty goes to 0
        cart.removeFromCart(item.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = cart.cartItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF397CA9),
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // ❌ Remove button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.redAccent),
                    onPressed: () => updateQuantity(it, -1),
                  ),

                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Qty: ${it.quantity}",
                                style:
                                const TextStyle(color: Colors.black54)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF397CA9)),
                              onPressed: () => updateQuantity(it, 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '\$${(it.price * it.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF397CA9)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF397CA9),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF397CA9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: items.isEmpty
                  ? null
                  : () {
                Navigator.pushNamed(context, '/checkout');
              },
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
