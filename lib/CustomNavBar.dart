import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

class CustomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  final List<String> _iconNames = ['home', 'order', 'my_cart', 'profile'];
  final List<String> _labels = ['Home', 'Orders', 'Cart', 'Profile'];
  final List<IconData> _fallbackIcons = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.shopping_cart_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorPalette.primary.withOpacity(0.9),
                        ColorPalette.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.primary.withOpacity(0.3),
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: widget.selectedIndex,
                    onTap: widget.onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: ColorPalette.white,
                    unselectedItemColor: Colors.white.withOpacity(0.6),
                    selectedFontSize: isTablet ? 14 : 12,
                    unselectedFontSize: isTablet ? 12 : 10,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                    items: List.generate(4, (index) {
                      final isSelected = widget.selectedIndex == index;
                      final iconPath =
                          'assets/images/navbar_icons/${_iconNames[index]}_${isSelected ? 'on' : 'off'}.png';

                      return BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.all(isSelected ? 8 : 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect for selected item
                                if (isSelected)
                                  Container(
                                    width: isTablet ? 32 : 28,
                                    height: isTablet ? 32 : 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),

                                // Icon
                                Image.asset(
                                  iconPath,
                                  width: isTablet ? 26 : 22,
                                  height: isTablet ? 26 : 22,
                                  color: isSelected
                                      ? ColorPalette.white
                                      : Colors.white.withOpacity(0.7),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    _fallbackIcons[index],
                                    size: isTablet ? 26 : 22,
                                    color: isSelected
                                        ? ColorPalette.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),

                                // Selection indicator
                                if (isSelected)
                                  Positioned(
                                    top: -2,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        label: _labels[index],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
