import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketplace_app_v0/core/config/socialIconType.dart';
import 'package:marketplace_app_v0/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _showPhoneLogin = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
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
                        // Logo/Icon
                        Image.asset(
                          'assets/images/logo_xhack.png',
                          width:
                              200, // Adjust size as needed (e.g. 30 or 35 if 40 is still too big)
                          height: 200,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 0),

                        // Welcome Text
                        Text(
                          localizations.welcomeBack,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.signInContinue,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorPalette.textGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Login Form
                        _buildLoginForm(),

                        const SizedBox(height: 30),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: ColorPalette.textGrey.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                localizations.orContinueWith,
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

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              assetPath: 'assets/images/phone_icon.png',
                              onPressed: () => _togglePhoneLogin(),
                              label: localizations.phone,
                              type: SocialButtonType.phone,
                              isSelected: _showPhoneLogin,
                            ),
                            _buildSocialButton(
                              assetPath: 'assets/images/email_icon.png',
                              onPressed: () => _toggleEmailLogin(),
                              label: localizations.email,
                              type: SocialButtonType.email,
                              isSelected: !_showPhoneLogin,
                            ),
                            _buildSocialButton(
                              assetPath: 'assets/images/google_icon.png',
                              onPressed: _handleGoogleSignIn,
                              label: localizations.google,
                              type: SocialButtonType.google,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.noAccount,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 29, 12, 12),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _navigateToRegister();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                localizations
                                    .signIn, // Changed from signIn to signUp
                                style: const TextStyle(
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
      ),
    );
  }

  Widget _buildLoginForm() {
    if (_showPhoneLogin) {
      return _buildPhoneLoginForm();
    } else {
      return _buildEmailLoginForm(context);
    }
  }

  Widget _buildEmailLoginForm(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          hintText: localizations.enterEmail,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          hintText: localizations.enterPassword,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleEmailLogin(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: ColorPalette.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  localizations.rememberMe,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorPalette.textGrey,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                localizations.forgotPassword,
                style: const TextStyle(
                  color: ColorPalette.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailLogin,
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
                    localizations.signInEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLoginForm() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          hintText: localizations.phoneNumberHint, // Localized hint
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction:
              _showOtpField ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (_showOtpField) {
              _otpFocusNode.requestFocus();
            } else {
              _handlePhoneSignIn();
            }
          },
        ),
        if (_showOtpField) ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            hintText: localizations.otpHint, // Localized hint
            prefixIcon: Icons.security_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleVerifyOtp(),
          ),
        ],
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_showOtpField ? _handleVerifyOtp : _handlePhoneSignIn),
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
                    _showOtpField
                        ? localizations.otpHint
                        : localizations.otpHint, // Localized text
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
            child: Text(
              localizations.resendOtp, // Localized text
              style: const TextStyle(
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
        obscureText: isPassword && !_isPasswordVisible,
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
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: ColorPalette.textGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
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
    required SocialButtonType type,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              child: Center(
                child: Image.asset(
                  assetPath,
                  width: 28,
                  height: 28,
                  errorBuilder: (context, error, stackTrace) {
                    print('Failed to load asset: $assetPath, error: $error');
                    IconData fallbackIcon;
                    Color fallbackColor;
                    switch (type) {
                      case SocialButtonType.phone:
                        fallbackIcon = Icons.phone;
                        fallbackColor = ColorPalette.primary;
                        break;
                      case SocialButtonType.email:
                        fallbackIcon = Icons.email;
                        fallbackColor = Colors.blue;
                        break;
                      case SocialButtonType.google:
                        fallbackIcon = Icons.g_mobiledata;
                        fallbackColor = const Color(0xFFDB4437);
                        break;
                    }
                    return Icon(fallbackIcon, color: fallbackColor, size: 28);
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr, // Ensure consistent text alignment
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? ColorPalette.primary : ColorPalette.textGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Authentication Methods
  Future<void> _handleEmailLogin() async {
    final localizations = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar(localizations.errorBothFields);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (response.user != null) {
        _showSuccessSnackBar(localizations.successLogin);
        _navigateToHome();
      }
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(localizations.errorUnexpected);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneSignIn() async {
    final localizations = AppLocalizations.of(context)!;
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar(localizations.errorPhoneNumber);
      return;
    }
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      _showErrorSnackBar(localizations.errorPhoneFormat);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      setState(() {
        _showOtpField = true;
        _isLoading = false;
      });
      _showSuccessSnackBar(localizations.successOtpSent);
      Future.delayed(const Duration(milliseconds: 500), () {
        _otpFocusNode.requestFocus();
      });
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
      setState(() => _isLoading = false);
    } catch (error) {
      _showErrorSnackBar(localizations.errorSendOtp);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final localizations = AppLocalizations.of(context)!;
    if (_otpController.text.isEmpty) {
      _showErrorSnackBar(localizations.errorOtpCode);
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
        _showSuccessSnackBar(localizations.successPhoneVerified);
        _navigateToHome();
      }
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(localizations.errorVerifyOtp);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOtp() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.resend(
        phone: _phoneController.text.trim(),
        type: OtpType.sms,
      );
      _showSuccessSnackBar(localizations.successOtpResent);
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(localizations.errorResendOtp);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'your-app://login-callback',
      );
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(localizations.errorGoogleSignIn);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final localizations = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar(localizations.errorEmailAddress);
      return;
    }
    try {
      await _supabase.auth.resetPasswordForEmail(_emailController.text.trim());
      _showSuccessSnackBar(localizations.successResetEmail);
    } on AuthException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(localizations.errorResetEmail);
    }
  }

  void _togglePhoneLogin() {
    setState(() {
      _showPhoneLogin = true;
      _showOtpField = false;
      _clearFields();
    });
  }

  void _toggleEmailLogin() {
    setState(() {
      _showPhoneLogin = false;
      _showOtpField = false;
      _clearFields();
    });
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _otpController.clear();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }
}
