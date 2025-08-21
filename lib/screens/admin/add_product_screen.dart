import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatelessWidget {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final imageController = TextEditingController();
  final categoryController = TextEditingController();

  AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Product Name")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
            TextField(controller: imageController, decoration: InputDecoration(labelText: "Image URL")),
            TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category")),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Add Product"),
              onPressed: () async {
                await FirebaseFirestore.instance.collection("products").add({
                  "name": nameController.text,
                  "price": double.parse(priceController.text),
                  "description": descController.text,
                  "imageUrl": imageController.text,
                  "category": categoryController.text,
                  "createdAt": DateTime.now(),
                });
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
