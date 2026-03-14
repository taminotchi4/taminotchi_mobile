import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';

extension SizeExtension on num {
  Widget get height => SizedBox(height: toDouble().h);

  Widget get width => SizedBox(width: toDouble().w);
}

extension PaddingExtension on Widget {
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value.r),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.h),
    child: this,
  );

  Widget paddingOnly({double left = 0, double right = 0, double top = 0, double bottom = 0}) => Padding(
    padding: EdgeInsets.only(left: left.w, right: right.w, top: top.h, bottom: bottom.h),
    child: this,
  );
}

extension L10nExtension on BuildContext {
  MyLocalizations get l10n => MyLocalizations.of(this)!;
}
