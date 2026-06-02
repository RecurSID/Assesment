import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/icons/huge_icons.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;
  final Color? favoriteColor;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 24,
    this.favoriteColor = AppTheme.errorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        HugeIcons.strokeroundedHeart,
        size: size,
        color: isFavorite
            ? favoriteColor
            : (Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary),
      ),
    );
  }
}
