import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class FavoriteController extends ChangeNotifier {
  static const String _favoriteItemsKey = 'favorite_products_key';

  late SharedPreferences _prefs;
  final Map<int, ProductModel> _favoriteProducts = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  List<ProductModel> get favoriteProducts =>
      List.unmodifiable(_favoriteProducts.values);

  int get favoriteCount => _favoriteProducts.length;

  bool get hasFavorites => _favoriteProducts.isNotEmpty;

  /// Initialize SharedPreferences and load favorites
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
    _isInitialized = true;
  }

  /// Load favorites from SharedPreferences
  void _loadFavorites() {
    final storedList = _prefs.getStringList(_favoriteItemsKey) ?? [];
    _favoriteProducts.clear();

    for (var item in storedList) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        final product = ProductModel.fromJson(json);
        _favoriteProducts[product.id] = product;
      } catch (_) {
        // Ignore invalid cached items
      }
    }

    notifyListeners();
  }

  /// Add product to favorites
  Future<void> addFavorite(ProductModel product) async {
    if (!_favoriteProducts.containsKey(product.id)) {
      _favoriteProducts[product.id] = product;
      await _saveFavorites();
    }
  }

  /// Remove product from favorites
  Future<void> removeFavorite(ProductModel product) async {
    if (_favoriteProducts.remove(product.id) != null) {
      await _saveFavorites();
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(ProductModel product) async {
    if (isFavorite(product.id)) {
      await removeFavorite(product);
    } else {
      await addFavorite(product);
    }
  }

  /// Check if product is favorite
  bool isFavorite(int productId) {
    return _favoriteProducts.containsKey(productId);
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final favoritesList = _favoriteProducts.values
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await _prefs.setStringList(_favoriteItemsKey, favoritesList);
    notifyListeners();
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    _favoriteProducts.clear();
    await _prefs.remove(_favoriteItemsKey);
    notifyListeners();
  }
}
