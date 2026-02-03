// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class MyLocalizationsUz extends MyLocalizations {
  MyLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get welcome => 'Xush kelibsiz!';

  @override
  String withName(Object name) {
    return 'Salom! $name';
  }

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String get choosePreferredLanguage =>
      'Quyida oʻzingiz yoqtirgan tilni tanlang. Bu sizga yaxshiroq xizmat koʻrsatishimizga yordam beradi.';

  @override
  String get selected => 'Tanlangan';

  @override
  String get allLanguages => 'Hamma tillar';

  @override
  String get continueButton => 'Davom etish';

  @override
  String get authCreateAccount => 'Hisob ochish';

  @override
  String get authUsername => 'Foydalanuvchi nomi';

  @override
  String get authCreateUsernameHint => 'Foydalanuvchi nomini yarating...';

  @override
  String get authPassword => 'Parol';

  @override
  String get authCreatePasswordHint => 'Parol yarating...';

  @override
  String get authConfirmPassword => 'Tasdiqlovchi Parol';

  @override
  String get authConfirmPasswordHint => 'Parolni tasdiqlang...';

  @override
  String get authAgreementPart1 => 'Ro‘yxatdan o‘tish orqali siz ';

  @override
  String get authAgreementPart2 => 'Ommaviy orfeta va Maxfiylik siyosatiga';

  @override
  String get authAgreementPart3 => ' rozilik bildirasiz';

  @override
  String get authPublicOffer => 'Ommaviy orfeta';

  @override
  String get authPrivacyPolicy => 'Maxfiylik siyosati';

  @override
  String get signUpButton => 'Ro’yxatdan o’tish';

  @override
  String get authSignUpWithGoogle => 'Google orqali yozilish';

  @override
  String get authAlreadyHaveAccount => 'Hisobingiz bormi?';

  @override
  String get loginButton => 'Kirish';

  @override
  String get authPasswordLengthWarning =>
      'Parolingiz kamida 6ta belgidan iborat bo‘lishi shart!';

  @override
  String get authEnterUsernameHint => 'Foydalanuvchi nomini kiriting...';

  @override
  String get authEnterPasswordHint => 'Parolingizni kiriting...';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authNoAccountYet => 'Hisobingiz hali yo’qmi?';

  @override
  String get authInvalidUsername =>
      'Iltimos, to’g’ri foydalanuvchi nomini kiriting!';

  @override
  String get authOr => 'yoki';

  @override
  String get authEnterUsernameValidation =>
      'Iltimos, foydalanuvchi nomini kiriting!';

  @override
  String get authUsernameLengthValidation =>
      'Foydalanuvchi nomi kamida 3 ta belgi bo\'lishi kerak';

  @override
  String get authEnterPasswordValidation => 'Iltimos, Parol kiriting';

  @override
  String get authConfirmPasswordValidation => 'Iltimos, Parolni tasdiqlang';

  @override
  String get authPasswordsNotMatch => 'Parollar mos kelmadi';

  @override
  String get authUsernameMaxLength =>
      'Foydalanuvchi nomi 24 tadan ortiq belgi bo\'lishi mumkin emas.';

  @override
  String get authUsernameCannotStartWithUnderscore =>
      'Foydalanuvchi nomi \'_\' bilan boshlanishi mumkin emas.';

  @override
  String get authUsernameCannotEndWithUnderscore =>
      'Foydalanuvchi nomi \'_\' bilan tugashi mumkin emas.';

  @override
  String get authUsernameFormat =>
      'Harflar, raqamlar va \'_\' dan foydalaning.';

  @override
  String get authUsernameAllowedChars =>
      'Faqat kichik harflar (a-z), raqamlar (0-9) va \'_\' belgisiga ruxsat beriladi.';

  @override
  String get authPasswordLengthRange =>
      'Parol 6 dan 24 gacha belgi oralig\'ida bo\'lishi kerak.';

  @override
  String get authPasswordMustContainNumber =>
      'Parolda kamida 1 ta raqam bo\'lishi kerak.';

  @override
  String get authPasswordMustContainLetter =>
      'Parolda kamida 1 ta harf bo\'lishi kerak.';

  @override
  String get authLoginWithTelegram => 'telegram orqali kirish';

  @override
  String get authViaTelegram => 'telegram orqali';

  @override
  String get comingSoon => 'tez kunda';

  @override
  String get authUsernamePasswordSame =>
      'username parol bilan bir xil bo\'la olmaydi.';

  @override
  String get joinTheCompetition => 'Quizzga qo‘shilish';

  @override
  String get liveQuizzes => 'Jonli quizlar';

  @override
  String get trendingQuizzes => 'Trenddagi quizlar';

  @override
  String get leaderboard => 'Yetakchilar jadvali';

  @override
  String get all => 'Barchasi';

  @override
  String get join => 'Qo‘shilish';

  @override
  String get level => 'daraja';

  @override
  String get editProfile => 'Profilni tahrirlash';

  @override
  String get competitions => 'Bellashuvlar';

  @override
  String get numberOfQuizzes => 'Quizlar soni';

  @override
  String get likes => 'Layklar';

  @override
  String get addFriends => 'Do‘st qo‘shish';

  @override
  String get myQuizzes => 'Quizlarim';

  @override
  String get myFavoriteQuizzes => 'Yoqtirgan quizlarim';

  @override
  String get myStatistics => 'Statistikam';

  @override
  String get profile => 'Profil';

  @override
  String get changeImage => 'Rasmni o‘zgartirish';

  @override
  String get fullName => 'To\'liq ism';

  @override
  String get enterYourFirstName => 'To\'liq ismingizni kiriting...';

  @override
  String get save => 'Saqlash';

  @override
  String get emptyStateTitle => 'Ups! Hozircha bo\'sh';

  @override
  String get emptyStateDescription =>
      'Ushbu kategoriyada hali quizlar mavjud emas.\nKeyinroq qaytib ko\'ring.';

  @override
  String get refresh => 'Yangilash';

  @override
  String get internetNoConnection => 'Internet aloqasi yo\'q!';

  @override
  String get internetCheckConnection =>
      'Iltimos, tarmoq ulanishini tekshiring va qayta urinib ko\'ring.';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get connectEmail => 'Email ulash';

  @override
  String get connectTelegram => 'Telegram ulash';

  @override
  String get changePassword => 'Parolni o’zgartirish';

  @override
  String get privacySettings => 'Maxfiylik sozlamalari';

  @override
  String get publicOffer => 'Ommaviy oferta';

  @override
  String get privacyTerms => 'Maxfiylik shartlari';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String get soundEffects => 'Ovoz effektlari';

  @override
  String get animations => 'Animatsiyalar';

  @override
  String get languages => 'Tillar';
}
