import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/services/http_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  static const String _cacheBox = 'productCache';
  static const String _cacheKey = 'products';

  final HttpService _httpService;

  ProductRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<List<ProductModel>> getProducts() async {
    try {
      final data = await _httpService.get(ApiConstants.productsEndpoint);
      final products = data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      await _cacheProducts(products);
      return products;
    } catch (e) {
      final cachedProducts = await _getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<ProductModel>> _getCachedProducts() async {
    final box = Hive.box(_cacheBox);
    final raw = box.get(_cacheKey, defaultValue: <String>[]);
    final cached = List<String>.from(raw as List<dynamic>);
    return cached.map((item) => ProductModel.fromJsonString(item)).toList();
  }

  Future<void> _cacheProducts(List<ProductModel> products) async {
    final box = Hive.box(_cacheBox);
    await box.put(
      _cacheKey,
      products.map((product) => product.toJsonString()).toList(),
    );
  }
}
