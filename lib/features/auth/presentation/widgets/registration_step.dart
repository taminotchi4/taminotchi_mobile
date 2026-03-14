import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
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
                  "Ro'yxatdan o'tish",
                  style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Ma'lumotlaringizni to'ldiring",
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
                SizedBox(height: 16.h),
                // Full Name
                TextField(
                  controller: _fullNameController,
                  style: AppStyles.h5Bold,
                  decoration: InputDecoration(
                    labelText: "To'liq ism",
                    hintText: "Isroilov Abdulloh",
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
                  style: AppStyles.h5Bold,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "ali",
                    prefixIcon: Icon(Icons.alternate_email, color: AppColors.mainBlue),
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
                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppStyles.h5Bold,
                  decoration: InputDecoration(
                    labelText: "Parol",
                    hintText: "Parol yarating...",
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
                    labelText: "Til",
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
                  items: const [
                    DropdownMenuItem(value: 'uz', child: Text('O\'zbekcha')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                      });
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
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () {
                            final fullName = _fullNameController.text.trim();
                            final username = _usernameController.text.trim();
                            final password = _passwordController.text.trim();

                            if (fullName.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
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
                        : Text("Ro'yxatdan o'tish",
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
}
