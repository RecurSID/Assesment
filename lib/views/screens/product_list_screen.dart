import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/icons/huge_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as app_error_widget;
import '../widgets/empty_widget.dart';
import 'product_details_screen.dart';

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

  void _showFilterSheet(ProductController productController) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    icon: const Icon(Icons.close_rounded),
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
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.16),
                          labelStyle: TextStyle(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<ProductController, FavoriteController>(
        builder: (context, productController, favoriteController, _) {
          if (productController.isLoading) {
            return const LoadingWidget();
          }

          if (productController.errorMessage != null) {
            return app_error_widget.ErrorWidget(
              message: productController.errorMessage ?? AppStrings.errorOccurred,
              onRetry: productController.retry,
            );
          }

          if (productController.isEmpty && productController.displayedProducts.isEmpty) {
            return EmptyWidget(
              title: AppStrings.noProductsFound,
              message: 'Unable to load products at the moment',
              icon: Icons.shopping_bag_outlined,
              onBack: () => Navigator.maybePop(context),
            );
          }

          if (productController.displayedProducts.isEmpty) {
            return EmptyWidget(
              title: AppStrings.noMatchingProducts,
              message: 'Try a different search term',
              icon: Icons.search_off,
              onBack: () => Navigator.maybePop(context),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
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
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
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
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: productController.fetchProducts,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: productController.displayedProducts.length +
                          (productController.isPaginationLoading ? 1 : 0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.67,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        if (index == productController.displayedProducts.length) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? AppTheme.darkAccent : AppTheme.lightAccent,
                              ),
                            ),
                          );
                        }

                        final product = productController.displayedProducts[index];
                        final isFavorite = favoriteController.isFavorite(product.id);

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
                                builder: (context) => ProductDetailsScreen(product: product),
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
        },
      ),
    );
  }
}
