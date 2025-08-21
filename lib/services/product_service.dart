import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _products =
  FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getProductsByCategory(String category) async {
    final snapshot =
    await _products.where('category', isEqualTo: category).get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (doc.exists) {
      return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    final snapshot = await _products.get();
    final categories =
    snapshot.docs.map((doc) => doc['category'] as String).toSet().toList();
    return categories;
  }
}
