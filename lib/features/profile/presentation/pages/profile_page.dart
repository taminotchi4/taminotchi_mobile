import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/managers/locale/localization_cubit.dart';
import '../../../../global/managers/theme/theme_cubit.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../managers/client_profile_bloc.dart';
import '../managers/client_profile_event.dart';
import '../managers/client_profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ClientProfileBloc>().add(const ClientProfileStarted());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        ),
        title: Text(
          'Chiqish',
          style: AppStyles.h4Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        content: Text(
          'Haqiqatan ham chiqmoqchimisiz?',
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: AppStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ClientProfileBloc>().add(
                    const ClientProfileLogoutRequested(),
                  );
            },
            child: Text(
              'Chiqish',
              style: AppStyles.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Profil'),
      body: BlocBuilder<ClientProfileBloc, ClientProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.profile == null) {
            return Center(
              child: Text(
                'Profil ma\'lumotlari topilmadi',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppDimens.lg.r),
            child: Column(
              children: [
                ProfileHeader(profile: state.profile!),
                AppDimens.xl.height,
                _buildSectionTitle('Sozlamalar'),
                AppDimens.md.height,
                _buildSettingsCard(
                  children: [
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return ProfileMenuItem(
                          icon: Icons.brightness_6_outlined,
                          title: 'Tungi rejim',
                          trailing: Switch(
                            value: themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              context.read<ThemeCubit>().toggleTheme();
                            },
                            activeTrackColor: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    BlocBuilder<LocalizationCubit, Locale>(
                      builder: (context, locale) {
                        return ProfileMenuItem(
                          icon: Icons.language_outlined,
                          title: 'Til',
                          trailing: DropdownButton<String>(
                            value: locale.languageCode,
                            underline: const SizedBox(),
                            dropdownColor: Theme.of(context).cardColor,
                            style: AppStyles.bodyMedium.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'uz',
                                child: Text('O\'zbekcha'),
                              ),
                              DropdownMenuItem(
                                value: 'ru',
                                child: Text('Русский'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<LocalizationCubit>()
                                    .changeLocale(localeCode: value);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Bildirishnomalar',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    ProfileMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Maxfiylik',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
                AppDimens.xl.height,
                _buildSectionTitle('Boshqa'),
                AppDimens.md.height,
                _buildSettingsCard(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Buyurtmalarim',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => context.go(Routes.orders),
                    ),
                    _buildDivider(),
                    ProfileMenuItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Yordam',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => context.push(
                        Routes.getSellerChat('admin'),
                        extra: {'name': 'Admin', 'role': 'Support'},
                      ),
                    ),
                    _buildDivider(),
                    ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Chiqish',
                      titleColor: Colors.red,
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
                AppDimens.xl.height,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppStyles.h5Bold.copyWith(
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: AppDimens.borderWidth.w,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1.h,
      color: Theme.of(context).dividerColor,
    );
  }
}
