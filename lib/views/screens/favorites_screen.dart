import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/favorite_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_widget.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Set<int> _selectedFavorites = {};
  bool _selectionMode = false;

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedFavorites.clear();
      }
    });
  }

  void _toggleSelected(int productId) {
    setState(() {
      if (_selectedFavorites.contains(productId)) {
        _selectedFavorites.remove(productId);
      } else {
        _selectedFavorites.add(productId);
      }
    });
  }

  void _selectAll(List<int> productIds) {
    setState(() {
      _selectedFavorites.clear();
      _selectedFavorites.addAll(productIds);
      _selectionMode = true;
    });
  }

  Future<void> _removeSelected(FavoriteController favoriteController) async {
    final productsToRemove = favoriteController.favoriteProducts
        .where((product) => _selectedFavorites.contains(product.id))
        .toList();

    for (final product in productsToRemove) {
      await favoriteController.removeFavorite(product);
    }

    setState(() {
      _selectedFavorites.clear();
      _selectionMode = false;
    });
  }

  void _confirmClearAll(BuildContext context,
      FavoriteController favoriteController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text(
          'Are you sure you want to remove all favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              favoriteController.clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteController>(
      builder: (context, favoriteController, _) {
        final favorites = favoriteController.favoriteProducts;
        final selectedCount = _selectedFavorites.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.favoritesTitle),
            elevation: 0,
            actions: [
              if (favoriteController.hasFavorites) ...[
                IconButton(
                  icon: Icon(
                    _selectionMode ? Icons.close : Icons.checklist_rtl,
                    size: 28,
                  ),
                  tooltip: _selectionMode ? 'Exit selection' : 'Select items',
                  onPressed: _toggleSelectionMode,
                ),
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.select_all, size: 28),
                    tooltip: 'Select all',
                    onPressed: () => _selectAll(
                      favorites.map((product) => product.id).toList(),
                    ),
                  ),
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 28),
                    tooltip: 'Remove selected',
                    onPressed: selectedCount > 0
                        ? () => _removeSelected(favoriteController)
                        : null,
                  ),
                if (!_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 28),
                    tooltip: 'Clear all favorites',
                    onPressed: () => _confirmClearAll(context, favoriteController),
                  ),
              ],
            ],
          ),
          body: favorites.isEmpty
              ? EmptyWidget(
                  title: AppStrings.noFavoritesFound,
                  message: 'Add products to favorites to see them here',
                  icon: Icons.favorite_outline,
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      final isSelected = _selectedFavorites.contains(product.id);

                      return Stack(
                        children: [
                          ProductCard(
                            product: product,
                            isFavorite: true,
                            onFavoritePressed: () {
                              favoriteController.toggleFavorite(product);
                              setState(() {
                                _selectedFavorites.remove(product.id);
                              });
                            },
                            onTap: () {
                              if (_selectionMode) {
                                _toggleSelected(product.id);
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_selectionMode)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withAlpha(230),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.lightAccent
                                        : Theme.of(context).dividerColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isSelected ? Icons.check_circle : Icons.circle,
                                  color: isSelected ? AppTheme.lightAccent : Colors.grey,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
