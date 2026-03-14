import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class PhoneInputStep extends StatefulWidget {
  const PhoneInputStep({super.key});

  @override
  State<PhoneInputStep> createState() => _PhoneInputStepState();
}

class _PhoneInputStepState extends State<PhoneInputStep> {
  final TextEditingController _controller = TextEditingController(text: '+998 ');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppDimens.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Text(
            "Xush kelibsiz!",
            style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tizimga kirish uchun telefon raqamingizni kiriting",
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 40.h),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.phone,
            style: AppStyles.h4Bold.copyWith(letterSpacing: 1.2),
            decoration: InputDecoration(
              labelText: "Telefon raqam",
              hintText: "+998 90 123 45 67",
              prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.mainBlue),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.mainBlue, width: 2),
              ),
            ),
            onChanged: (value) {
              if (!value.startsWith('+998 ')) {
                _controller.text = '+998 ';
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
                return;
              }
              
              String digits = value.substring(5).replaceAll(' ', '');
              if (digits.length > 9) {
                digits = digits.substring(0, 9);
              }
              
              String formatted = '+998 ';
              if (digits.length > 0) {
                formatted += digits.substring(0, digits.length >= 2 ? 2 : digits.length);
              }
              if (digits.length > 2) {
                formatted += ' ' + digits.substring(2, digits.length >= 5 ? 5 : digits.length);
              }
              if (digits.length > 5) {
                formatted += ' ' + digits.substring(5);
              }

              if (_controller.text != formatted) {
                _controller.text = formatted;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              }
            },
          ),
          const Spacer(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () {
                          final phone = _controller.text.trim();
                          if (phone.length > 9) {
                            context.read<AuthBloc>().add(AuthPhoneNumberSubmitted(phone));
                          }
                        },
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
                      : Text("Davom etish", 
                            style: AppStyles.h4Bold.copyWith(color: Colors.white)),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
