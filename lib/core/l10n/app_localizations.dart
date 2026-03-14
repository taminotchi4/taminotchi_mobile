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

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Quyida oʻzingiz yoqtirgan tilni tanlang.'**
  String get choosePreferredLanguage;

  /// No description provided for @continueButton.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueButton;

  /// No description provided for @home.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In uz, this message translates to:
  /// **'Sozalamalar'**
  String get settings;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @error.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik'**
  String get error;

  /// No description provided for @noInternet.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get noInternet;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @createPost.
  ///
  /// In uz, this message translates to:
  /// **'Elon joylash'**
  String get createPost;

  /// No description provided for @postContentHint.
  ///
  /// In uz, this message translates to:
  /// **'Elon matnini kiriting...'**
  String get postContentHint;

  /// No description provided for @send.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get send;

  /// No description provided for @success.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli'**
  String get success;

  /// No description provided for @postCreatedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Elon muvaffaqiyatli joylandi'**
  String get postCreatedSuccess;

  /// No description provided for @myPosts.
  ///
  /// In uz, this message translates to:
  /// **'Mening e-lonlarim'**
  String get myPosts;

  /// No description provided for @noPostsYet.
  ///
  /// In uz, this message translates to:
  /// **'Sizning postlaringiz hozircha yoq'**
  String get noPostsYet;

  /// No description provided for @comments.
  ///
  /// In uz, this message translates to:
  /// **'Izohlar'**
  String get comments;

  /// No description provided for @privateReplies.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy javoblar'**
  String get privateReplies;

  /// No description provided for @all.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get all;

  /// No description provided for @nightMode.
  ///
  /// In uz, this message translates to:
  /// **'Tungi rejim'**
  String get nightMode;

  /// No description provided for @language.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik'**
  String get privacy;

  /// No description provided for @other.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get other;

  /// No description provided for @myOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarim'**
  String get myOrders;

  /// No description provided for @help.
  ///
  /// In uz, this message translates to:
  /// **'Yordam'**
  String get help;

  /// No description provided for @faq.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'p beriladigan savollar (FAQs)'**
  String get faq;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham chiqmoqchimisiz?'**
  String get logoutConfirm;

  /// No description provided for @noProfileData.
  ///
  /// In uz, this message translates to:
  /// **'Profil ma\'lumotlari topilmadi'**
  String get noProfileData;

  /// No description provided for @faqQ1.
  ///
  /// In uz, this message translates to:
  /// **'Qanday qilib e\'lon joylashtirish mumkin?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy sahifadagi \'+ Elon joylash\' tugmasini bosing, kerakli ma\'lumotlarni kiriting va yuboring.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In uz, this message translates to:
  /// **'Xarid qilgan mahsulotimni qanday qaytaraman?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni qaytarish shartlari sotuvchi bilan kelishiladi. Admin bilan bog\'lanish uchun \'Yordam\' tugmasidan foydalaning.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In uz, this message translates to:
  /// **'Profil ma\'lumotlarini qanday o\'zgartiraman?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In uz, this message translates to:
  /// **'Profil sahifasidagi tahrirlash belgisini bosing.'**
  String get faqA3;

  /// No description provided for @posts.
  ///
  /// In uz, this message translates to:
  /// **'E\'lonlar'**
  String get posts;

  /// No description provided for @products.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get products;

  /// No description provided for @postCreated.
  ///
  /// In uz, this message translates to:
  /// **'Post yaratildi'**
  String get postCreated;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobga kirish'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredContent.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon joylash uchun Login qilishingiz kerak'**
  String get loginRequiredContent;

  /// No description provided for @login.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get login;

  /// No description provided for @productsNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar topilmadi'**
  String get productsNotFound;

  /// No description provided for @loadMore.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'proq yuklash'**
  String get loadMore;

  /// No description provided for @product.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot'**
  String get product;

  /// No description provided for @selectSizeError.
  ///
  /// In uz, this message translates to:
  /// **'Mos o\'lchamni tanlang'**
  String get selectSizeError;

  /// No description provided for @colors.
  ///
  /// In uz, this message translates to:
  /// **'Ranglar'**
  String get colors;

  /// No description provided for @sizes.
  ///
  /// In uz, this message translates to:
  /// **'O\'lchamlar'**
  String get sizes;

  /// No description provided for @description.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get description;

  /// No description provided for @aboutProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot haqida'**
  String get aboutProduct;

  /// No description provided for @justNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgina'**
  String get justNow;

  /// No description provided for @daysAgo.
  ///
  /// In uz, this message translates to:
  /// **'{days} kun oldin'**
  String daysAgo(int days);

  /// No description provided for @hoursAgo.
  ///
  /// In uz, this message translates to:
  /// **'{hours} soat oldin'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In uz, this message translates to:
  /// **'{minutes} daqiqa oldin'**
  String minutesAgo(int minutes);

  /// No description provided for @edit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get delete;

  /// No description provided for @noCommentsYet.
  ///
  /// In uz, this message translates to:
  /// **'Izohlar yo\'q'**
  String get noCommentsYet;

  /// No description provided for @showLess.
  ///
  /// In uz, this message translates to:
  /// **'Kamroq ko\'rsatish'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In uz, this message translates to:
  /// **'...ko\'proq'**
  String get showMore;

  /// No description provided for @reply.
  ///
  /// In uz, this message translates to:
  /// **'Javob berish'**
  String get reply;

  /// No description provided for @replyingTo.
  ///
  /// In uz, this message translates to:
  /// **'{name}ga javob yozilmoqda'**
  String replyingTo(String name);

  /// No description provided for @writeReply.
  ///
  /// In uz, this message translates to:
  /// **'Javob yozing...'**
  String get writeReply;

  /// No description provided for @writeComment.
  ///
  /// In uz, this message translates to:
  /// **'Izoh yozing...'**
  String get writeComment;

  /// No description provided for @editComment.
  ///
  /// In uz, this message translates to:
  /// **'Izohni tahrirlash...'**
  String get editComment;

  /// No description provided for @ratingHint.
  ///
  /// In uz, this message translates to:
  /// **'Yulduzchalarni to\'llidirsh uchun chapdan o\'ngga suring.'**
  String get ratingHint;

  /// No description provided for @ratingError.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 1 yulduzgacha ratingni tanlang'**
  String get ratingError;

  /// No description provided for @addToCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shish'**
  String get addToCart;

  /// No description provided for @noOrdersYet.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar hozircha mavjud emas'**
  String get noOrdersYet;

  /// No description provided for @search.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish...'**
  String get search;

  /// No description provided for @tapToPost.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon joylash uchun tugmani bosing'**
  String get tapToPost;

  /// No description provided for @addPost.
  ///
  /// In uz, this message translates to:
  /// **'+ Elon joylash'**
  String get addPost;

  /// No description provided for @postCreationHint.
  ///
  /// In uz, this message translates to:
  /// **'Siz maxsulot qidirmaysiz! Nima kerak ekanligini yozing, sotuvchilar o\'zi sizni topishadi'**
  String get postCreationHint;

  /// No description provided for @uploadImageHint.
  ///
  /// In uz, this message translates to:
  /// **'Maxsulotning taxminiy rasmi bo\'lsa yuklang(ixtiyoriy)'**
  String get uploadImageHint;

  /// No description provided for @selectCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tanlang'**
  String get selectCategory;

  /// No description provided for @gallery.
  ///
  /// In uz, this message translates to:
  /// **'Galereya'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @postDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Qidirayotgan maxsulotingizning tafsilotlarini kiriting...'**
  String get postDescriptionHint;

  /// No description provided for @userOnlyPost.
  ///
  /// In uz, this message translates to:
  /// **'Post yaratish faqat foydalanuvchilar uchun'**
  String get userOnlyPost;

  /// No description provided for @imagesMax8.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar (maksimum 8 ta)'**
  String get imagesMax8;

  /// No description provided for @welcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish uchun telefon raqamingizni kiriting'**
  String get welcomeSubtitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqam'**
  String get phoneNumberLabel;

  /// No description provided for @enterPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolingizni kiriting'**
  String get enterPassword;

  /// No description provided for @change.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get change;

  /// No description provided for @password.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get password;

  /// No description provided for @verify.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get verify;

  /// No description provided for @enterOtp.
  ///
  /// In uz, this message translates to:
  /// **'{phone} raqamiga yuborilgan 6 xonali kodni kiriting'**
  String enterOtp(String phone);

  /// No description provided for @resendCode.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get resendCode;

  /// No description provided for @register.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get register;

  /// No description provided for @fillProfileInfo.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlaringizni to\'ldiring'**
  String get fillProfileInfo;

  /// No description provided for @fullName.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ism'**
  String get fullName;

  /// No description provided for @fullNameExample.
  ///
  /// In uz, this message translates to:
  /// **'Isroilov Abdulloh'**
  String get fullNameExample;

  /// No description provided for @username.
  ///
  /// In uz, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameExample.
  ///
  /// In uz, this message translates to:
  /// **'ali'**
  String get usernameExample;

  /// No description provided for @createPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Parol yarating...'**
  String get createPasswordHint;

  /// No description provided for @uzbek.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get uzbek;

  /// No description provided for @russian.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @priceLabel.
  ///
  /// In uz, this message translates to:
  /// **'Narxi:'**
  String get priceLabel;

  /// No description provided for @addressLabel.
  ///
  /// In uz, this message translates to:
  /// **'Manzil:'**
  String get addressLabel;

  /// No description provided for @statusAgreed.
  ///
  /// In uz, this message translates to:
  /// **'Kelishilgan'**
  String get statusAgreed;

  /// No description provided for @statusActive.
  ///
  /// In uz, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @leaveComment.
  ///
  /// In uz, this message translates to:
  /// **'Izoh qoldiring'**
  String get leaveComment;

  /// No description provided for @izohlarCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} izoh'**
  String izohlarCount(int count);

  /// No description provided for @hideReplies.
  ///
  /// In uz, this message translates to:
  /// **'Javoblarni yashirish'**
  String get hideReplies;

  /// No description provided for @viewReplies.
  ///
  /// In uz, this message translates to:
  /// **'Javoblarni ko\'rish ({count})'**
  String viewReplies(int count);

  /// No description provided for @post.
  ///
  /// In uz, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Post topilmadi'**
  String get postNotFound;

  /// No description provided for @editComingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash funksiyasi yaqin orada qo\'shiladi'**
  String get editComingSoon;

  /// No description provided for @postActivated.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon faollashtirildi'**
  String get postActivated;

  /// No description provided for @postArchivedAgreed.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon kelishilgan deb belgilandi'**
  String get postArchivedAgreed;

  /// No description provided for @markAsAgreed.
  ///
  /// In uz, this message translates to:
  /// **'Kelishilgan deb belgilash'**
  String get markAsAgreed;

  /// No description provided for @reactivate.
  ///
  /// In uz, this message translates to:
  /// **'Qayta faollashtirish'**
  String get reactivate;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In uz, this message translates to:
  /// **'Postni o\'chirmoqchimisiz?'**
  String get deleteConfirmContent;

  /// No description provided for @noComments.
  ///
  /// In uz, this message translates to:
  /// **'Izohlar hozircha yo\'q'**
  String get noComments;

  /// No description provided for @noReplies.
  ///
  /// In uz, this message translates to:
  /// **'Javoblar hozircha yo\'q'**
  String get noReplies;

  /// No description provided for @writeReplyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Javob yozish'**
  String get writeReplyTitle;

  /// No description provided for @writeReplyHint.
  ///
  /// In uz, this message translates to:
  /// **'Javobingizni yozing...'**
  String get writeReplyHint;

  /// No description provided for @replySent.
  ///
  /// In uz, this message translates to:
  /// **'Javob yuborildi'**
  String get replySent;

  /// No description provided for @category.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya'**
  String get category;

  /// No description provided for @noPostsInCategory.
  ///
  /// In uz, this message translates to:
  /// **'Bu kategoriyada hozircha e\'lonlar yo\'q'**
  String get noPostsInCategory;

  /// No description provided for @aboutUs.
  ///
  /// In uz, this message translates to:
  /// **'Biz haqimizda'**
  String get aboutUs;

  /// No description provided for @contactSupport.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash xizmati'**
  String get contactSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanish shartlari'**
  String get termsOfUse;

  /// No description provided for @following.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatilmoqda'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatish'**
  String get follow;

  /// No description provided for @followers.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatuvchilar'**
  String get followers;

  /// No description provided for @filter.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get filter;

  /// No description provided for @mostSold.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'p sotilgan'**
  String get mostSold;

  /// No description provided for @highestRating.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori reyting'**
  String get highestRating;

  /// No description provided for @sortDefault.
  ///
  /// In uz, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// No description provided for @allCategories.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get allCategories;

  /// No description provided for @seller.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi'**
  String get seller;

  /// No description provided for @sellerNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi topilmadi'**
  String get sellerNotFound;

  /// No description provided for @chats.
  ///
  /// In uz, this message translates to:
  /// **'Chatlar'**
  String get chats;

  /// No description provided for @noChats.
  ///
  /// In uz, this message translates to:
  /// **'Chatlar yo\'q'**
  String get noChats;

  /// No description provided for @resultNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Natija topilmadi'**
  String get resultNotFound;

  /// No description provided for @clickPostToDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish uchun e\'lon ustiga bosing'**
  String get clickPostToDelete;

  /// No description provided for @market.
  ///
  /// In uz, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @user.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get user;

  /// No description provided for @notificationsNone.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar yo\'q'**
  String get notificationsNone;
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
