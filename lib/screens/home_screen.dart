import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'auth/login_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  String searchQuery = "";
  String selectedCategory = "All";
  int _currentIndex = 0;

  // 🟢 Categories
  final List<String> categories = [
    "All",
    "Infants",
    "Diapers",
    "Baby Foods",
    "Clothes",
    "Toys",
    "Best-Selling",
    "New-Arrival",
  ];

  // 🟢 Banner Images (local assets in assets/banners/)
  final List<String> bannerImages = [
    "assets/banners/banner1.jpg",
    "assets/banners/banner2.jpg",
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _addToCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cart");

    final doc = await cartRef.doc(product.id).get();

    if (doc.exists) {
      // 🔹 Increase quantity if already exists
      int currentQty = doc["quantity"] ?? 1;
      await cartRef.doc(product.id).update({"quantity": currentQty + 1});
    } else {
      // 🔹 Add new product to cart
      await cartRef.doc(product.id).set({
        "id": product.id,
        "name": product.name,
        "price": product.price,
        "imageUrl": product.imageUrl,
        "category": product.category,
        "quantity": 1,
      });
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/cart");
        break;
      case 1:
        Navigator.pushNamed(context, "/orders");
        break;
      case 2:
        Navigator.pushNamed(context, "/profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        // backgroundColor: const Color(0xFF397CA9),
        title: Image.asset(
          "assets/BabyShopHub_LOGO.png", // your logo path
          height: 40, // adjust size as needed
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: ListView(
        children: [
          // 🟢 Banner Carousel
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: bannerImages.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(url,
                      width: double.infinity, fit: BoxFit.cover),
                );
              }).toList(),
            ),
          ),

          // 🟢 Category List
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF397CA9)
                          : const Color(0xFF7EC8E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 📦 Product Grid
          FutureBuilder<List<Product>>(
            future: productService.getProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ));
              }

              final products = snapshot.data!;
              final filteredProducts = products.where((p) {
                final matchesSearch = p.name.toLowerCase().contains(searchQuery) ||
                    p.description.toLowerCase().contains(searchQuery);
                final matchesCategory = selectedCategory == "All" ||
                    p.category.toLowerCase() == selectedCategory.toLowerCase();
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No products found",
                          style: TextStyle(fontSize: 16)),
                    ));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
// inside your widget build method where you return Card:
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼 Product Image → Navigate to details
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product.imageUrl,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 50),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            product.category,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "\$${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              // ✅ Add product to CartService
                              CartService().addToCart(
                                CartItem(
                                  productId: product.id,
                                  name: product.name,
                                  price: product.price,
                                  quantity: 1,
                                  imageUrl: product.imageUrl,
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to Cart")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF397CA9),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Add to Cart"),
                          ),
                        )
                      ],
                    ),
                  );

                },
              );
            },
          ),
        ],
      ),

      // 🟢 Modern Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        selectedItemColor: const Color(0xFF397CA9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
