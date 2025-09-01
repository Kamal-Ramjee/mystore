import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({
    super.key,
    required this.productId,
    required Map<String, dynamic> productData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final Color primaryColor = const Color(0xFF397CA9);
  final Color secondaryColor = const Color(0xFF7EC8E3);

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    final doc = await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data["name"] ?? "";
      priceController.text = (data["price"] ?? "").toString();
      descController.text = data["description"] ?? "";
      imageController.text = data["imageUrl"] ?? "";
      _selectedCategory = data["category"];
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProduct() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .update({
      "name": nameController.text,
      "price": double.tryParse(priceController.text) ?? 0,
      "description": descController.text,
      "imageUrl": imageController.text,
      "category": _selectedCategory,
      "updatedAt": DateTime.now(),
    });

    Navigator.pop(context);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Preview Image
              if (imageController.text.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageController.text,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              _buildTextField(
                  controller: nameController,
                  label: "Product Name",
                  icon: Icons.shopping_bag),
              const SizedBox(height: 12),

              _buildTextField(
                  controller: priceController,
                  label: "Price",
                  icon: Icons.attach_money,
                  type: TextInputType.number),
              const SizedBox(height: 12),

              _buildTextField(
                  controller: descController,
                  label: "Description",
                  icon: Icons.description),
              const SizedBox(height: 12),

              _buildTextField(
                  controller: imageController,
                  label: "Image URL",
                  icon: Icons.image),
              const SizedBox(height: 12),

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
                  prefixIcon:
                  Icon(Icons.category, color: primaryColor),
                  labelText: "Category",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Floating Save Button
      floatingActionButton: SizedBox(
        width: 180,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text(
            "Update Product",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          onPressed: _updateProduct,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
