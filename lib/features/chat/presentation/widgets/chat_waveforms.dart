import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RealTimeWaveform extends StatelessWidget {
  final List<double> data;

  const RealTimeWaveform({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final displayData = data.length > 30 ? data.sublist(data.length - 30) : data;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: displayData.map((val) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: 3.w,
          height: (val * 30.h).clamp(2.h, 30.h),
          color: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }
}

class StaticWaveform extends StatelessWidget {
  final List<double> data;

  const StaticWaveform({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sampleRate = (data.length / 40).ceil();
    final sampled = <double>[];
    for (int i = 0; i < data.length; i += sampleRate) {
      sampled.add(data[i]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sampled.map((val) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: 2.w,
          height: (val * 40.h).clamp(2.h, 40.h),
          color: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }
}
