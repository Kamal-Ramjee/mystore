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
      appBar: AppBar(title: const Text('Your Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            leading: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => updateQuantity(it, -1),
            ),
            title: Text(it.name),
            subtitle: Row(
              children: [
                Text("Qty: ${it.quantity}"),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => updateQuantity(it, 1),
                ),
              ],
            ),
            trailing: Text(
              '\$${(it.price * it.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: items.isEmpty
                  ? null
                  : () {
                Navigator.pushNamed(context, '/checkout');
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
