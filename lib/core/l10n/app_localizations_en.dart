// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MyLocalizationsEn extends MyLocalizations {
  MyLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome!';

  @override
  String withName(Object name) {
    return 'Hi! $name';
  }

  @override
  String get selectLanguage => 'Select a language';

  @override
  String get choosePreferredLanguage =>
      'Choose your preferred language below. This will help us serve you better.';

  @override
  String get selected => 'Selected';

  @override
  String get allLanguages => 'All languages';

  @override
  String get continueButton => 'Continue';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authUsername => 'Username';

  @override
  String get authCreateUsernameHint => 'Create a username...';

  @override
  String get authPassword => 'Password';

  @override
  String get authCreatePasswordHint => 'Create a password...';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authConfirmPasswordHint => 'Confirm the password...';

  @override
  String get authAgreementPart1 => 'By signing up, you agree to the ';

  @override
  String get authAgreementPart2 => 'Public Offer and the Privacy Policy';

  @override
  String get authAgreementPart3 => ' terms';

  @override
  String get authPublicOffer => 'Public Offer';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get authSignUpWithGoogle => 'Sign up with Google';

  @override
  String get authAlreadyHaveAccount => 'Do you have an account?';

  @override
  String get loginButton => 'Log In';

  @override
  String get authPasswordLengthWarning =>
      'Your password must be at least 6 characters long!';

  @override
  String get authEnterUsernameHint => 'Enter username...';

  @override
  String get authEnterPasswordHint => 'Enter your password...';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccountYet => 'Don\'t have an account yet?';

  @override
  String get authInvalidUsername => 'Please enter a valid username!';

  @override
  String get authOr => 'or';

  @override
  String get authEnterUsernameValidation => 'Please enter a username!';

  @override
  String get authUsernameLengthValidation =>
      'Username must be at least 3 characters long';

  @override
  String get authEnterPasswordValidation => 'Please enter a password';

  @override
  String get authConfirmPasswordValidation => 'Please confirm the password';

  @override
  String get authPasswordsNotMatch => 'Passwords do not match';

  @override
  String get authUsernameMaxLength => 'Username cannot exceed 24 characters.';

  @override
  String get authUsernameCannotStartWithUnderscore =>
      'Username cannot start with \'_\'.';

  @override
  String get authUsernameCannotEndWithUnderscore =>
      'Username cannot end with \'_\'.';

  @override
  String get authUsernameFormat => 'Use letters, numbers, and \'_\'.';

  @override
  String get authUsernameAllowedChars =>
      'Only lowercase letters (a-z), numbers (0-9), and \'_\' are allowed.';

  @override
  String get authPasswordLengthRange =>
      'Password must be between 6 and 24 characters.';

  @override
  String get authPasswordMustContainNumber =>
      'Password must contain at least 1 number.';

  @override
  String get authPasswordMustContainLetter =>
      'Password must contain at least 1 letter.';

  @override
  String get authLoginWithTelegram => 'Login with Telegram';

  @override
  String get authViaTelegram => 'via Telegram';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get authUsernamePasswordSame =>
      'Username cannot be the same as the password.';

  @override
  String get joinTheCompetition => 'Join the competition';

  @override
  String get liveQuizzes => 'Live quizzes';

  @override
  String get trendingQuizzes => 'Trending quizzes';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get all => 'All';

  @override
  String get join => 'Join';

  @override
  String get level => 'level';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get competitions => 'Competitions';

  @override
  String get numberOfQuizzes => 'My quizzes';

  @override
  String get likes => 'Likes';

  @override
  String get addFriends => 'Add friends';

  @override
  String get myQuizzes => 'My quizzes';

  @override
  String get myFavoriteQuizzes => 'My favorite quizzes';

  @override
  String get myStatistics => 'My statistics';

  @override
  String get profile => 'Profile';

  @override
  String get changeImage => 'Change image';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourFirstName => 'Enter your full name...';

  @override
  String get save => 'Save';

  @override
  String get emptyStateTitle => 'Oops! It\'s empty for now';

  @override
  String get emptyStateDescription =>
      'There are no quizzes in this category yet.\nPlease check back later.';

  @override
  String get refresh => 'Refresh';

  @override
  String get internetNoConnection => 'No internet connection!';

  @override
  String get internetCheckConnection =>
      'Please check your network connection and try again.';

  @override
  String get settings => 'Settings';

  @override
  String get connectEmail => 'Connect Email';

  @override
  String get connectTelegram => 'Connect Telegram';

  @override
  String get changePassword => 'Change Password';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get publicOffer => 'Ommaviy oferta';

  @override
  String get privacyTerms => 'Maxfiylik shartlari';

  @override
  String get notifications => 'Notifications';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get animations => 'Animations';

  @override
  String get languages => 'Languages';
}
