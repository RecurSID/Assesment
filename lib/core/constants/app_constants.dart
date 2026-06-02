class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int pageSize = 10;
}

class AppStrings {
  static const String appTitle = 'Product Catalog Application';

  static const String favoritesTitle = 'Favorites';
  static const String homeTab = 'Home';
  static const String favoritesTab = 'Favorites';
  static const String filterTitle = 'Filters';
  static const String filterAll = 'All';
  static const String filterCategories = 'Categories';

  static const String noProductsFound = 'No products found';
  static const String noFavoritesFound = 'No favorites yet';
  static const String searchPlaceholder = 'Search products...';
  static const String errorOccurred = 'Something went wrong';
  static const String noMatchingProducts = 'No matching products found';
}

class PaginationConstants {
  static const int initialLoadCount = 10;
  static const int loadMoreCount = 10;
}
