import 'dart:ui';

abstract class LocaleRepository {
  Future<Locale> getLocale();

  Future<void> saveLocale(Locale locale);
}
