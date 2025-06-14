import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';
import 'package:marketplace_app_v0/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app_v0/core/config/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  // User data variables
  String userName = 'Loading...';
  String userEmail = '';
  String userRole = 'Livestock Farmer';
  String userLocation = 'Tunisia';
  String blockchainId = '0xA92...F41E';
  bool isLoading = true;
  bool isVerifying = false;
  bool isWalletVerified = false;
  String? walletError;
  final TextEditingController _walletController = TextEditingController();

  // Sample stats
  int totalAnimals = 24;
  int healthyAnimals = 21;
  int alerts = 3;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          userEmail = user.email ?? '';
          userName = user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              user.email?.split('@')[0] ??
              'User';
        });

        await _fetchProfileData(user.id);
      } else {
        _redirectToLogin();
      }
    } catch (error) {
      print('Error loading profile: $error');
      _showErrorSnackBar('Failed to load profile data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileData(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select(
              'full_name, role, location, blockchain_id, total_animals, healthy_animals, alerts, is_wallet_verified')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          userName = response['full_name'] ?? userName;
          userRole = response['role'] ?? userRole;
          userLocation = response['location'] ?? userLocation;
          blockchainId = response['blockchain_id'] ?? blockchainId;
          totalAnimals = response['total_animals'] ?? totalAnimals;
          healthyAnimals = response['healthy_animals'] ?? healthyAnimals;
          alerts = response['alerts'] ?? alerts;
          isWalletVerified = response['is_wallet_verified'] ?? false;
          _walletController.text = blockchainId;
        });
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  // Wallet address validation
  bool _validateWalletAddress(String address) {
    final ethRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return ethRegex.hasMatch(address);
  }

  Future<void> _verifyWalletAddress() async {
    final address = _walletController.text.trim();

    if (address.isEmpty) {
      setState(() {
        walletError = 'Wallet address is required';
      });
      return;
    }

    if (!_validateWalletAddress(address)) {
      setState(() {
        walletError = 'Invalid wallet address format';
      });
      return;
    }

    setState(() {
      isVerifying = true;
      walletError = null;
    });

    try {
      // Simulate wallet verification (replace with actual blockchain verification)
      await Future.delayed(const Duration(seconds: 2));

      // Update Supabase profile
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({
          'blockchain_id': address,
          'is_wallet_verified': true,
        }).eq('user_id', user.id);

        setState(() {
          blockchainId = address;
          isWalletVerified = true;
        });
        _showSuccessSnackBar('Wallet address verified and saved');
      }
    } catch (error) {
      setState(() {
        walletError = 'Verification failed: $error';
      });
      _showErrorSnackBar('Failed to verify wallet address');
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await supabase.auth.signOut();

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.onboarding,
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      print('Logout error: $error');
      _showErrorSnackBar('Failed to logout. Please try again.');
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.onboarding,
        (Route<dynamic> route) => false,
      );
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final localizations = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorPalette.primary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isTablet ? 300 : 250,
            floating: false,
            pinned: true,
            backgroundColor: ColorPalette.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorPalette.primary,
                      ColorPalette.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isTablet ? 70 : 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: isTablet ? 65 : 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: const AssetImage(
                              'assets/images/farmer_avatar.png'),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$userRole • $userLocation',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shadowColor: ColorPalette.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            ColorPalette.primary.withOpacity(0.1),
                            ColorPalette.primary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ColorPalette.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isWalletVerified
                                      ? Icons.verified
                                      : Icons.verified_user,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  isWalletVerified
                                      ? 'Blockchain Verified'
                                      : 'Verify Blockchain ID',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _walletController,
                            decoration: InputDecoration(
                              labelText: 'Wallet Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorText: walletError,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _walletController.text));
                                  _showSuccessSnackBar('Address copied');
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                walletError = null;
                                isWalletVerified = false;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed:
                                isVerifying ? null : _verifyWalletAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isVerifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isWalletVerified
                                        ? 'Verified'
                                        : 'Verify Address',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 30),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    'Account Settings',
                    'Manage your profile and preferences',
                    Icons.settings,
                    ColorPalette.primary,
                    () {},
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Notifications',
                    'Configure alerts and notifications',
                    Icons.notifications,
                    Colors.blue,
                    () {},
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Help & Support',
                    'Get help or contact support',
                    Icons.help_outline,
                    Colors.green,
                    () {},
                    isTablet,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    'Logout',
                    'Sign out of your account',
                    Icons.logout,
                    Colors.red,
                    _handleLogout,
                    isTablet,
                    isDestructive: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isTablet, {
    bool isAlert = false,
  }) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: isTablet ? 28 : 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet, {
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? color.withOpacity(0.1)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet ? 26 : 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? color : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
