import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketplace_app_v0/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _showPhoneSignup = false;
  bool _showOtpField = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorPalette.primary.withOpacity(0.1),
              Colors.white,
              ColorPalette.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: ColorPalette.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_xhack.png',
                        width:
                            200, // Adjust size as needed (e.g. 30 or 35 if 40 is still too big)
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        localizations.createAccountTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.joinPixelMarket,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorPalette.textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildRegisterForm(),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: ColorPalette.textGrey.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              localizations.orRegisterWith,
                              style: TextStyle(
                                color: ColorPalette.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: ColorPalette.textGrey.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            assetPath: 'assets/images/phone_icon.png',
                            onPressed: () => _togglePhoneRegister(),
                            label: localizations.phone,
                            isSelected: _showPhoneSignup,
                          ),
                          _buildSocialButton(
                            assetPath: 'assets/images/email_icon.png',
                            onPressed: () => _toggleEmailRegister(),
                            label: localizations.email,
                            isSelected: !_showPhoneSignup,
                          ),
                          _buildSocialButton(
                            assetPath: 'assets/images/google_icon.png',
                            onPressed: _handleGoogleRegister,
                            label: localizations.google,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.alreadyHaveAccount,
                            style: TextStyle(
                              color: ColorPalette.textGrey,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              localizations.signUp,
                              style: TextStyle(
                                color: ColorPalette.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    if (_showPhoneSignup) {
      return _buildPhoneRegisterForm(context);
    } else {
      return _buildEmailRegisterForm(context);
    }
  }

  Widget _buildEmailRegisterForm(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: localizations.fullNameHint,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          hintText: localizations.emailAddressHint,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          hintText: localizations.passwordHint,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          hintText: localizations.confirmPasswordHint,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleEmailRegister(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: ColorPalette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorPalette.textGrey,
                    ),
                    children: [
                      TextSpan(text: localizations.agreeToTerms),
                      TextSpan(
                        text: localizations.termsOfService,
                        style: TextStyle(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: localizations.and),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                _isLoading || !_acceptTerms ? null : _handleEmailRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: ColorPalette.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    localizations.createAccountButton,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneRegisterForm(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: localizations.fullNameHint,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          hintText: localizations.emailAddressHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction:
              _showOtpField ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (_showOtpField) {
              _otpFocusNode.requestFocus();
            } else {
              _handlePhoneRegister();
            }
          },
        ),
        if (_showOtpField) ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            hintText: localizations.otpHint,
            prefixIcon: Icons.security_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleVerifyOtp(),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: ColorPalette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorPalette.textGrey,
                    ),
                    children: [
                      TextSpan(text: localizations.agreeToTerms),
                      TextSpan(
                        text: localizations.termsOfService,
                        style: TextStyle(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: localizations.and),
                      TextSpan(
                        text: localizations.privacyPolicy,
                        style: TextStyle(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || !_acceptTerms
                ? null
                : (_showOtpField ? _handleVerifyOtp : _handlePhoneRegister),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: ColorPalette.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _showOtpField ? 'Verify & Create Account' : 'Send OTP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (_showOtpField) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _handleResendOtp,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: ColorPalette.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword
            ? (isConfirmPassword
                ? !_isConfirmPasswordVisible
                : !_isPasswordVisible)
            : false,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onFieldSubmitted,
        inputFormatters: keyboardType == TextInputType.phone
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ColorPalette.textGrey.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Icon(prefixIcon, color: ColorPalette.textGrey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isConfirmPassword
                        ? (_isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility)
                        : (_isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                    color: ColorPalette.textGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      } else {
                        _isPasswordVisible = !_isPasswordVisible;
                      }
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ColorPalette.textGrey.withOpacity(0.2),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ColorPalette.textGrey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ColorPalette.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String assetPath,
    required VoidCallback onPressed,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? ColorPalette.primary.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ColorPalette.primary
                  : ColorPalette.textGrey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  assetPath,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    IconData fallbackIcon;
                    Color fallbackColor;
                    switch (label) {
                      case 'Phone':
                        fallbackIcon = Icons.phone;
                        fallbackColor = ColorPalette.primary;
                        break;
                      case 'Email':
                        fallbackIcon = Icons.email;
                        fallbackColor = Colors.blue;
                        break;
                      case 'Google':
                        fallbackIcon = Icons.g_mobiledata;
                        fallbackColor = const Color(0xFFDB4437);
                        break;
                      default:
                        fallbackIcon = Icons.person_add;
                        fallbackColor = ColorPalette.textGrey;
                    }
                    return Icon(fallbackIcon, color: fallbackColor, size: 28);
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? ColorPalette.primary : ColorPalette.textGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _handleEmailRegister() async {
    if (!_validateEmailForm()) return;

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': _nameController.text.trim()},
      );

      if (response.user != null) {
        _showSuccessSnackBar(
          'Account created! Please check your email to verify your account.',
        );
        _navigateToLogin();
      }
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneRegister() async {
    if (!_validatePhoneForm()) return;

    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithOtp(
        phone: _phoneController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      setState(() {
        _showOtpField = true;
        _isLoading = false;
      });

      _showSuccessSnackBar('OTP sent to your phone number');
      Future.delayed(const Duration(milliseconds: 500), () {
        _otpFocusNode.requestFocus();
      });
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
      setState(() => _isLoading = false);
    } catch (error) {
      _showErrorSnackBar('Failed to send OTP');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showErrorSnackBar('Please enter the OTP code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await _supabase.auth.verifyOTP(
        phone: _phoneController.text.trim(),
        token: _otpController.text.trim(),
        type: OtpType.sms,
      );

      if (response.user != null) {
        _showSuccessSnackBar('Account created successfully!');
        _navigateToHome();
      }
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('Failed to verify OTP');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.resend(
        phone: _phoneController.text.trim(),
        type: OtpType.sms,
      );
      _showSuccessSnackBar('OTP resent successfully');
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('Failed to resend OTP');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'your-app://signup-callback',
      );
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar('Google registration failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateEmailForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return false;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorSnackBar('Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter a password');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return false;
    }

    return true;
  }

  bool _validatePhoneForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return false;
    }

    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      _showErrorSnackBar(
        'Phone number must include country code (e.g., +216XXXXXXXX)',
      );
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _togglePhoneRegister() {
    setState(() {
      _showPhoneSignup = true;
      _showOtpField = false;
      _clearFields();
    });
  }

  void _toggleEmailRegister() {
    setState(() {
      _showPhoneSignup = false;
      _showOtpField = false;
      _clearFields();
    });
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _otpController.clear();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: ColorPalette.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
