import 'package:flutter/material.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final AnimationController animationController;
  final PageController pageController;
  final bool isTablet;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.animationController,
    required this.pageController,
    required this.isTablet,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final List<String> _iconNames = ['home', 'order', 'my_cart', 'profile'];
  final List<String> _labels = ['Home', 'Order', 'My Cart', 'Profile'];

  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: ColorPalette.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          currentIndex: widget.selectedIndex,
          onTap: widget.onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: ColorPalette.white,
          unselectedItemColor: ColorPalette.white.withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: widget.isTablet ? 14 : 12,
          unselectedFontSize: widget.isTablet ? 12 : 10,
          elevation: 0,
          items: List.generate(4, (index) {
            final isSelected = widget.selectedIndex == index;
            final iconPath =
                'assets/images/navbar_icons/${_iconNames[index]}_${isSelected ? 'on' : 'off'}.png';

            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorPalette.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          isSelected && widget.animationController.isAnimating
                          ? _scaleAnimation.value
                          : 1.0,
                      child: Image.asset(
                        iconPath,
                        width: widget.isTablet ? 28 : 22,
                        height: widget.isTablet ? 28 : 22,
                        color: isSelected
                            ? ColorPalette.white
                            : ColorPalette.white.withOpacity(0.6),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getIconForIndex(index),
                          color: isSelected
                              ? ColorPalette.white
                              : ColorPalette.white.withOpacity(0.6),
                          size: widget.isTablet ? 28 : 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
              label: _labels[index],
            );
          }),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.receipt_long;
      case 2:
        return Icons.shopping_cart;
      case 3:
        return Icons.person;
      default:
        return Icons.error;
    }
  }
}
