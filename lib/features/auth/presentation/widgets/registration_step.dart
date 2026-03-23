import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/validators.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class RegistrationStep extends StatefulWidget {
  const RegistrationStep({super.key});

  @override
  State<RegistrationStep> createState() => _RegistrationStepState();
}

class _RegistrationStepState extends State<RegistrationStep> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedLanguage = 'uz';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(AppDimens.lg.r),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Text(
                  context.l10n.register,
                  style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.l10n.fillProfileInfo,
                  style: AppStyles.bodyRegular.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 32.h),
                // Disabled phone number field
                TextField(
                  controller: TextEditingController(text: state.phoneNumber),
                  enabled: false,
                  style: AppStyles.h5Bold.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.phoneNumberLabel,
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
                SizedBox(height: 16.h),
                // Full Name
                TextField(
                  controller: _fullNameController,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.fullName,
                    hintText: context.l10n.fullNameExample,
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.mainBlue),
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
                SizedBox(height: 16.h),
                // Username
                TextField(
                  controller: _usernameController,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onChanged: (value) {
                    context.read<AuthBloc>().add(AuthUsernameChanged(value));
                  },
                  decoration: InputDecoration(
                    labelText: context.l10n.username,
                    hintText: context.l10n.usernameExample,
                    prefixIcon: Icon(Icons.alternate_email, color: AppColors.mainBlue),
                    suffixIcon: _buildUsernameSuffix(state),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: state.isUsernameAvailable == false
                            ? Colors.red
                            : state.isUsernameAvailable == true
                                ? Colors.green
                                : AppColors.mainBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (state.username.isNotEmpty && state.usernameValidationError != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 12.w),
                    child: Text(
                      state.usernameValidationError!,
                      style: AppStyles.bodySmall.copyWith(color: Colors.red),
                    ),
                  ),
                if (state.isUsernameAvailable == false && state.usernameValidationError == null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 12.w),
                    child: Text(
                      'Username allaqachon band',
                      style: AppStyles.bodySmall.copyWith(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16.h),
                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.password,
                    hintText: context.l10n.createPasswordHint,
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
                SizedBox(height: 16.h),
                // Language selector
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: InputDecoration(
                    labelText: context.l10n.language,
                    prefixIcon: Icon(Icons.language, color: AppColors.mainBlue),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: AppColors.mainBlue, width: 2),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'uz', child: Text(context.l10n.uzbek)),
                    DropdownMenuItem(value: 'ru', child: Text(context.l10n.russian)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                      // Optional: update locale immediately if desired, 
                      // but here it's part of registration flow
                    }
                  },
                ),
                if (state.status == AuthStatus.error && state.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Text(
                      state.errorMessage!,
                      style: AppStyles.bodySmall.copyWith(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: state.status == AuthStatus.loading ||
                            state.isCheckingUsername ||
                            state.isUsernameAvailable == false
                        ? null
                        : () {
                            final fullName = _fullNameController.text.trim();
                            final username = _usernameController.text.trim();
                            final password = _passwordController.text.trim();

                            if (fullName.isNotEmpty &&
                                username.isNotEmpty &&
                                password.isNotEmpty) {
                              // Store password in state first, then call profile submitted
                              context.read<AuthBloc>().add(AuthProfileSubmitted(
                                    fullName: fullName,
                                    username: username,
                                    password: password,
                                    language: _selectedLanguage,
                                  ));
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
                        : Text(context.l10n.register,
                            style: AppStyles.h4Bold.copyWith(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildUsernameSuffix(AuthState state) {
    if (state.isCheckingUsername) {
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state.isUsernameAvailable == true) {
      return const Icon(Icons.check_circle_outline, color: Colors.green);
    }

    if (state.isUsernameAvailable == false) {
      return const Icon(Icons.error_outline, color: Colors.red);
    }

    return null;
  }
}
