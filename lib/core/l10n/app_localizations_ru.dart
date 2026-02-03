// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class MyLocalizationsRu extends MyLocalizations {
  MyLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcome => 'Добро пожаловать!';

  @override
  String withName(Object name) {
    return 'Привет! $name';
  }

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get choosePreferredLanguage =>
      'Выберите предпочтительный язык ниже. Это поможет нам предоставлять вам лучший сервис.';

  @override
  String get selected => 'Выбрано';

  @override
  String get allLanguages => 'Все языки';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authUsername => 'Имя пользователя';

  @override
  String get authCreateUsernameHint => 'Придумайте имя пользователя...';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authCreatePasswordHint => 'Придумайте пароль...';

  @override
  String get authConfirmPassword => 'Подтверждение пароля';

  @override
  String get authConfirmPasswordHint => 'Подтвердите пароль...';

  @override
  String get authAgreementPart1 => 'Регистрируясь, вы соглашаетесь с ';

  @override
  String get authAgreementPart2 =>
      'Публичной офертой и Политикой конфиденциальности';

  @override
  String get authAgreementPart3 => ' условиями';

  @override
  String get authPublicOffer => 'Публичная оферта';

  @override
  String get authPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get signUpButton => 'Зарегистрироваться';

  @override
  String get authSignUpWithGoogle => 'Войти через Google';

  @override
  String get authAlreadyHaveAccount => 'У вас есть аккаунт?';

  @override
  String get loginButton => 'Войти';

  @override
  String get authPasswordLengthWarning =>
      'Ваш пароль должен состоять как минимум из 6 символов!';

  @override
  String get authEnterUsernameHint => 'Введите имя пользователя...';

  @override
  String get authEnterPasswordHint => 'Введите ваш пароль...';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authNoAccountYet => 'У вас еще нет аккаунта?';

  @override
  String get authInvalidUsername =>
      'Пожалуйста, введите корректное имя пользователя!';

  @override
  String get authOr => 'или';

  @override
  String get authEnterUsernameValidation =>
      'Пожалуйста, введите имя пользователя!';

  @override
  String get authUsernameLengthValidation =>
      'Имя пользователя должно состоять минимум из 3 символов';

  @override
  String get authEnterPasswordValidation => 'Пожалуйста, введите Пароль';

  @override
  String get authConfirmPasswordValidation => 'Пожалуйста, подтвердите Пароль';

  @override
  String get authPasswordsNotMatch => 'Пароли не совпадают';

  @override
  String get authUsernameMaxLength =>
      'Имя пользователя не может превышать 24 символа.';

  @override
  String get authUsernameCannotStartWithUnderscore =>
      'Имя пользователя не может начинаться с \'_\'.';

  @override
  String get authUsernameCannotEndWithUnderscore =>
      'Имя пользователя не может заканчиваться на \'_\'.';

  @override
  String get authUsernameFormat => 'Используйте буквы, цифры и \'_\'.';

  @override
  String get authUsernameAllowedChars =>
      'Разрешены только строчные буквы (a-z), цифры (0-9) и символ \'_\'.';

  @override
  String get authPasswordLengthRange =>
      'Пароль должен быть от 6 до 24 символов.';

  @override
  String get authPasswordMustContainNumber =>
      'Пароль должен содержать как минимум 1 цифру.';

  @override
  String get authPasswordMustContainLetter =>
      'Пароль должен содержать как минимум 1 букву.';

  @override
  String get authLoginWithTelegram => 'Войти через Telegram';

  @override
  String get authViaTelegram => 'через Telegram';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get authUsernamePasswordSame =>
      'Имя пользователя не может совпадать с паролем.';

  @override
  String get joinTheCompetition => 'Присоединиться к соревнованию';

  @override
  String get liveQuizzes => 'Прямые викторины';

  @override
  String get trendingQuizzes => 'Популярные викторины';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get all => 'Все';

  @override
  String get join => 'Присоединиться';

  @override
  String get level => 'Уровень';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get competitions => 'Соревнования';

  @override
  String get numberOfQuizzes => 'Количество викторин';

  @override
  String get likes => 'Лайки';

  @override
  String get addFriends => 'Добавить друзей';

  @override
  String get myQuizzes => 'Мои викторины';

  @override
  String get myFavoriteQuizzes => 'Мои избранные викторины';

  @override
  String get myStatistics => 'Моя статистика';

  @override
  String get profile => 'Профиль';

  @override
  String get changeImage => 'Изменить изображение';

  @override
  String get fullName => 'Полное имя';

  @override
  String get enterYourFirstName => 'Введите ваше полное имя...';

  @override
  String get save => 'Сохранить';

  @override
  String get emptyStateTitle => 'Ой! Пока пусто';

  @override
  String get emptyStateDescription =>
      'В этой категории пока нет викторин.\nПожалуйста, зайдите позже.';

  @override
  String get refresh => 'Обновить';

  @override
  String get internetNoConnection => 'Нет интернет-соединения!';

  @override
  String get internetCheckConnection =>
      'Пожалуйста, проверьте подключение к сети и попробуйте еще раз.';

  @override
  String get settings => 'Настройки';

  @override
  String get connectEmail => 'Подключить почту';

  @override
  String get connectTelegram => 'Подключить Telegram';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get privacySettings => 'Настройки конфиденциальности';

  @override
  String get publicOffer => 'Публичная оферта';

  @override
  String get privacyTerms => 'Условия конфиденциальности';

  @override
  String get notifications => 'Уведомления';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get animations => 'Анимации';

  @override
  String get languages => 'Языки';
}
