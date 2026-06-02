import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/icons/huge_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as app_error_widget;
import '../widgets/empty_widget.dart';
import 'product_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ScrollController _scrollController;
  final List<Map<String, String>> _categories = [
    {'label': AppStrings.filterAll, 'query': ''},
    {'label': 'Electronics', 'query': 'electronics'},
    {'label': 'Jewelery', 'query': 'jewelery'},
    {'label': 'Men', 'query': "men's clothing"},
    {'label': 'Women', 'query': "women's clothing"},
  ];
  String _selectedCategory = AppStrings.filterAll;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductController>().init();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<ProductController>().loadMore();
    }
  }

  void _applyCategory(String label, String query) {
    setState(() {
      _selectedCategory = label;
    });
    context.read<ProductController>().filterByCategory(query);
  }

  Future<void> _refreshProducts(ProductController productController) async {
    await productController.fetchProducts();

    final selectedCategory = _categories.firstWhere(
      (category) => category['label'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    final query = selectedCategory['query'] ?? '';
    if (query.isNotEmpty) {
      productController.filterByCategory(query);
    }
  }

  String get _timeBasedGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning! ';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    }
    return 'Good Night!';
  }

  void _showFilterSheet(ProductController productController) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.filterTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  IconButton(
                    icon: const Icon(HugeIcons.strokeroundedCancel01),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.filterCategories,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((category) {
                        final label = category['label']!;
                        final query = category['query']!;
                        final selected = label == _selectedCategory;
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.16),
                          labelStyle: TextStyle(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          onSelected: (_) {
                            _applyCategory(label, query);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Reset filters',
                    onPressed: () {
                      _applyCategory(AppStrings.filterAll, '');
                      Navigator.pop(context);
                    },
                    icon: const Icon(HugeIcons.strokeroundedRefresh),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeHeader(ProductController productController) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  splashRadius: 24,
                  padding: const EdgeInsets.all(14),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: Tween<double>(begin: 0.8, end: 1)
                            .animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      themeProvider.isDarkMode
                          ? HugeIcons.strokeroundedMoon02
                          : HugeIcons.strokeroundedSun03,
                      key: ValueKey<bool>(themeProvider.isDarkMode),
                      color: themeProvider.isDarkMode
                          ? Theme.of(context).colorScheme.primary
                          : Colors.orange.shade600,
                      size: 22,
                    ),
                  ),
                  onPressed: themeProvider.toggleTheme,
                  tooltip: themeProvider.isDarkMode
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Product Catalog Application',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SearchBarWidget(
                  onChanged: (query) {
                    context.read<ProductController>().search(query);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showFilterSheet(productController),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      HugeIcons.strokeroundedFilter,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductController, FavoriteController>(
      builder: (context, productController, favoriteController, _) {
        Widget body;

        if (productController.isLoading) {
          body = const LoadingWidget();
        } else if (productController.errorMessage != null) {
          body = app_error_widget.ErrorWidget(
            message: productController.errorMessage ?? AppStrings.errorOccurred,
            onRetry: productController.retry,
          );
        } else if (productController.isEmpty &&
            productController.displayedProducts.isEmpty) {
          body = SafeArea(
            child: Column(
              children: [
                _buildHomeHeader(productController),
                Expanded(
                  child: EmptyWidget(
                    title: AppStrings.noProductsFound,
                    message: 'Unable to load products at the moment',
                    icon: HugeIcons.strokeroundedShoppingBag01,
                  ),
                ),
              ],
            ),
          );
        } else if (productController.displayedProducts.isEmpty) {
          body = SafeArea(
            child: Column(
              children: [
                _buildHomeHeader(productController),
                Expanded(
                  child: EmptyWidget(
                    title: AppStrings.noMatchingProducts,
                    message: 'Try a different search term',
                    icon: HugeIcons.strokeroundedSearchRemove,
                  ),
                ),
              ],
            ),
          );
        } else {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          body = SafeArea(
            child: Column(
              children: [
                _buildHomeHeader(productController),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refreshProducts(productController),
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: productController.displayedProducts.length +
                          (productController.isPaginationLoading ? 1 : 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.67,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        if (index ==
                            productController.displayedProducts.length) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode
                                    ? AppTheme.darkAccent
                                    : AppTheme.lightAccent,
                              ),
                            ),
                          );
                        }

                        final product =
                            productController.displayedProducts[index];
                        final isFavorite =
                            favoriteController.isFavorite(product.id);

                        return ProductCard(
                          product: product,
                          isFavorite: isFavorite,
                          onFavoritePressed: () {
                            favoriteController.toggleFavorite(product);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: body,
        );
      },
    );
  }
}
