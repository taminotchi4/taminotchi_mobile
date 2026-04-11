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

  @override
  String get nightMode => 'Ночной режим';

  @override
  String get language => 'Язык';

  @override
  String get notifications => 'Уведомления';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get other => 'Прочее';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get help => 'Помощь';

  @override
  String get faq => 'Часто задаваемые вопросы (FAQs)';

  @override
  String get logout => 'Выход';

  @override
  String get logoutConfirm => 'Вы действительно хотите выйти?';

  @override
  String get noProfileData => 'Данные профиля не найдены';

  @override
  String get faqQ1 => 'Как разместить объявление?';

  @override
  String get faqA1 =>
      'Нажмите кнопку \'+ Разместить\' на главной странице, введите необходимые данные и отправьте.';

  @override
  String get faqQ2 => 'Как вернуть купленный товар?';

  @override
  String get faqA2 =>
      'Условия возврата товара согласовываются с продавцом. Для связи con админом используйте кнопку \'Помощь\'.';

  @override
  String get faqQ3 => 'Как изменить данные профиля?';

  @override
  String get faqA3 => 'Нажмите на значок редактирования на странице профиля.';

  @override
  String get posts => 'Объявления';

  @override
  String get products => 'Продукты';

  @override
  String get postCreated => 'Пост создан';

  @override
  String get loginRequiredTitle => 'Вход в аккаунт';

  @override
  String get loginRequiredContent =>
      'Чтобы разместить объявление, необходимо войти в аккаунт';

  @override
  String get login => 'Вход';

  @override
  String get productsNotFound => 'Продукты не найдены';

  @override
  String get loadMore => 'Загрузить больше';

  @override
  String get product => 'Продукт';

  @override
  String get selectSizeError => 'Выберите подходящий размер';

  @override
  String get colors => 'Цвета';

  @override
  String get sizes => 'Размеры';

  @override
  String get description => 'Описание';

  @override
  String get aboutProduct => 'О продукте';

  @override
  String get justNow => 'Только что';

  @override
  String daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get noCommentsYet => 'Комментариев пока нет';

  @override
  String get showLess => 'Свернуть';

  @override
  String get showMore => '...ещё';

  @override
  String get reply => 'Ответить';

  @override
  String replyingTo(String name) {
    return 'Вы отвечаете $name';
  }

  @override
  String get writeReply => 'Напишите ответ...';

  @override
  String get writeComment => 'Напишите комментарий...';

  @override
  String get editComment => 'Редактировать комментарий...';

  @override
  String get ratingHint => 'Проведите слева направо, чтобы заполнить звезды.';

  @override
  String get ratingError => 'Выберите рейтинг не менее 1 звезды';

  @override
  String get addToCart => 'Добавить в корзину';

  @override
  String get noOrdersYet => 'Заказов пока нет';

  @override
  String get search => 'Поиск...';

  @override
  String get tapToPost => 'Нажмите на кнопку, чтобы разместить объявление';

  @override
  String get addPost => '+ Разместить';

  @override
  String get postCreationHint =>
      'Вы не ищете товар! Напишите, что вам нужно, и продавцы сами вас найдут';

  @override
  String get uploadImageHint =>
      'Загрузите примерное фото товара (необязательно)';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get postDescriptionHint => 'Введите подробности искомого товара...';

  @override
  String get userOnlyPost => 'Создание постов доступно только пользователям';

  @override
  String get imagesMax8 => 'Картинки (максимум 8 шт)';

  @override
  String get welcomeTitle => 'Добро пожаловать!';

  @override
  String get welcomeSubtitle => 'Введите номер телефона для входа в систему';

  @override
  String get phoneNumberLabel => 'Номер телефона';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get change => 'Изменить';

  @override
  String get password => 'Пароль';

  @override
  String get verify => 'Подтверждение';

  @override
  String enterOtp(String phone) {
    return 'Введите 6-значный код, отправленный на номер $phone';
  }

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get register => 'Регистрация';

  @override
  String get fillProfileInfo => 'Заполните данные вашего профиля';

  @override
  String get fullName => 'Полное имя';

  @override
  String get fullNameExample => 'Иванов Иван';

  @override
  String get username => 'Имя пользователя';

  @override
  String get usernameExample => 'ivan';

  @override
  String get createPasswordHint => 'Придумайте пароль...';

  @override
  String get uzbek => 'Узбекский';

  @override
  String get russian => 'Русский';

  @override
  String get priceLabel => 'Цена:';

  @override
  String get addressLabel => 'Адрес:';

  @override
  String get statusNegotiation => 'В процессе обсуждения';

  @override
  String get statusAgreed => 'Договорено';

  @override
  String get statusActive => 'Активно';

  @override
  String get leaveComment => 'Оставьте комментарий';

  @override
  String izohlarCount(int count) {
    return '$count комментариев';
  }

  @override
  String get hideReplies => 'Скрыть ответы';

  @override
  String viewReplies(int count) {
    return 'Посмотреть ответы ($count)';
  }

  @override
  String get post => 'Пост';

  @override
  String get postNotFound => 'Пост не найден';

  @override
  String get editComingSoon => 'Функция редактирования скоро появится';

  @override
  String get postActivated => 'Объявление активировано';

  @override
  String get postArchivedAgreed => 'Объявление помечено как договеренное';

  @override
  String get markAsAgreed => 'Пометить как догoворено';

  @override
  String get reactivate => 'Активировать снова';

  @override
  String get deleteConfirmTitle => 'Удалить';

  @override
  String get deleteConfirmContent => 'Вы хотите удалить пост?';

  @override
  String get noComments => 'Комментариев пока нет';

  @override
  String get noReplies => 'Ответов пока нет';

  @override
  String get writeReplyTitle => 'Написать ответ';

  @override
  String get writeReplyHint => 'Напишите ваш ответ...';

  @override
  String get replySent => 'Ответ отправлен';

  @override
  String get category => 'Категория';

  @override
  String get noPostsInCategory => 'В этой категории пока нет объявлений';

  @override
  String get aboutUs => 'О нас';

  @override
  String get contactSupport => 'Служба поддержки';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get following => 'Вы подписаны';

  @override
  String get follow => 'Подписаться';

  @override
  String get followers => 'Подписчики';

  @override
  String get filter => 'Фильтр';

  @override
  String get mostSold => 'Самые продаваемые';

  @override
  String get highestRating => 'Высокий рейтинг';

  @override
  String get sortDefault => 'По умолчанию';

  @override
  String get allCategories => 'Все';

  @override
  String get seller => 'Продавец';

  @override
  String get sellerNotFound => 'Продавец не найден';

  @override
  String get chats => 'Чаты';

  @override
  String get noChats => 'Чатов нет';

  @override
  String get resultNotFound => 'Результатов не найдено';

  @override
  String get clickPostToDelete => 'Нажмите на объявление, чтобы удалить';

  @override
  String get market => 'Маркет';

  @override
  String get user => 'Пользователь';

  @override
  String get notificationsNone => 'Уведомлений нет';

  @override
  String get deleteAccountTitle => 'Hisobni o\'chirish';

  @override
  String get deleteAccountConfirm =>
      'Haqiqatan ham hisobingizni butunlay o\'chirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi.';

  @override
  String get deleteAccount => 'O\'chirish';
}
