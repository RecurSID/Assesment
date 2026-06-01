class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '/products';
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const int pageSize = 10;
}

class AppStrings {
  // General
  static const String appTitle = 'Product Catalog';
  
  // Screens
  static const String productListTitle = 'Products';
  static const String favoritesTitle = 'Favorites';
  static const String productDetailsTitle = 'Product Details';
  static const String homeTab = 'Home';
  static const String favoritesTab = 'Favorites';
  
  // Actions
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String retry = 'Retry';
  static const String loadMore = 'Load More';
  
  // Messages
  static const String noProductsFound = 'No products found';
  static const String noFavoritesFound = 'No favorites yet';
  static const String searchPlaceholder = 'Search products...';
  static const String errorOccurred = 'Something went wrong';
  static const String noMatchingProducts = 'No matching products found';
  
  // Theme
  static const String lightTheme = 'Light';
  static const String darkTheme = 'Dark';
}

class PaginationConstants {
  static const int initialLoadCount = 10;
  static const int loadMoreCount = 10;
}
