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
          context.l10n.logout,
          style: AppStyles.h4Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        content: Text(
          context.l10n.logoutConfirm,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: AppStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.go(Routes.auth);
            },
            child: Text(
              context.l10n.logout,
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        ),
        title: Text(
          context.l10n.deleteAccountTitle,
          style: AppStyles.h4Bold.copyWith(
            color: Colors.red,
          ),
        ),
        content: Text(
          context.l10n.deleteAccountConfirm,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: AppStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ClientProfileBloc>().add(
                    const ClientProfileDeleteAccountRequested(),
                  );
            },
            child: Text(
              context.l10n.deleteAccount,
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
      appBar: CommonAppBar(title: context.l10n.profile),
      body: BlocListener<ClientProfileBloc, ClientProfileState>(
        listener: (context, state) {
          if (state.isLoggedOut) {
            context.go(Routes.auth);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: BlocBuilder<ClientProfileBloc, ClientProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.profile == null) {
              return Center(
                child: Text(
                  context.l10n.noProfileData,
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ClientProfileBloc>().add(
                      const ClientProfileStarted(),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppDimens.lg.r),
                child: Column(
                  children: [
                    ProfileHeader(profile: state.profile!),
                    AppDimens.xl.height,
                    _buildSectionTitle(context.l10n.settings),
                    AppDimens.md.height,
                    _buildSettingsCard(
                      children: [
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            return ProfileMenuItem(
                              icon: Icons.brightness_6_outlined,
                              title: context.l10n.nightMode,
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
                              title: context.l10n.language,
                              trailing: DropdownButton<String>(
                                value: locale.languageCode,
                                underline: const SizedBox(),
                                dropdownColor: Theme.of(context).cardColor,
                                style: AppStyles.bodyMedium.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'uz',
                                    child: Text(context.l10n.uzbek),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ru',
                                    child: Text(context.l10n.russian),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    context
                                        .read<LocalizationCubit>()
                                        .changeLocale(localeCode: value);

                                    final profileState = context
                                        .read<ClientProfileBloc>()
                                        .state;
                                    if (profileState.profile != null) {
                                      context.read<ClientProfileBloc>().add(
                                            ClientProfileUpdated(
                                              profileState.profile!.copyWith(
                                                language: value,
                                              ),
                                            ),
                                          );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          title: context.l10n.notifications,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () => context.push(Routes.notifications),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: context.l10n.privacy,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tez kunda..')),
                            );
                          },
                        ),
                      ],
                    ),
                    AppDimens.xl.height,
                    _buildSectionTitle(context.l10n.other),
                    AppDimens.md.height,
                    _buildSettingsCard(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: context.l10n.myOrders,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () => context.go(Routes.orders),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.support_agent_rounded,
                          title: context.l10n.help,
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
                          icon: Icons.help_outline_rounded,
                          title: context.l10n.faq,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () {
                            // FAQ functionality could be a dialog or a new page
                            _showFAQDialog(context);
                          },
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'Sotuvchi bo\'lish',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Yangi',
                                  style: AppStyles.bodySmall.copyWith(
                                    fontSize: 10.sp,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ],
                          ),
                          onTap: () => context.push(Routes.becomeSeller),
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: context.l10n.logout,
                          titleColor: Colors.amber[800],
                          onTap: _showLogoutDialog,
                        ),
                        _buildDivider(),
                        ProfileMenuItem(
                          icon: Icons.delete_forever_rounded,
                          title: context.l10n.deleteAccountTitle,
                          titleColor: Colors.red,
                          onTap: _showDeleteAccountDialog,
                        ),
                      ],
                    ),
                    AppDimens.xl.height,
                  ],
                ),
              ),
            );
          },
        ),
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

  void _showFAQDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Text(
                context.l10n.faq,
                style: AppStyles.h4Bold,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _buildFAQItem(
                    context,
                    context.l10n.faqQ1,
                    context.l10n.faqA1,
                  ),
                  _buildFAQItem(
                    context,
                    context.l10n.faqQ2,
                    context.l10n.faqA2,
                  ),
                  _buildFAQItem(
                    context,
                    context.l10n.faqQ3,
                    context.l10n.faqA3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      expandedAlignment: Alignment.centerLeft,
      children: [
        Text(
          answer,
          style: AppStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
