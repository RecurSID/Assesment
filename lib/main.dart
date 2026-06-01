import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'controllers/product_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/theme_provider.dart';
import 'repositories/product_repository.dart';
import 'views/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Initialize favorite controller
  final favoriteController = FavoriteController();
  await favoriteController.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
        ),
        ChangeNotifierProvider<ProductController>(
          create: (_) => ProductController(
            repository: ProductRepository(),
          ),
        ),
        ChangeNotifierProvider<FavoriteController>(
          create: (_) => favoriteController,
        ),
      ],
      child: const ProductCatalogApp(),
    ),
  );
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppStrings.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const MainScreen(),
          navigatorObservers: [
            NavigatorObserver(),
          ],
        );
      },
    );
  }
}
