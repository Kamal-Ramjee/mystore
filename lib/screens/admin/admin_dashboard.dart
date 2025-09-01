import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mystore/screens/auth/login_screen.dart';

import 'add_product_screen.dart';
import 'manage_orders_screen.dart';
import 'edit_product_screen.dart'; // for editing products

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  final List<Widget> _pages = [
    const ProductsPage(),
    const ManageOrdersScreen(),
    const SizedBox(), // placeholder for logout
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _logout(context); // logout directly
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF7EC8E3), // light blue
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/BabyShopHub_LOGO.png", // ✅ put your logo in assets
                height: 45,
              ),
              const SizedBox(width: 10),
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF397CA9), // dark blue
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductScreen()),
          );
        },
        child: const Icon(Icons.add,color: Colors.white,),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF397CA9), // dark blue
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.red),
            label: "Logout",
          ),
        ],
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("products").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            var product = products[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                product['name'],
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("\$${product['price']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF397CA9)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProductScreen(
                            productId: product.id,
                            productData: product.data() as Map<String, dynamic>,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("products")
                          .doc(product.id)
                          .delete();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
