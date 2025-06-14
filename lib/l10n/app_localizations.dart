import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zauro'**
  String get onboardingTitle;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Manage your livestock smarter with AI insights, secure records, and fair trade powered by blockchain.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Detect diseases early, monitor animal health, and get real-time AI recommendations for better care.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Prove ownership, trade confidently, and access insurance through secure blockchain-based livestock identity.'**
  String get onboardingDescription3;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to Zauro'**
  String get signInContinue;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInEmail.
  ///
  /// In en, this message translates to:
  /// **'LogIn with Email'**
  String get signInEmail;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signIn;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @joinPixelMarket.
  ///
  /// In en, this message translates to:
  /// **'Join Zauro today'**
  String get joinPixelMarket;

  /// No description provided for @orRegisterWith.
  ///
  /// In en, this message translates to:
  /// **'Or register with'**
  String get orRegisterWith;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @googleLabel.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signUp;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (+216XXXXXXXX)'**
  String get phoneNumberHint;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP code'**
  String get otpHint;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTerms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpButton;

  /// No description provided for @verifyAndCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify & Create Account'**
  String get verifyAndCreateAccount;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @errorBothFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get errorBothFields;

  /// No description provided for @errorPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get errorPhoneNumber;

  /// No description provided for @errorPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Phone number must include country code (e.g., +216XXXXXXXX)'**
  String get errorPhoneFormat;

  /// No description provided for @errorOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP code'**
  String get errorOtpCode;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnexpected;

  /// No description provided for @errorSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get errorSendOtp;

  /// No description provided for @errorVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify OTP'**
  String get errorVerifyOtp;

  /// No description provided for @errorGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get errorGoogleSignIn;

  /// No description provided for @errorResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get errorResendOtp;

  /// No description provided for @errorEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get errorEmailAddress;

  /// No description provided for @errorResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email'**
  String get errorResetEmail;

  /// No description provided for @successLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get successLogin;

  /// No description provided for @successOtpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your phone number'**
  String get successOtpSent;

  /// No description provided for @successPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verification successful!'**
  String get successPhoneVerified;

  /// No description provided for @successOtpResent.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get successOtpResent;

  /// No description provided for @successResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get successResetEmail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
