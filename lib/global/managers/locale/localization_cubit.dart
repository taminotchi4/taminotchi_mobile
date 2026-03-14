// localization_cubit.dart
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_repository.dart';

class LocalizationCubit extends Cubit<Locale> {
  final LocaleRepository _localeRepo;
  static const Locale defaultLocale = Locale('uz');
  LocalizationCubit({required LocaleRepository localeRepo}) : _localeRepo = localeRepo, super(defaultLocale) {
    _loadInitialLocale();
  }

  void _loadInitialLocale() async {
    final initialLocale = await _localeRepo.getLocale();
    emit(initialLocale);
  }

  Future<void> changeLocale({required String localeCode}) async {
    final newLocale = Locale(localeCode);
    await _localeRepo.saveLocale(newLocale);
    emit(newLocale);
  }
}
