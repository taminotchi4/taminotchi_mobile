// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class MyLocalizationsRu extends MyLocalizations {
  MyLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get choosePreferredLanguage => 'Выберите предпочтительный язык ниже.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get home => 'Главная';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get error => 'Ошибка';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get retry => 'Повторить';

  @override
  String get createPost => 'Разместить объявление';

  @override
  String get postContentHint => 'Введите текст объявления...';

  @override
  String get send => 'Отправить';

  @override
  String get success => 'Успешно';

  @override
  String get postCreatedSuccess => 'Объявление успешно размещено';

  @override
  String get myPosts => 'Мои объявления';

  @override
  String get noPostsYet => 'У вас пока нет объявлений';

  @override
  String get comments => 'Комментарии';

  @override
  String get privateReplies => 'Личные ответы';

  @override
  String get all => 'Все';
}
