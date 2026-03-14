import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'locale_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  static const _kLocaleKey = 'preferred_locale';
  final SharedPreferences sharedPreferences;

  LocaleRepositoryImpl(this.sharedPreferences);

  @override
  Future<Locale> getLocale() async {
    final localeCode = sharedPreferences.getString(_kLocaleKey);
    return localeCode != null ? Locale(localeCode) : const Locale('uz');
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await sharedPreferences.setString(_kLocaleKey, locale.languageCode);
  }
}
