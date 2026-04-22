class Product {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final double? rentalPrice;
  final String imageUrl;
  final String category;
  final String categoryAr;
  final String brand;
  final String origin;
  final bool isAvailable;
  final bool isRentable;
  final double? discount;

  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.rentalPrice,
    required this.imageUrl,
    required this.category,
    required this.categoryAr,
    required this.brand,
    required this.origin,
    this.isAvailable = true,
    this.isRentable = false,
    this.discount,
  });
}

class ProductCategory {
  final String id;
  final String name;
  final String nameAr;
  final String brand;
  final String origin;
  final String iconName;
  final List<String> subcategories;
  final List<String> subcategoriesAr;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.brand,
    required this.origin,
    required this.iconName,
    required this.subcategories,
    required this.subcategoriesAr,
  });
}

class CartItem {
  final Product product;
  int quantity;
  final bool isRental;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isRental = false,
  });

  double get totalPrice =>
      (isRental ? (product.rentalPrice ?? product.price) : product.price) *
      quantity;
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final String statusAr;
  final DateTime createdAt;
  final String shippingAddress;

  /// True when this row is a rental (uses `/store/rentals/...` APIs).
  final bool isRental;

  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.statusAr,
    required this.createdAt,
    required this.shippingAddress,
    this.isRental = false,
  });
}
