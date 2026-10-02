import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/base/abstract/base_form.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/features/profile/models/user_profile_model.dart';
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
  late TextEditingController _dobController;
  late TextEditingController _countryController;
  String _selectedGender = 'prefer_not_to_say';
  String _selectedLanguage = 'en';
  bool _isSaving = false;

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
    _dobController = TextEditingController(text: profile?.dob ?? '2000-01-01');
    _countryController = TextEditingController(
      text: profile?.countryCode ?? 'IN',
    );
    _selectedGender = profile?.gender ?? 'prefer_not_to_say';
    _selectedLanguage = profile?.language ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final success = await context.read<UserProfileCubit>().updateProfile(
      fullName: _nameController.text,
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      countryCode: _countryController.text.trim(),
      language: _selectedLanguage,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        SnackBarHelper.showSuccess(
          context,
          AppStrings.profileUpdatedSuccessfully,
        );
        context.pop();
      } else {
        SnackBarHelper.showError(context, AppStrings.failedToUpdateProfile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _EditProfileFormView(
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      dobController: _dobController,
      countryController: _countryController,
      selectedGender: _selectedGender,
      selectedLanguage: _selectedLanguage,
      isSaving: _isSaving,
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
  final TextEditingController dobController;
  final TextEditingController countryController;
  final String selectedGender;
  final String selectedLanguage;
  final bool isSaving;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onLanguageChanged;
  final void Function(BuildContext) onSubmitCallback;

  const _EditProfileFormView({
    required GlobalKey<FormState> formKey,
    required this.nameController,
    required this.emailController,
    required this.dobController,
    required this.countryController,
    required this.selectedGender,
    required this.selectedLanguage,
    required this.isSaving,
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                ),
                Text(
                  AppStrings.editProfile,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Picture Circle
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple,
                        width: 2.5,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ],
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

            // Email Input
            AppTextField.email(
              controller: emailController,
              style: AppTextFieldStyle.glass,
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
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGender,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B192E),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                  ),
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
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B192E),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English (en)')),
                    DropdownMenuItem(value: 'ta', child: Text('தமிழ் (ta)')),
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.accentBlue],
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
                            color: AppColors.whiteColor,
                            strokeWidth: 2.2,
                          ),
                        )
                      : Text(
                          AppStrings.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
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
