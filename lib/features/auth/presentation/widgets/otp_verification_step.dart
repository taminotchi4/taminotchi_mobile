import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class OtpVerificationStep extends StatefulWidget {
  const OtpVerificationStep({super.key});

  @override
  State<OtpVerificationStep> createState() => _OtpVerificationStepState();
}

class _OtpVerificationStepState extends State<OtpVerificationStep> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      context.read<AuthBloc>().add(AuthOtpSubmitted(_otpCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                FocusScope.of(context).unfocus();
              }
              return false;
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimens.lg.r),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.read<AuthBloc>().add(const AuthStepChanged(AuthStep.phoneInput)),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Tasdiqlash",
                      style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "${state.phoneNumber} raqamiga yuborilgan 6 xonali kodni kiriting",
                      style: AppStyles.bodyRegular.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48.w,
                          height: 56.h,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppStyles.h4Bold.copyWith(fontSize: 18.sp),
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: AppColors.mainBlue, width: 2),
                              ),
                            ),
                            onChanged: (value) => _onChanged(value, index),
                          ),
                        );
                      }),
                    ),
                    if (state.errorMessage != null) ...[
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage!,
                        style: AppStyles.bodySmall.copyWith(color: Colors.red),
                      ),
                    ],
                    SizedBox(height: 40.h),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _formatTime(state.otpTimer),
                            style: AppStyles.h3Bold.copyWith(
                              color: state.otpTimer == 0 ? Colors.red : AppColors.mainBlue,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: state.otpTimer == 0
                                ? () => context.read<AuthBloc>().add(AuthResendOtpRequested())
                                : null,
                            child: Text(
                              "Kodni qayta yuborish",
                              style: AppStyles.bodyMedium.copyWith(
                                color: state.otpTimer == 0 ? AppColors.mainBlue : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: state.status == AuthStatus.loading || _otpCode.length < 6
                            ? null
                            : () => context.read<AuthBloc>().add(AuthOtpSubmitted(_otpCode)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: state.status == AuthStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Tasdiqlash", 
                                  style: AppStyles.h4Bold.copyWith(color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
