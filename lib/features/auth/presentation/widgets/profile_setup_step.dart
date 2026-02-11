import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../managers/auth_bloc.dart';
import '../managers/auth_state.dart';

class ProfileSetupStep extends StatefulWidget {
  const ProfileSetupStep({super.key});

  @override
  State<ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends State<ProfileSetupStep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _selectedLang = 'uz';
  String? _imagePath;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final sizeInBytes = await file.length();
      if (sizeInBytes > 8 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rasm hajmi 8MB dan ko'p bo'lmasligi kerak")),
          );
        }
        return;
      }
      setState(() => _imagePath = image.path);
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 3) return "Kamida 3 ta belgi bo'lishi kerak";
    if (value.length > 30) return "Ko'pi bilan 30 ta belgi bo'lishi kerak";
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) return "Harf bilan boshlanishi kerak";
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) return "Faqat harf, son va _ mumkin";
    if (value.endsWith('_')) return "Oxirida _ bo'lishi mumkin emas";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimens.lg.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              "Ma'lumotlar",
              style: AppStyles.h1Bold.copyWith(color: Theme.of(context).primaryColor),
            ),
            SizedBox(height: 8.h),
            Text(
              "Profilingizni to'ldiring",
              style: AppStyles.bodyRegular.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: 30.h),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null
                        ? Icon(Icons.person_rounded, size: 60.r, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.mainBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "To'liq ism (FullName) *",
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Ismni kiriting";
                if (value.length < 3) return "Kamida 3 ta belgi";
                if (value.length > 50) return "Maksimal 50 ta belgi";
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username (ixtiyoriy)",
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              validator: _validateUsername,
            ),
            SizedBox(height: 24.h),
            Text("Tilni tanlang", style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildLangButton("O'zbekcha", 'uz'),
                SizedBox(width: 12.w),
                _buildLangButton("Русский", 'ru'),
              ],
            ),
            SizedBox(height: 40.h),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(AuthProfileSubmitted(
                                    fullName: _nameController.text,
                                    username: _usernameController.text,
                                    profilePhotoPath: _imagePath,
                                    language: _selectedLang,
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
                        : Text("Tayyor", style: AppStyles.h4Bold.copyWith(color: Colors.white)),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, String code) {
    final isSelected = _selectedLang == code;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedLang = code),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainBlue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.mainBlue : Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.mainBlue : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
