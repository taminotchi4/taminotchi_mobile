import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../domain/entities/client_profile_entity.dart';
import '../managers/client_profile_bloc.dart';
import '../managers/client_profile_event.dart';
import '../managers/client_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final ClientProfileEntity profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  String? _selectedLanguage;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(text: widget.profile.username);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _selectedLanguage = widget.profile.language;
    _photoPath = widget.profile.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.cardRadius.r),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const AppSvgIcon(
                  assetPath: AppIcons.gallery,
                  size: AppDimens.iconLg,
                ),
                title: Text(
                  context.l10n.gallery,
                  style: AppStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  size: AppDimens.iconLg.r,
                ),
                title: Text(
                  context.l10n.camera,
                  style: AppStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    final state = context.read<ClientProfileBloc>().state;
    final username = _usernameController.text.trim();
    
    // Check if username is valid according to bloc state
    if (state.usernameValidationError != null) {
      return;
    }

    // Check availability if changed
    if (username != widget.profile.username && state.isUsernameAvailable == false) {
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      username: username,
      phone: _phoneController.text.trim(),
      language: _selectedLanguage,
      photoUrl: _photoPath,
    );

    context.read<ClientProfileBloc>().add(
          ClientProfileUpdated(updatedProfile),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.edit,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimens.lg.r),
        child: Column(
          children: [
            AppDimens.lg.height,
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : '?',
                      style: AppStyles.h1Bold.copyWith(
                        color: Colors.white,
                        fontSize: 48.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppDimens.xl.height,
            _buildTextField(
              controller: _nameController,
              label: context.l10n.fullName,
              hint: context.l10n.fullNameExample,
            ),
            AppDimens.lg.height,
            BlocBuilder<ClientProfileBloc, ClientProfileState>(
              builder: (context, state) {
                return _buildTextField(
                  controller: _usernameController,
                  label: context.l10n.username,
                  hint: context.l10n.usernameExample,
                  errorText: state.usernameValidationError,
                  suffixIcon: _buildUsernameSuffix(state),
                  onChanged: (value) {
                    context.read<ClientProfileBloc>().add(
                          ClientProfileUsernameChanged(
                              value, widget.profile.username),
                        );
                  },
                );
              },
            ),
            AppDimens.lg.height,
            _buildTextField(
              controller: _phoneController,
              label: context.l10n.phoneNumberLabel,
              hint: '+998 90 123 45 67',
              enabled: false,
            ),
            Transform.translate(
              offset: Offset(0, -4.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement phone number change flow
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'o\'zgartirish',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            AppDimens.lg.height,
            _buildLanguageSelector(),
            AppDimens.xl.height,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.buttonRadius.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.save,
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    void Function(String)? onChanged,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        AppDimens.sm.height,
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          style: AppStyles.bodyRegular.copyWith(
            color: enabled 
                ? Theme.of(context).textTheme.bodyMedium?.color
                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            suffixIcon: suffixIcon,
            hintStyle: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).hintColor,
            ),
            filled: true,
            fillColor: enabled ? Theme.of(context).cardColor : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: AppDimens.borderWidth.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Theme.of(context).primaryColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppDimens.md.h,
              horizontal: AppDimens.md.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildUsernameSuffix(ClientProfileState state) {
    if (state.isCheckingUsername) {
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state.isUsernameAvailable == true &&
        _usernameController.text.trim() != widget.profile.username) {
      return const Icon(Icons.check_circle_outline, color: Colors.green);
    }

    if (state.isUsernameAvailable == false) {
      return const Icon(Icons.error_outline, color: Colors.red);
    }

    return null;
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.language,
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        AppDimens.sm.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: AppDimens.borderWidth.w,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: AppStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              items: [
                DropdownMenuItem(value: 'uz', child: Text(context.l10n.uzbek)),
                DropdownMenuItem(value: 'ru', child: Text(context.l10n.russian)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
