import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../controllers/favorite_controller.dart';
import '../../core/icons/huge_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/favorite_button.dart';
import '../widgets/home_back_button.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    void goBack() {
      Navigator.of(context).pop();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: HomeBackButton(onPressed: goBack),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Consumer<FavoriteController>(
                  builder: (context, favoriteController, _) {
                    final isFavorite =
                        favoriteController.isFavorite(product.id);

                    return CircleAvatar(
                      backgroundColor: Theme.of(context).cardColor,
                      child: FavoriteButton(
                        isFavorite: isFavorite,
                        onPressed: () {
                          favoriteController.toggleFavorite(product);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.image,
                    imageBuilder: (context, imageProvider) => Padding(
                      padding: const EdgeInsets.fromLTRB(30, 38, 30, 48),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: isDarkMode
                          ? AppTheme.darkCardColor
                          : Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: isDarkMode
                          ? AppTheme.darkCardColor
                          : Colors.grey[200],
                      child: const Icon(HugeIcons.strokeroundedImageNotFound01),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.18),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.28 : 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ProductStat(
                            label: 'Price',
                            value: '\$${product.price.toStringAsFixed(2)}',
                            valueStyle: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        Expanded(
                          child: _ProductStat(
                            label: 'Rating',
                            value: product.rating.rate.toStringAsFixed(1),
                            icon: HugeIcons.strokeroundedStar,
                            iconColor: AppTheme.ratingColor,
                          ),
                        ),
                        Expanded(
                          child: _ProductStat(
                            label: 'Reviews',
                            value: product.rating.count.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final TextStyle? valueStyle;

  const _ProductStat({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final valueTextStyle = valueStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueTextStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
