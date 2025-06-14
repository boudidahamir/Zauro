import 'package:flutter/material.dart';
import 'package:marketplace_app_v0/HomeScreen.dart';
import 'package:marketplace_app_v0/OnboardingScreen.dart';
import 'package:marketplace_app_v0/features/auth/LoginScreen.dart';
import 'package:marketplace_app_v0/features/auth/RegisterScreen.dart';
import 'package:marketplace_app_v0/features/cart/CartScreen.dart';
import 'package:marketplace_app_v0/features/orders/marketplace.dart';
import 'package:marketplace_app_v0/features/profile/ProfileScreen.dart';
import 'package:marketplace_app_v0/features/profile/user-wallet.dart';

class AppRoutes {
  static const String onboarding = '/Onboarding';
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String order = '/order';
  static const String marketplace = '/marketplace';
  static const String profile = '/profile';
  static const String wallet = '/wallet'; // ✅ New route

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      onboarding: (context) => const OnboardingScreen(),
      register: (context) => const RegisterScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => HomeScreen(),
      order: (context) => AnimalNFTMarketplace(),
      marketplace: (context) => const CartScreen(),
      profile: (context) => const ProfileScreen(),
      wallet: (context) => const UserWalletScreen(), // ✅ Add this
    };
  }
}
