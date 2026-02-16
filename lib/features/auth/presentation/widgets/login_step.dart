import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class LoginStep extends StatefulWidget {
  const LoginStep({super.key});

  @override
  State<LoginStep> createState() => _LoginStepState();
}

class _LoginStepState extends State<LoginStep> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(AppDimens.lg.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Text(
                "Tizimga kirish",
                style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: 8.h),
              Text(
                "Parolingizni kiriting",
                style: AppStyles.bodyRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: 40.h),
              // Disabled phone number field
              TextField(
                controller: TextEditingController(text: state.phoneNumber),
                enabled: false,
                style: AppStyles.h4Bold.copyWith(
                  letterSpacing: 1.2,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                decoration: InputDecoration(
                  labelText: "Telefon raqam",
                  prefixIcon: Icon(Icons.phone_android_rounded, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 8.h),
              // Blue link to go back and change phone
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(const AuthStepChanged(AuthStep.phoneInput));
                },
                child: Text(
                  "O'zgartirish",
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.mainBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Password input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppStyles.h4Bold,
                decoration: InputDecoration(
                  labelText: "Parol",
                  hintText: "Parolingizni kiriting",
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.mainBlue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: AppColors.mainBlue, width: 2),
                  ),
                ),
              ),
              if (state.status == AuthStatus.error && state.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Text(
                    state.errorMessage!,
                    style: AppStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () {
                          final password = _passwordController.text.trim();
                          if (password.isNotEmpty) {
                            context.read<AuthBloc>().add(AuthPasswordSubmitted(password));
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
                      : Text("Kirish",
                            style: AppStyles.h4Bold.copyWith(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
