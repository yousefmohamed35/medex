import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/product.dart';

class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  Future<List<ProductCategory>> getCategories() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.storeCategories,
      requireAuth: true,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch categories');
    }
    if (kDebugMode) {
      log('getCategories: success', name: 'StoreService');
    }
    final data = response['data'];
    final list = data is Map && data['categories'] is List
        ? data['categories'] as List
        : (data is List ? data : <dynamic>[]);
    return list.map((e) => _parseCategory(e)).toList();
  }

  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? categoryId,
    String? subcategory,
    String? brand,
    String? sort,
  }) async {
    if (kDebugMode) {
      log(
        'getProducts: page=$page, perPage=$perPage, search=$search, categoryId=$categoryId, subcategory=$subcategory, brand=$brand, sort=$sort',
        name: 'StoreService',
      );
    }
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      if (subcategory != null && subcategory.isNotEmpty)
        'subcategory': subcategory,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };
    final url = Uri.parse(ApiEndpoints.storeProducts)
        .replace(queryParameters: query)
        .toString();
    final response = await ApiClient.instance.get(
      url,
      requireAuth: true,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch products');
    }
    if (kDebugMode) {
      final data = response['data'];
      final n = data is Map && data['products'] is List
          ? (data['products'] as List).length
          : (data is List ? data.length : 0);
      log('getProducts: success (page=$page, count=$n)', name: 'StoreService');
    }
    final data = response['data'];
    final list = data is Map && data['products'] is List
        ? data['products'] as List
        : (data is List ? data : <dynamic>[]);
    return list.map((e) => _parseProduct(e)).toList();
  }

  /// Loads all products by walking every page. The API may ignore a large
  /// [perPage] and cap each page (e.g. 30); this still merges every page until
  /// a short or empty page is returned.
  Future<List<Product>> getAllProducts({
    int perPage = 100,
    int maxPages = 200,
    String? search,
    String? categoryId,
    String? subcategory,
    String? brand,
    String? sort,
  }) async {
    final merged = <Product>[];
    var page = 1;
    int? fullPageSize;

    while (page <= maxPages) {
      final batch = await getProducts(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
        subcategory: subcategory,
        brand: brand,
        sort: sort,
      );
      if (batch.isEmpty) break;

      fullPageSize ??= batch.length;
      merged.addAll(batch);

      if (batch.length < fullPageSize) break;
      page++;
    }

    return merged;
  }

  Future<List<Order>> getOrders({int page = 1, int perPage = 20}) async {
    final url = Uri.parse(ApiEndpoints.storeOrders).replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
    }).toString();
    final response = await ApiClient.instance.get(
      url,
      requireAuth: true,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch orders');
    }
    debugPrint('🛒 Orders Response: $response');
    final data = response['data'];
    debugPrint('🛒 Orders Data: $data');
    final list = data is Map && data['orders'] is List
        ? data['orders'] as List
        : (data is List ? data : <dynamic>[]);
    return list.map((e) => _parseOrder(e)).toList();
  }

  /// Marks a purchase order as received (shipped → delivered). [current] keeps line items if the API omits them.
  Future<Order> markOrderReceived(String orderId, {Order? current}) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.storeOrderMarkReceived(orderId),
      body: <String, dynamic>{},
      requireAuth: true,
    );
    if (response['success'] != true) {
      throw Exception(
          response['message'] ?? 'Failed to mark order as received');
    }
    final raw = response['data'];
    if (raw is! Map) {
      throw Exception('Invalid response');
    }
    final map = Map<String, dynamic>.from(raw);
    final updated = _parseOrder(map);
    return _mergeOrderPreserveLineItems(updated, current);
  }

  /// Marks a rental as received (shipped → delivered). [current] keeps line items if the API omits them.
  Future<Order> markRentalReceived(String rentalId, {Order? current}) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.storeRentalMarkReceived(rentalId),
      body: <String, dynamic>{},
      requireAuth: true,
    );
    if (response['success'] != true) {
      throw Exception(
          response['message'] ?? 'Failed to mark rental as received');
    }
    final raw = response['data'];
    if (raw is! Map) {
      throw Exception('Invalid response');
    }
    final map = Map<String, dynamic>.from(raw);
    final updated = _parseOrder(map);
    return _mergeOrderPreserveLineItems(updated, current);
  }

  Order _mergeOrderPreserveLineItems(Order updated, Order? current) {
    if (current == null) return updated;
    if (updated.items.isNotEmpty || current.items.isEmpty) return updated;
    return Order(
      id: updated.id.isNotEmpty ? updated.id : current.id,
      items: current.items,
      totalAmount:
          updated.totalAmount != 0 ? updated.totalAmount : current.totalAmount,
      status: updated.status,
      statusAr:
          updated.statusAr.isNotEmpty ? updated.statusAr : current.statusAr,
      createdAt: updated.createdAt,
      shippingAddress: updated.shippingAddress.isNotEmpty
          ? updated.shippingAddress
          : current.shippingAddress,
      isRental: current.isRental,
    );
  }

  ProductCategory _parseCategory(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final sub =
        (map['subcategories'] as List?)?.map((e) => '$e').toList() ?? [];
    final subAr =
        (map['subcategories_ar'] as List?)?.map((e) => '$e').toList() ?? sub;
    return ProductCategory(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      nameAr: map['name_ar']?.toString() ?? map['name']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      origin: map['origin']?.toString() ?? '',
      iconName: map['icon_name']?.toString() ?? 'category',
      subcategories: sub,
      subcategoriesAr: subAr,
    );
  }

  Product _parseProduct(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final title = map['title']?.toString();
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? title ?? '',
      nameAr: map['name_ar']?.toString() ??
          map['title_ar']?.toString() ??
          map['name']?.toString() ??
          title ??
          '',
      description: map['description']?.toString() ?? '',
      descriptionAr: map['description_ar']?.toString() ??
          map['description']?.toString() ??
          '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      rentalPrice: (map['rental_price'] as num?)?.toDouble(),
      imageUrl: ApiEndpoints.getImageUrl(
        map['image_url']?.toString() ??
            map['image']?.toString() ??
            map['thumbnail']?.toString() ??
            '',
      ),
      category: map['category']?.toString() ?? '',
      categoryAr:
          map['category_ar']?.toString() ?? map['category']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      origin: map['origin']?.toString() ?? '',
      isAvailable: map['is_available'] != false,
      isRentable: map['is_rentable'] == true,
      discount: (map['discount'] as num?)?.toDouble(),
    );
  }

  Order _parseOrder(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);

    final isRental = map['rental_status'] != null ||
        map['renterId'] != null ||
        map['renter_id'] != null ||
        map['is_rental'] == true ||
        map['type']?.toString().toLowerCase() == 'rental';

    final itemsRaw = map['items'] is List ? map['items'] as List : <dynamic>[];
    var items = itemsRaw.map((e) {
      final itemMap =
          e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      final product = _parseProduct(itemMap['product'] ?? itemMap);
      return CartItem(
        product: product,
        quantity: (itemMap['quantity'] as num?)?.toInt() ?? 1,
        isRental: itemMap['is_rental'] == true || isRental,
      );
    }).toList();

    if (items.isEmpty && map['product'] != null) {
      final product = _parseProduct(map['product']);
      final qty = (map['quantity'] as num?)?.toInt() ?? 1;
      items = [
        CartItem(product: product, quantity: qty, isRental: isRental),
      ];
    }

    final total = (map['total'] as num?)?.toDouble() ??
        (map['total_amount'] as num?)?.toDouble() ??
        0;

    final statusRaw = map['status']?.toString() ??
        map['rental_status']?.toString() ??
        'PENDING';

    final shipping =
        map['shipping_address']?.toString() ?? map['address']?.toString() ?? '';

    final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
        DateTime.now();

    return Order(
      id: map['id']?.toString() ?? map['order_id']?.toString() ?? '',
      items: items,
      totalAmount: total,
      status: statusRaw,
      statusAr: map['status_ar']?.toString() ?? '',
      createdAt: createdAt,
      shippingAddress: shipping,
      isRental: isRental,
    );
  }
}
