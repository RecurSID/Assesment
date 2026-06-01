import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../core/constants/app_constants.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _repository;

  ProductController({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  // State variables
  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayedProducts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;
  int _currentDisplayCount = PaginationConstants.initialLoadCount;

  // Getters
  List<ProductModel> get allProducts => List.unmodifiable(_allProducts);
  List<ProductModel> get displayedProducts => _displayedProducts;
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreProducts =>
      _currentDisplayCount < _allProducts.length &&
      _searchQuery.isEmpty;
  bool get isEmpty => _displayedProducts.isEmpty && !_isLoading;

  /// Initialize and fetch products
  Future<void> init() async {
    if (_allProducts.isNotEmpty) return; // Prevent refetch
    await fetchProducts();
  }

  /// Fetch all products from API
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _repository.getProducts();
      _currentDisplayCount = PaginationConstants.initialLoadCount;
      _displayedProducts =
          _allProducts.take(_currentDisplayCount).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _displayedProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    if (_isPaginationLoading ||
        !hasMoreProducts ||
        _searchQuery.isNotEmpty) {
      return;
    }

    _isPaginationLoading = true;
    notifyListeners();

    // Simulate slight delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    _currentDisplayCount +=
        PaginationConstants.loadMoreCount;

    if (_currentDisplayCount > _allProducts.length) {
      _currentDisplayCount = _allProducts.length;
    }

    _displayedProducts =
        _allProducts.take(_currentDisplayCount).toList();

    _isPaginationLoading = false;
    notifyListeners();
  }

  /// Search products
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _displayedProducts =
          _allProducts.take(_currentDisplayCount).toList();
    } else {
      _displayedProducts = _allProducts
          .where((product) =>
              product.title.toLowerCase().contains(_searchQuery) ||
              product.description
                  .toLowerCase()
                  .contains(_searchQuery) ||
              product.category
                  .toLowerCase()
                  .contains(_searchQuery))
          .toList();
    }

    notifyListeners();
  }

  /// Filter by exact category match (case-insensitive)
  void filterByCategory(String category) {
    final cat = category.toLowerCase().trim();
    _searchQuery = '';

    if (cat.isEmpty) {
      _displayedProducts = _allProducts.take(_currentDisplayCount).toList();
    } else {
      _displayedProducts = _allProducts
          .where((product) => product.category.toLowerCase() == cat)
          .toList();
    }

    notifyListeners();
  }

  /// Retry fetching products
  Future<void> retry() async {
    await fetchProducts();
  }
}
