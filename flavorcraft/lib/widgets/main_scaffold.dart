import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    final routes = [
      AppRoutes.home,
      AppRoutes.recipes,
      AppRoutes.shoppingList,
      AppRoutes.profile,
    ];
    if (index != widget.currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;
    final app = AppController.instance;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _buildNavItem(
                0,
                Icons.kitchen_rounded,
                Icons.kitchen_outlined,
                app.text('nav.home'),
              ),
              _buildNavItem(
                1,
                Icons.restaurant_menu_rounded,
                Icons.restaurant_menu_outlined,
                app.text('nav.recipes'),
              ),
              _buildNavItem(
                2,
                Icons.shopping_cart_rounded,
                Icons.shopping_cart_outlined,
                app.text('nav.shopping'),
              ),
              _buildNavItem(
                3,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                app.text('nav.profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = widget.currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 22,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
