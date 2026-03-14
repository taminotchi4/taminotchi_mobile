import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';

class ProductDescriptionSection extends StatelessWidget {
  final String description;

  const ProductDescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final lines = description.split('\n');
    final hasMoreThan5Lines = lines.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDimens.lg.height,
        Text(
          'Tavsif',
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        AppDimens.xs.height,
        Text(
          description,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
        ),
        if (hasMoreThan5Lines) ...[
          AppDimens.xs.height,
          InkWell(
            onTap: () => _showFullDescription(context),
            child: Text(
              'Mahsulot haqida',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.cardRadius.r),
          ),
        ),
        child: Column(
          children: [
            AppDimens.md.height,
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppDimens.lg.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.r),
              child: Text(
                'Mahsulot haqida',
                style: AppStyles.h4Bold.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            AppDimens.md.height,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.r),
                child: Text(
                  description,
                  style: AppStyles.bodyRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            AppDimens.lg.height,
          ],
        ),
      ),
    );
  }
}
