import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
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

  void _enterSelectionMode(int productId) {
    setState(() {
      _selectionMode = true;
      _selectedFavorites.add(productId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedFavorites.clear();
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

  void _confirmDeleteSelected(BuildContext context,
      FavoriteController favoriteController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text(
          'Delete ${_selectedFavorites.length} selected item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeSelected(favoriteController);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_selectedFavorites.length} item(s) removed',
                  ),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              },
            ),
            title: Text(
              _selectionMode
                  ? '$selectedCount selected'
                  : AppStrings.favoritesTitle,
            ),
            elevation: 0,
            actions: [
              if (favoriteController.hasFavorites) ...[
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.close, size: 26),
                    tooltip: 'Cancel selection',
                    onPressed: _exitSelectionMode,
                  ),
                if (_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 26),
                    tooltip: 'Delete selected',
                    onPressed: selectedCount > 0
                        ? () => _confirmDeleteSelected(
                              context,
                              favoriteController,
                            )
                        : null,
                  ),
                if (!_selectionMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 26),
                    tooltip: 'Clear all favorites',
                    onPressed: () =>
                        _confirmClearAll(context, favoriteController),
                  ),
              ],
            ],
          ),
          body: favorites.isEmpty
              ? EmptyWidget(
                  title: AppStrings.noFavoritesFound,
                  message: 'Add products to favorites to see them here',
                  icon: Icons.favorite_outline,
                  onBack: () => Navigator.maybePop(context),
                )
              : Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: !_selectionMode
                          ? Padding(
                              key: const ValueKey('hint'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Tap and hold a favorite to select items for removal.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final product = favorites[index];
                            final isSelected =
                                _selectedFavorites.contains(product.id);

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
                                        builder: (context) =>
                                            ProductDetailsScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    if (!_selectionMode) {
                                      _enterSelectionMode(product.id);
                                      return;
                                    }
                                    _toggleSelected(product.id);
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
                                        color: isSelected
                                            ? AppTheme.lightAccent
                                            : Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
