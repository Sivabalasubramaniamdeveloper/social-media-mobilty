import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/subscription/cubit/subscription_cubit.dart';
import 'package:mineai/features/subscription/cubit/subscription_state.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../cubit/vault_cubit.dart';
import '../cubit/vault_state.dart';
import '../models/vault_item_model.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _selectedFilter = 'all';

  List<Map<String, dynamic>> get _tabs => [
    {
      'id': 'all',
      'label': AppStrings.all,
      'icon': Icons.folder_special_rounded,
    },
    {
      'id': 'password',
      'label': AppStrings.passwords,
      'icon': Icons.lock_outline_rounded,
    },
    {
      'id': 'photo',
      'label': AppStrings.photos,
      'icon': Icons.photo_library_outlined,
    },
    {
      'id': 'document',
      'label': AppStrings.documents,
      'icon': Icons.description_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadVault();
  }

  PlanTier _getCurrentTier() {
    final subState = context.read<SubscriptionCubit>().state;
    if (subState is SubscriptionLoaded) {
      return subState.plan.tier;
    }
    return PlanTier.basic;
  }

  void _loadVault() {
    context.read<VaultCubit>().loadVault(
      filter: _selectedFilter,
      tier: _getCurrentTier(),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarHelper.showSuccess(context, '$label copied to clipboard');
  }

  void _openFile(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) {
        SnackBarHelper.showError(null, 'File no longer exists on device');
        return;
      }
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        SnackBarHelper.showWarning(
          null,
          'Could not open file: ${result.message}',
        );
      }
    } catch (e) {
      SnackBarHelper.showError(null, 'Failed to open file: $e');
    }
  }

  void _showAddPasswordDialog(PlanTier tier) {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final websiteController = TextEditingController();
    final notesController = TextEditingController();
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight ? scheme.surface : const Color(0xFF1B192E),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Store New Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Account / Service Title *',
                          hintText: 'e.g. Google, GitHub, Netflix',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
                          hintText: 'user@example.com',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                            ),
                            onPressed: () => setModalState(
                              () => obscurePassword = !obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: websiteController,
                        decoration: InputDecoration(
                          labelText: 'Website / App URL (Optional)',
                          hintText: 'https://example.com',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Private Notes (Optional)',
                          filled: true,
                          fillColor: isLight
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFF262344),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final pass = passwordController.text.trim();
                            if (title.isEmpty || pass.isEmpty) {
                              SnackBarHelper.showWarning(
                                context,
                                'Please provide both Title and Password',
                              );
                              return;
                            }

                            final userId = await UserHelper.getCurrentUserId();
                            final item = VaultItemModel(
                              userId: userId,
                              type: 'password',
                              title: title,
                              content: pass,
                              accountUsername: usernameController.text.trim(),
                              websiteUrl: websiteController.text.trim(),
                              notes: notesController.text.trim(),
                              createdAt: DateTime.now(),
                            );

                            if (modalCtx.mounted) Navigator.pop(modalCtx);
                            if (!mounted) return;
                            final saved = await context
                                .read<VaultCubit>()
                                .saveItem(
                                  item,
                                  tier: tier,
                                  currentFilter: _selectedFilter,
                                );
                            if (saved) {
                              SnackBarHelper.showSuccess(
                                null,
                                'Password stored in private vault!',
                              );
                            }
                          },
                          child: const Text(
                            'Save to Private Vault',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndSavePhoto(PlanTier tier) async {
    if (tier == PlanTier.basic) {
      _showUpgradePlanModal(
        'Private Photo Storage is available in Pro (10 photos) and Premium (20 photos).',
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${appDir.path}/vault_photos');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final fileName = 'vault_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(
        picked.path,
      ).copy('${vaultDir.path}/$fileName');
      final size = await savedFile.length();

      final userId = await UserHelper.getCurrentUserId();
      final item = VaultItemModel(
        userId: userId,
        type: 'photo',
        title: 'Private Photo ${DateFormat('MMM dd').format(DateTime.now())}',
        content: savedFile.path,
        fileName: fileName,
        fileSize: size,
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      final success = await context.read<VaultCubit>().saveItem(
        item,
        tier: tier,
        currentFilter: _selectedFilter,
      );

      if (success) {
        SnackBarHelper.showSuccess(null, AppStrings.privatePhotoSaved);
      }
    } catch (e) {
      SnackBarHelper.showError(null, 'Failed to save photo: $e');
    }
  }

  Future<void> _pickAndSaveDocument(PlanTier tier) async {
    if (tier == PlanTier.basic) {
      _showUpgradePlanModal(
        'Private Document Storage is available in Pro (10 docs) and Premium (30 docs).',
      );
      return;
    }

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'csv'],
      );
      if (files.isEmpty) return;

      final file = files.first;
      if (file.path == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${appDir.path}/vault_docs');
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final fileName = file.name;
      final savedFile = await File(
        file.path!,
      ).copy('${vaultDir.path}/$fileName');

      final fileSize = await savedFile.length();
      final userId = await UserHelper.getCurrentUserId();
      final item = VaultItemModel(
        userId: userId,
        type: 'document',
        title: file.name,
        content: savedFile.path,
        fileName: file.name,
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      final success = await context.read<VaultCubit>().saveItem(
        item,
        tier: tier,
        currentFilter: _selectedFilter,
      );

      if (success) {
        SnackBarHelper.showSuccess(null, AppStrings.documentStoredVault);
      }
    } catch (e) {
      SnackBarHelper.showError(null, 'Failed to save document: $e');
    }
  }

  void _showUpgradePlanModal(String reason) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return AlertDialog(
          backgroundColor: isLight ? scheme.surface : const Color(0xFF1E1B38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Pro Feature Locked',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            '$reason\n\nUpgrade today to unlock confidential photos and documents storage with end-to-end security.',
            style: TextStyle(
              fontSize: 13,
              color: isLight
                  ? AppColors.lightSecondaryOnSurface
                  : AppColors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.push(RouteNames.subscription);
              },
              child: const Text(
                'View Plans',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemChoiceSheet(PlanTier tier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isLight = theme.brightness == Brightness.light;

        return Container(
          decoration: BoxDecoration(
            color: isLight ? scheme.surface : const Color(0xFF1B192E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add to Private Vault',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.password_rounded,
                    color: Colors.blueAccent,
                  ),
                ),
                title: Text(
                  'Account / Password',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Save passwords, credentials & notes (Free on all plans)',
                  style: TextStyle(
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddPasswordDialog(tier);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.purpleAccent,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'Private Photo',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTierBadge(tier, 'photo'),
                  ],
                ),
                subtitle: Text(
                  'Confidential gallery items (Pro: 10, Premium: 20)',
                  style: TextStyle(
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSavePhoto(tier);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.amberAccent,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      'Private Document',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTierBadge(tier, 'document'),
                  ],
                ),
                subtitle: Text(
                  'PDFs, IDs, certificates (Pro: 10, Premium: 30)',
                  style: TextStyle(
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveDocument(tier);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierBadge(PlanTier tier, String type) {
    if (tier == PlanTier.basic) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'PRO',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'ACTIVE',
        style: TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final tier = _getCurrentTier();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppScreenHeader(
                  title: AppStrings.secureVault,
                  centerTitle: true,
                  onBack: () => context.pop(),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.amber,
                    ),
                    tooltip: 'Subscription & Quotas',
                    onPressed: () => context.push(RouteNames.subscription),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final isSelected = _selectedFilter == tab['id'];

                    return ChoiceChip(
                      avatar: Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : scheme.primary,
                      ),
                      label: Text(tab['label'] as String),
                      selected: isSelected,
                      selectedColor: scheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : scheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: isLight
                          ? scheme.surfaceContainerHighest
                          : const Color(0xFF1E1B38),
                      side: BorderSide(
                        color: isSelected
                            ? scheme.primary
                            : (isLight ? Colors.black12 : Colors.white10),
                      ),
                      onSelected: (_) {
                        setState(() => _selectedFilter = tab['id'] as String);
                        _loadVault();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: BlocConsumer<VaultCubit, VaultState>(
                  listener: (context, state) {
                    if (state is VaultError) {
                      SnackBarHelper.showError(context, state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state is VaultLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: scheme.primary),
                      );
                    }

                    List<VaultItemModel> items = [];
                    int photos = 0;
                    int maxPhotos = 0;
                    int docs = 0;
                    int maxDocs = 0;

                    if (state is VaultLoaded) {
                      items = state.items;
                      photos = state.photoCount;
                      maxPhotos = state.maxPhotos;
                      docs = state.documentCount;
                      maxDocs = state.maxDocuments;
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadVault(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        children: [
                          // Quota Banner Card
                          _buildQuotaBanner(
                            scheme,
                            isLight,
                            tier,
                            photos,
                            maxPhotos,
                            docs,
                            maxDocs,
                          ),
                          const SizedBox(height: 16),

                          if (items.isEmpty)
                            _buildEmptyState(scheme, isLight)
                          else
                            ...items.map(
                              (item) =>
                                  _buildVaultTile(item, scheme, isLight, tier),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: scheme.primary,
        onPressed: () => _showAddItemChoiceSheet(tier),
        icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        label: const Text(
          'Store Secret',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuotaBanner(
    ColorScheme scheme,
    bool isLight,
    PlanTier tier,
    int photos,
    int maxPhotos,
    int docs,
    int maxDocs,
  ) {
    final tierTitle = tier == PlanTier.premium
        ? 'Premium Plan'
        : tier == PlanTier.pro
        ? 'Pro Plan'
        : 'Basic (Free) Plan';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Private Vault Security ($tierTitle)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tier == PlanTier.basic ? 'PASSWORDS ONLY' : 'PRO VAULT',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMiniQuotaChip(
                icon: Icons.lock_outline_rounded,
                label: 'Passwords',
                value: 'Unlimited',
                isAllowed: true,
              ),
              const SizedBox(width: 8),
              _buildMiniQuotaChip(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                value: tier == PlanTier.basic
                    ? 'Locked (Pro)'
                    : '$photos / $maxPhotos',
                isAllowed: tier != PlanTier.basic,
              ),
              const SizedBox(width: 8),
              _buildMiniQuotaChip(
                icon: Icons.description_outlined,
                label: 'Docs',
                value: tier == PlanTier.basic
                    ? 'Locked (Pro)'
                    : '$docs / $maxDocs',
                isAllowed: tier != PlanTier.basic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniQuotaChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isAllowed,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isAllowed
              ? Colors.black.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAllowed
                ? Colors.white10
                : Colors.red.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isAllowed ? Colors.cyanAccent : Colors.redAccent,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAllowed ? Colors.white : Colors.redAccent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 52,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Vault is Empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep your passwords, confidential documents, and private photos safely stored and retrieved anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isLight
                  ? AppColors.lightSecondaryOnSurface
                  : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultTile(
    VaultItemModel item,
    ColorScheme scheme,
    bool isLight,
    PlanTier tier,
  ) {
    final dateStr = DateFormat('MMM dd, yyyy').format(item.createdAt);

    if (item.type == 'password') {
      return _buildPasswordTile(item, scheme, isLight, tier);
    } else if (item.type == 'photo') {
      return _buildPhotoTile(item, scheme, isLight, tier, dateStr);
    } else {
      return _buildDocumentTile(item, scheme, isLight, tier, dateStr);
    }
  }

  Widget _buildPasswordTile(
    VaultItemModel item,
    ColorScheme scheme,
    bool isLight,
    PlanTier tier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.key_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (item.accountUsername != null &&
                        item.accountUsername!.isNotEmpty)
                      Text(
                        item.accountUsername!,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'Copy Password',
                onPressed: () => _copyToClipboard(item.content, 'Password'),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                  size: 18,
                ),
                tooltip: 'Delete',
                onPressed: () => _deleteVaultItem(item, tier),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Password: ••••••••••••',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPasswordPlainDialog(item),
                  child: const Text(
                    'REVEAL',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordPlainDialog(VaultItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B38),
        title: Text(item.title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.accountUsername != null &&
                item.accountUsername!.isNotEmpty) ...[
              Text(
                'Account: ${item.accountUsername}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Password:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            SelectableText(
              item.content,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes: ${item.notes}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.content));
              Navigator.pop(ctx);
              SnackBarHelper.showSuccess(context, AppStrings.passwordCopied);
            },
            child: const Text(
              'Copy Password',
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(
    VaultItemModel item,
    ColorScheme scheme,
    bool isLight,
    PlanTier tier,
    String dateStr,
  ) {
    final file = File(item.content);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.black26,
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : const Icon(Icons.broken_image_rounded, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded, size: 20),
            tooltip: 'View Photo',
            onPressed: () => _viewPhotoFullScreen(item),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: scheme.error,
              size: 18,
            ),
            onPressed: () => _deleteVaultItem(item, tier),
          ),
        ],
      ),
    );
  }

  void _viewPhotoFullScreen(VaultItemModel item) {
    final file = File(item.content);
    if (!file.existsSync()) {
      SnackBarHelper.showError(context, AppStrings.imageMissingVault);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.file(file))),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton.small(
                backgroundColor: Colors.purpleAccent,
                onPressed: () => SharePlus.instance.share(
                  ShareParams(files: [XFile(file.path)]),
                ),
                child: const Icon(Icons.share_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(
    VaultItemModel item,
    ColorScheme scheme,
    bool isLight,
    PlanTier tier,
    String dateStr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight
            ? scheme.surfaceContainerHighest
            : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLight ? Colors.black12 : Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.amberAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight
                        ? AppColors.lightSecondaryOnSurface
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            tooltip: 'Open Document',
            onPressed: () => _openFile(item.content),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: scheme.error,
              size: 18,
            ),
            onPressed: () => _deleteVaultItem(item, tier),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVaultItem(VaultItemModel item, PlanTier tier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B38),
        title: const Text(
          'Delete Vault Item',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${item.title}" from your private vault?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      await context.read<VaultCubit>().deleteItem(
        item,
        tier: tier,
        currentFilter: _selectedFilter,
      );
      SnackBarHelper.showSuccess(null, AppStrings.itemDeletedVault);
    }
  }
}
