import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/l10n/app_localizations.dart';
import 'core/network/dependencies.dart';
import 'core/routing/router.dart';
import 'core/utils/theme.dart';
import 'global/managers/locale/localization_cubit.dart';
import 'global/managers/locale/locale_repository_impl.dart';
import 'global/managers/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  runApp(MyApp(pref: pref));
}

class MyApp extends StatelessWidget {
  final SharedPreferences pref;

  const MyApp({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LocalizationCubit(
              localeRepo: LocaleRepositoryImpl(pref),
            ),
          ),
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(440, 956),
          ensureScreenSize: true,
          builder: (context, child) => BlocBuilder<LocalizationCubit, Locale>(
            builder: (context, currentLocale) {
              return BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme().lightTheme,
                    darkTheme: AppTheme().darkTheme,
                    locale: currentLocale,
                    localizationsDelegates: MyLocalizations.localizationsDelegates,
                    supportedLocales: MyLocalizations.supportedLocales,
                    title: 'Taminotchi',
                    themeMode: themeMode,
                    routerConfig: router,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
