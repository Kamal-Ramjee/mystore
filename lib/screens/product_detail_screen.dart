import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final cart = CartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
      ),
      body: FutureBuilder<Product?>(
        future: productService.getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load product"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.imageUrl.isNotEmpty)
                  Center(child: Image.network(product.imageUrl, height: 200)),
                const SizedBox(height: 16),
                Text(product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, color: Colors.green)),
                const SizedBox(height: 16),
                Text(product.description),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Add to in-memory cart
                    final item = CartItem(
                      productId: product.id,
                      name: product.name,
                      price: product.price,
                    );
                    cart.addToCart(item);

                    // Feedback + quick jump to Cart
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('“${product.name}” added to cart.'),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
