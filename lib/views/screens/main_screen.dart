import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/icons/huge_icons.dart';
import '../../core/theme/app_theme.dart';
import 'favorites_screen.dart';
import 'product_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    ProductListScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.lightAccent,
        unselectedItemColor: Theme.of(context).iconTheme.color,
        iconSize: 28,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeroundedHome01),
            label: AppStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeroundedHeart),
            label: AppStrings.favoritesTab,
          ),
        ],
      ),
    );
  }
}
