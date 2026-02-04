import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../managers/followers_bloc.dart';
import '../managers/followers_event.dart';
import '../managers/followers_state.dart';

class FollowersPage extends StatefulWidget {
  final String sellerId;

  const FollowersPage({super.key, required this.sellerId});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  void initState() {
    super.initState();
    context.read<FollowersBloc>().add(FollowersStarted(widget.sellerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Followers',
        leading: AppBackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimens.lg.r),
            child: TextField(
              onChanged: (value) =>
                  context.read<FollowersBloc>().add(FollowersSearchChanged(value)),
              decoration: InputDecoration(
                hintText: 'Qidirish...',
                hintStyle: AppStyles.bodyRegular.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: AppDimens.borderWidth.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: AppDimens.borderWidth.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: AppDimens.borderWidth.w,
                  ),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  child: AppSvgIcon(
                    assetPath: AppIcons.search,
                    size: AppDimens.iconMd,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppDimens.sm.h,
                  horizontal: AppDimens.md.w,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<FollowersBloc, FollowersState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Foydalanuvchilar topilmadi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
                  itemCount: state.filtered.length,
                  separatorBuilder: (context, _) => Divider(
                    height: AppDimens.lg.h,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final follower = state.filtered[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimens.circleRadius.r),
                          child: Container(
                            width: AppDimens.avatarSm.w,
                            height: AppDimens.avatarSm.w,
                            color: Theme.of(context).dividerColor,
                            child: AppSvgIcon(
                              assetPath: follower.avatarPath,
                              size: AppDimens.iconSm,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                        AppDimens.sm.width,
                        Expanded(
                          child: Text(
                            follower.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodyRegular.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
