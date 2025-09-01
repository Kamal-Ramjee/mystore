import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();

  final List<String> categories = [
    "Infants",
    "Diapers",
    "Baby Foods",
    "Clothes",
    "Toys",
    "Best-Selling",
    "New-Arrival",
  ];

  String? _selectedCategory;

  final Color primaryColor = const Color(0xFF397CA9);
  final Color secondaryColor = const Color(0xFF7EC8E3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [secondaryColor, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Add Products",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(nameController, "Product Name", Icons.label),
                const SizedBox(height: 15),
                _buildTextField(priceController, "Price", Icons.attach_money,
                    inputType: TextInputType.number),
                const SizedBox(height: 15),
                _buildTextField(descController, "Description", Icons.description,
                    maxLines: 3),
                const SizedBox(height: 15),
                _buildTextField(imageController, "Image URL", Icons.image),
                const SizedBox(height: 15),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Modern Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 3,
                    ),
                    child: const Text("➕ Add Product"),
                    onPressed: () async {
                      if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please select a category")),
                        );
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection("products")
                          .add({
                        "name": nameController.text,
                        "price": double.tryParse(priceController.text) ?? 0,
                        "description": descController.text,
                        "imageUrl": imageController.text,
                        "category": _selectedCategory,
                        "createdAt": DateTime.now(),
                      });

                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
