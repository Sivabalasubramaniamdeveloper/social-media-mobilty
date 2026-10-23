import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mineai/core/base/abstract/base_form.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/features/profile/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _countryController;
  String _selectedGender = 'prefer_not_to_say';
  String _selectedLanguage = 'en';
  File? _avatarFile;
  String? _avatarUrl;
  bool _isSaving = false;
  bool _isPhoneLocked = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<UserProfileCubit>().state;
    UserProfileModel? profile;
    if (profileState is UserProfileLoaded) {
      profile = profileState.profile;
    }

    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _dobController = TextEditingController(text: profile?.dob ?? '2000-01-01');
    _countryController = TextEditingController(
      text: profile?.countryCode ?? 'IN',
    );
    _selectedGender = profile?.gender ?? 'prefer_not_to_say';
    _selectedLanguage = profile?.language ?? 'en';
    _avatarUrl = profile?.avatarUrl;
    _isPhoneLocked = profile?.phone != null && profile!.phone!.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _avatarFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Could not select photo: $e');
      }
    }
  }

  Future<void> _handleSave([BuildContext? _]) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phoneText = _phoneController.text.trim();
    if (!_isPhoneLocked && phoneText.isNotEmpty) {
      final indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');
      if (!indianPhoneRegex.hasMatch(phoneText)) {
        SnackBarHelper.showError(
          context,
          'Phone number must be a valid 10-digit Indian number (starting with 6-9)',
        );
        return;
      }
    }

    final cubit = context.read<UserProfileCubit>();
    setState(() => _isSaving = true);

    if (_avatarFile != null) {
      try {
        final bytes = await _avatarFile!.readAsBytes();
        final ext = _avatarFile!.path.split('.').last.toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        final userId = await UserHelper.getCurrentUserId();
        final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        bool uploaded = false;
        try {
          await Supabase.instance.client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: true),
          );
          _avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
          uploaded = true;
        } catch (_) {}

        if (!uploaded) {
          // Pass base64 to backend which saves to bucket using service role and returns URL
          _avatarUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        }
      } catch (e) {
        debugPrint('[EditProfile] Failed to process avatar: $e');
      }
    }

    final success = await cubit.updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      countryCode: _countryController.text.trim(),
      language: _selectedLanguage,
      avatarUrl: _avatarUrl,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      SnackBarHelper.showSuccess(
        context,
        AppStrings.profileUpdatedSuccessfully,
      );
      if (mounted) context.pop();
    } else {
      SnackBarHelper.showError(context, AppStrings.failedToUpdateProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _EditProfileFormView(
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      dobController: _dobController,
      countryController: _countryController,
      selectedGender: _selectedGender,
      selectedLanguage: _selectedLanguage,
      avatarFile: _avatarFile,
      avatarUrl: _avatarUrl,
      onPickAvatar: _pickAvatar,
      isSaving: _isSaving,
      isPhoneLocked: _isPhoneLocked,
      onGenderChanged: (val) => setState(() => _selectedGender = val),
      onLanguageChanged: (val) => setState(() => _selectedLanguage = val),
      onSubmitCallback: _handleSave,
    );
  }
}

class _EditProfileFormView extends BaseFormScreen {
  final GlobalKey<FormState> _key;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController countryController;
  final String selectedGender;
  final String selectedLanguage;
  final File? avatarFile;
  final String? avatarUrl;
  final VoidCallback onPickAvatar;
  final bool isSaving;
  final bool isPhoneLocked;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onLanguageChanged;
  final void Function(BuildContext) onSubmitCallback;

  const _EditProfileFormView({
    required GlobalKey<FormState> formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.dobController,
    required this.countryController,
    required this.selectedGender,
    required this.selectedLanguage,
    required this.avatarFile,
    required this.avatarUrl,
    required this.onPickAvatar,
    required this.isSaving,
    required this.isPhoneLocked,
    required this.onGenderChanged,
    required this.onLanguageChanged,
    required this.onSubmitCallback,
  }) : _key = formKey;

  @override
  GlobalKey<FormState> get formKey => _key;

  @override
  String get title => AppStrings.editProfile;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  EdgeInsets get formPadding => EdgeInsets.zero;

  @override
  bool get showSubmitButton => false;

  @override
  void onSubmit(BuildContext context) => onSubmitCallback(context);

  @override
  List<Widget> buildFormFields(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: scheme.onSurface,
                    size: 20,
                  ),
                ),
                Text(
                  AppStrings.editProfile,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Picture Circle with Upload
            Center(
              child: InkWell(
                onTap: onPickAvatar,
                borderRadius: BorderRadius.circular(48),
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.primary, width: 2.5),
                        image: DecorationImage(
                          image: avatarFile != null
                              ? FileImage(avatarFile!) as ImageProvider
                              : NetworkImage(
                                  avatarUrl != null && avatarUrl!.isNotEmpty
                                      ? avatarUrl!
                                      : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Full Name Input
            AppTextField(
              controller: nameController,
              label: AppStrings.fullName,
              prefixIcon: Icons.person_outline_rounded,
              isRequired: true,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 18),

            // Mobile Number Input (Indian 10-digit, immutable once entered)
            AppTextField(
              controller: phoneController,
              label: 'Mobile Number (India)',
              hint: isPhoneLocked ? phoneController.text : '10-digit Indian number (e.g. 9876543210)',
              prefixIcon: Icons.phone_outlined,
              suffixIcon: isPhoneLocked ? const Icon(Icons.lock_outline_rounded, size: 18) : null,
              enabled: !isPhoneLocked,
              readOnly: isPhoneLocked,
              keyboardType: TextInputType.phone,
              style: AppTextFieldStyle.glass,
              validator: (val) {
                if (isPhoneLocked) return null;
                if (val == null || val.trim().isEmpty) return null;
                final regex = RegExp(r'^[6-9]\d{9}$');
                if (!regex.hasMatch(val.trim())) {
                  return 'Enter valid 10-digit Indian number (starts 6-9)';
                }
                return null;
              },
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                isPhoneLocked
                    ? 'Registered mobile number cannot be edited once saved.'
                    : '10-digit Indian mobile number. Once saved, it cannot be changed.',
                style: TextStyle(
                  fontSize: 11,
                  color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Email Input (Non-editable / locked)
            AppTextField.email(
              controller: emailController,
              enabled: false,
              readOnly: true,
              suffixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Registered account email cannot be edited.',
                style: TextStyle(
                  fontSize: 11,
                  color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Date of Birth Input
            AppTextField(
              controller: dobController,
              label: AppStrings.dateOfBirth,
              prefixIcon: Icons.calendar_today_rounded,
              isRequired: true,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 18),

            // Country Code Input
            AppTextField(
              controller: countryController,
              label: AppStrings.countryCode,
              prefixIcon: Icons.flag_outlined,
              textCapitalization: TextCapitalization.characters,
              isRequired: true,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 18),

            // Gender Selector
            Text(
              AppStrings.gender,
              style: TextStyle(
                fontSize: 13,
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isLight
                    ? scheme.surfaceContainerHighest
                    : const Color(0xFF1E1B38).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight
                      ? scheme.primary.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGender,
                  isExpanded: true,
                  dropdownColor: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF1B192E),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                  style: TextStyle(color: scheme.onSurface, fontSize: 14),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(AppStrings.male),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(AppStrings.female),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(AppStrings.other),
                    ),
                    DropdownMenuItem(
                      value: 'prefer_not_to_say',
                      child: Text(AppStrings.preferNotToSay),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) onGenderChanged(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Language Selector
            Text(
              AppStrings.language,
              style: TextStyle(
                fontSize: 13,
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isLight
                    ? scheme.surfaceContainerHighest
                    : const Color(0xFF1E1B38).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight
                      ? scheme.primary.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  isExpanded: true,
                  dropdownColor: isLight
                      ? scheme.surfaceContainerHighest
                      : const Color(0xFF1B192E),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                  style: TextStyle(color: scheme.onSurface, fontSize: 14),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(AppStrings.englishLanguageCode),
                    ),
                    DropdownMenuItem(
                      value: 'ta',
                      child: Text(AppStrings.tamilLanguageCode),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) onLanguageChanged(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isSaving ? null : () => onSubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : Text(
                          AppStrings.saveChanges,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ];
  }
}
