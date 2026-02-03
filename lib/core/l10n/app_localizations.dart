import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MyLocalizations
/// returned by `MyLocalizations.of(context)`.
///
/// Applications need to include `MyLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MyLocalizations.localizationsDelegates,
///   supportedLocales: MyLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MyLocalizations.supportedLocales
/// property.
abstract class MyLocalizations {
  MyLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MyLocalizations? of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  static const LocalizationsDelegate<MyLocalizations> delegate =
      _MyLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// Onboarding qismida birinchi chiqib turadigan qismi
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get welcome;

  /// No description provided for @withName.
  ///
  /// In uz, this message translates to:
  /// **'Salom! {name}'**
  String withName(Object name);

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Quyida oʻzingiz yoqtirgan tilni tanlang. Bu sizga yaxshiroq xizmat koʻrsatishimizga yordam beradi.'**
  String get choosePreferredLanguage;

  /// No description provided for @selected.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan'**
  String get selected;

  /// No description provided for @allLanguages.
  ///
  /// In uz, this message translates to:
  /// **'Hamma tillar'**
  String get allLanguages;

  /// No description provided for @continueButton.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueButton;

  /// No description provided for @authCreateAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisob ochish'**
  String get authCreateAccount;

  /// No description provided for @authUsername.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomi'**
  String get authUsername;

  /// No description provided for @authCreateUsernameHint.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomini yarating...'**
  String get authCreateUsernameHint;

  /// No description provided for @authPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get authPassword;

  /// No description provided for @authCreatePasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Parol yarating...'**
  String get authCreatePasswordHint;

  /// No description provided for @authConfirmPassword.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlovchi Parol'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang...'**
  String get authConfirmPasswordHint;

  /// No description provided for @authAgreementPart1.
  ///
  /// In uz, this message translates to:
  /// **'Ro‘yxatdan o‘tish orqali siz '**
  String get authAgreementPart1;

  /// No description provided for @authAgreementPart2.
  ///
  /// In uz, this message translates to:
  /// **'Ommaviy orfeta va Maxfiylik siyosatiga'**
  String get authAgreementPart2;

  /// No description provided for @authAgreementPart3.
  ///
  /// In uz, this message translates to:
  /// **' rozilik bildirasiz'**
  String get authAgreementPart3;

  /// No description provided for @authPublicOffer.
  ///
  /// In uz, this message translates to:
  /// **'Ommaviy orfeta'**
  String get authPublicOffer;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get authPrivacyPolicy;

  /// No description provided for @signUpButton.
  ///
  /// In uz, this message translates to:
  /// **'Ro’yxatdan o’tish'**
  String get signUpButton;

  /// No description provided for @authSignUpWithGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali yozilish'**
  String get authSignUpWithGoogle;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz bormi?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @loginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginButton;

  /// No description provided for @authPasswordLengthWarning.
  ///
  /// In uz, this message translates to:
  /// **'Parolingiz kamida 6ta belgidan iborat bo‘lishi shart!'**
  String get authPasswordLengthWarning;

  /// No description provided for @authEnterUsernameHint.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomini kiriting...'**
  String get authEnterUsernameHint;

  /// No description provided for @authEnterPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Parolingizni kiriting...'**
  String get authEnterPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccountYet.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz hali yo’qmi?'**
  String get authNoAccountYet;

  /// No description provided for @authInvalidUsername.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, to’g’ri foydalanuvchi nomini kiriting!'**
  String get authInvalidUsername;

  /// No description provided for @authOr.
  ///
  /// In uz, this message translates to:
  /// **'yoki'**
  String get authOr;

  /// No description provided for @authEnterUsernameValidation.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, foydalanuvchi nomini kiriting!'**
  String get authEnterUsernameValidation;

  /// No description provided for @authUsernameLengthValidation.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomi kamida 3 ta belgi bo\'lishi kerak'**
  String get authUsernameLengthValidation;

  /// No description provided for @authEnterPasswordValidation.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, Parol kiriting'**
  String get authEnterPasswordValidation;

  /// No description provided for @authConfirmPasswordValidation.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, Parolni tasdiqlang'**
  String get authConfirmPasswordValidation;

  /// No description provided for @authPasswordsNotMatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get authPasswordsNotMatch;

  /// No description provided for @authUsernameMaxLength.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomi 24 tadan ortiq belgi bo\'lishi mumkin emas.'**
  String get authUsernameMaxLength;

  /// No description provided for @authUsernameCannotStartWithUnderscore.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomi \'_\' bilan boshlanishi mumkin emas.'**
  String get authUsernameCannotStartWithUnderscore;

  /// No description provided for @authUsernameCannotEndWithUnderscore.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi nomi \'_\' bilan tugashi mumkin emas.'**
  String get authUsernameCannotEndWithUnderscore;

  /// No description provided for @authUsernameFormat.
  ///
  /// In uz, this message translates to:
  /// **'Harflar, raqamlar va \'_\' dan foydalaning.'**
  String get authUsernameFormat;

  /// No description provided for @authUsernameAllowedChars.
  ///
  /// In uz, this message translates to:
  /// **'Faqat kichik harflar (a-z), raqamlar (0-9) va \'_\' belgisiga ruxsat beriladi.'**
  String get authUsernameAllowedChars;

  /// No description provided for @authPasswordLengthRange.
  ///
  /// In uz, this message translates to:
  /// **'Parol 6 dan 24 gacha belgi oralig\'ida bo\'lishi kerak.'**
  String get authPasswordLengthRange;

  /// No description provided for @authPasswordMustContainNumber.
  ///
  /// In uz, this message translates to:
  /// **'Parolda kamida 1 ta raqam bo\'lishi kerak.'**
  String get authPasswordMustContainNumber;

  /// No description provided for @authPasswordMustContainLetter.
  ///
  /// In uz, this message translates to:
  /// **'Parolda kamida 1 ta harf bo\'lishi kerak.'**
  String get authPasswordMustContainLetter;

  /// No description provided for @authLoginWithTelegram.
  ///
  /// In uz, this message translates to:
  /// **'telegram orqali kirish'**
  String get authLoginWithTelegram;

  /// No description provided for @authViaTelegram.
  ///
  /// In uz, this message translates to:
  /// **'telegram orqali'**
  String get authViaTelegram;

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'tez kunda'**
  String get comingSoon;

  /// No description provided for @authUsernamePasswordSame.
  ///
  /// In uz, this message translates to:
  /// **'username parol bilan bir xil bo\'la olmaydi.'**
  String get authUsernamePasswordSame;

  /// No description provided for @joinTheCompetition.
  ///
  /// In uz, this message translates to:
  /// **'Quizzga qo‘shilish'**
  String get joinTheCompetition;

  /// No description provided for @liveQuizzes.
  ///
  /// In uz, this message translates to:
  /// **'Jonli quizlar'**
  String get liveQuizzes;

  /// No description provided for @trendingQuizzes.
  ///
  /// In uz, this message translates to:
  /// **'Trenddagi quizlar'**
  String get trendingQuizzes;

  /// No description provided for @leaderboard.
  ///
  /// In uz, this message translates to:
  /// **'Yetakchilar jadvali'**
  String get leaderboard;

  /// No description provided for @all.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get all;

  /// No description provided for @join.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shilish'**
  String get join;

  /// No description provided for @level.
  ///
  /// In uz, this message translates to:
  /// **'daraja'**
  String get level;

  /// No description provided for @editProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get editProfile;

  /// No description provided for @competitions.
  ///
  /// In uz, this message translates to:
  /// **'Bellashuvlar'**
  String get competitions;

  /// No description provided for @numberOfQuizzes.
  ///
  /// In uz, this message translates to:
  /// **'Quizlar soni'**
  String get numberOfQuizzes;

  /// No description provided for @likes.
  ///
  /// In uz, this message translates to:
  /// **'Layklar'**
  String get likes;

  /// No description provided for @addFriends.
  ///
  /// In uz, this message translates to:
  /// **'Do‘st qo‘shish'**
  String get addFriends;

  /// No description provided for @myQuizzes.
  ///
  /// In uz, this message translates to:
  /// **'Quizlarim'**
  String get myQuizzes;

  /// No description provided for @myFavoriteQuizzes.
  ///
  /// In uz, this message translates to:
  /// **'Yoqtirgan quizlarim'**
  String get myFavoriteQuizzes;

  /// No description provided for @myStatistics.
  ///
  /// In uz, this message translates to:
  /// **'Statistikam'**
  String get myStatistics;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @changeImage.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni o‘zgartirish'**
  String get changeImage;

  /// No description provided for @fullName.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ism'**
  String get fullName;

  /// No description provided for @enterYourFirstName.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ismingizni kiriting...'**
  String get enterYourFirstName;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @emptyStateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ups! Hozircha bo\'sh'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateDescription.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu kategoriyada hali quizlar mavjud emas.\nKeyinroq qaytib ko\'ring.'**
  String get emptyStateDescription;

  /// No description provided for @refresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get refresh;

  /// No description provided for @internetNoConnection.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q!'**
  String get internetNoConnection;

  /// No description provided for @internetCheckConnection.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, tarmoq ulanishini tekshiring va qayta urinib ko\'ring.'**
  String get internetCheckConnection;

  /// No description provided for @settings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settings;

  /// No description provided for @connectEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email ulash'**
  String get connectEmail;

  /// No description provided for @connectTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram ulash'**
  String get connectTelegram;

  /// No description provided for @changePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o’zgartirish'**
  String get changePassword;

  /// No description provided for @privacySettings.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik sozlamalari'**
  String get privacySettings;

  /// No description provided for @publicOffer.
  ///
  /// In uz, this message translates to:
  /// **'Ommaviy oferta'**
  String get publicOffer;

  /// No description provided for @privacyTerms.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik shartlari'**
  String get privacyTerms;

  /// No description provided for @notifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifications;

  /// No description provided for @soundEffects.
  ///
  /// In uz, this message translates to:
  /// **'Ovoz effektlari'**
  String get soundEffects;

  /// No description provided for @animations.
  ///
  /// In uz, this message translates to:
  /// **'Animatsiyalar'**
  String get animations;

  /// No description provided for @languages.
  ///
  /// In uz, this message translates to:
  /// **'Tillar'**
  String get languages;
}

class _MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const _MyLocalizationsDelegate();

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(lookupMyLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_MyLocalizationsDelegate old) => false;
}

MyLocalizations lookupMyLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MyLocalizationsEn();
    case 'ru':
      return MyLocalizationsRu();
    case 'uz':
      return MyLocalizationsUz();
  }

  throw FlutterError(
    'MyLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
