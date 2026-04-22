import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  static final CartService instance = CartService._();
  CartService._() {
    fetchCart();
  }

  final List<CartItem> _items = [];
  final Map<String, String> _serverItemIds = {};
  bool _isSyncing = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isSyncing => _isSyncing;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> fetchCart() async {
    try {
      _isSyncing = true;
      notifyListeners();
      final response = await ApiClient.instance.get(
        ApiEndpoints.storeCart,
        requireAuth: true,
      );
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final rawItems = data is Map && data['items'] is List
            ? data['items'] as List
            : <dynamic>[];
        _items.clear();
        _serverItemIds.clear();
        for (final raw in rawItems) {
          final map = raw is Map<String, dynamic>
              ? raw
              : Map<String, dynamic>.from(raw as Map);
          final product = Product(
            id: map['product_id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            nameAr: map['name_ar']?.toString() ?? map['name']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            descriptionAr: map['description_ar']?.toString() ??
                map['description']?.toString() ??
                '',
            price: (map['price'] as num?)?.toDouble() ?? 0,
            rentalPrice: (map['rental_price'] as num?)?.toDouble(),
            imageUrl:
                ApiEndpoints.getImageUrl(map['image_url']?.toString() ?? ''),
            category: map['category']?.toString() ?? '',
            categoryAr: map['category_ar']?.toString() ??
                map['category']?.toString() ??
                '',
            brand: map['brand']?.toString() ?? '',
            origin: map['origin']?.toString() ?? '',
            isAvailable: true,
            isRentable: map['is_rentable'] == true,
            discount: (map['discount'] as num?)?.toDouble(),
          );
          final isRental = map['is_rental'] == true;
          final item = CartItem(
            product: product,
            quantity: (map['quantity'] as num?)?.toInt() ?? 1,
            isRental: isRental,
          );
          _items.add(item);
          _serverItemIds['${product.id}_$isRental'] =
              map['id']?.toString() ?? '';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CartService.fetchCart: $e');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void addToCart(Product product, {bool isRental = false}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.isRental == isRental,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, isRental: isRental));
    }
    notifyListeners();
    _syncAdd(productId: product.id, quantity: 1, isRental: isRental);
  }

  void removeFromCart(String productId) {
    final item = _items.where((e) => e.product.id == productId).toList();
    if (item.isNotEmpty) {
      _syncDelete(productId, item.first.isRental);
    }
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _syncDelete(_items[index].product.id, _items[index].isRental);
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
        _syncUpdate(
          _items[index].product.id,
          _items[index].isRental,
          quantity,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _syncClear();
  }

  Future<void> _syncAdd({
    required String productId,
    required int quantity,
    required bool isRental,
  }) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.storeCartItems,
        body: {
          'product_id': productId,
          'quantity': quantity,
          'is_rental': isRental,
        },
        requireAuth: true,
      );
      await fetchCart();
    } catch (e) {
      if (kDebugMode) print('❌ CartService._syncAdd: $e');
    }
  }

  Future<void> _syncUpdate(
      String productId, bool isRental, int quantity) async {
    try {
      final itemId = _serverItemIds['${productId}_$isRental'];
      if (itemId == null || itemId.isEmpty) {
        await fetchCart();
        return;
      }
      await ApiClient.instance.patch(
        ApiEndpoints.storeCartItem(itemId),
        body: {'quantity': quantity},
        requireAuth: true,
      );
      await fetchCart();
    } catch (e) {
      if (kDebugMode) print('❌ CartService._syncUpdate: $e');
    }
  }

  Future<void> _syncDelete(String productId, bool isRental) async {
    try {
      final itemId = _serverItemIds['${productId}_$isRental'];
      if (itemId == null || itemId.isEmpty) return;
      await ApiClient.instance.delete(
        ApiEndpoints.storeCartItem(itemId),
        requireAuth: true,
      );
      await fetchCart();
    } catch (e) {
      if (kDebugMode) print('❌ CartService._syncDelete: $e');
    }
  }

  Future<void> _syncClear() async {
    try {
      await ApiClient.instance.delete(
        ApiEndpoints.storeCartClear,
        requireAuth: true,
      );
    } catch (e) {
      if (kDebugMode) print('❌ CartService._syncClear: $e');
    }
  }
}
