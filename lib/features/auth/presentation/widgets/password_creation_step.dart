import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class PasswordCreationStep extends StatefulWidget {
  const PasswordCreationStep({super.key});

  @override
  State<PasswordCreationStep> createState() => _PasswordCreationStepState();
}

class _PasswordCreationStepState extends State<PasswordCreationStep> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppDimens.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(const AuthStepChanged(AuthStep.otpVerification)),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          SizedBox(height: 20.h),
          Text(
            "Parol yarating",
            style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
          ),
          SizedBox(height: 8.h),
          Text(
            "Akkauntingizni himoya qilish uchun kuchli parol tanlang",
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 40.h),
          TextField(
            controller: _passController,
            obscureText: _obscurePass,
            style: AppStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: "Yangi parol",
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            style: AppStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: "Parolni tasdiqlang",
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                final pass = _passController.text;
                final confirm = _confirmController.text;
                if (pass.length >= 6 && pass == confirm) {
                  context.read<AuthBloc>().add(AuthPasswordSubmitted(pass));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Parollar mos kelmadi yoki juda qisqa")),
                  );
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
              child: Text("Siz haqingizda", 
                style: AppStyles.h4Bold.copyWith(color: Colors.white)),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
