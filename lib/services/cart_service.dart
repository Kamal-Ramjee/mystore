import '../models/cart_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((e) => e.productId == item.productId);
    if (index >= 0) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(item);
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((e) => e.productId == productId);
  }

  void clearCart() {
    _cartItems.clear();
  }

  double get total =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
