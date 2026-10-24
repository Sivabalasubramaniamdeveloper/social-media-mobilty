import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/api_keys/models/api_key_model.dart';
import 'package:mineai/features/api_keys/service/api_key_service.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final ApiKeyService _service = ApiKeyService();
  List<ApiKeyModel> _apiKeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final keys = await _service.fetchApiKeys();
      if (mounted) {
        setState(() {
          _apiKeys = keys;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, 'Failed to load API keys: $e');
      }
    }
  }

  Future<void> _toggleStatus(ApiKeyModel key, bool newStatus) async {
    try {
      await _service.updateApiKeyStatus(key.id, newStatus);
      await _loadData();
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          newStatus ? 'API Key activated' : 'API Key paused',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Could not update key: $e');
      }
    }
  }

  Future<void> _deleteKey(ApiKeyModel key) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? scheme.surface : const Color(0xFF1E1B38),
        title: Text(AppStrings.deleteKeyTitle, style: TextStyle(color: scheme.onSurface)),
        content: Text(
          'Are you sure you want to delete "${key.keyName}"? Future AI requests will fall back to MineAI default key.',
          style: TextStyle(
            color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteApiKey(key.id);
        await _loadData();
        if (mounted) SnackBarHelper.showSuccess(context, AppStrings.apiKeyDeleted);
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, 'Failed to delete key: $e');
      }
    }
  }

  void _showAddKeyModal() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final keyNameController = TextEditingController();
    final keyValController = TextEditingController();
    String selectedProviderName = 'gemini';
    bool obscure = true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? scheme.surface : const Color(0xFF1B192E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isSmtp = selectedProviderName == 'email_smtp';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isSmtp ? 'Add Email App Password' : 'Add API Key',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface.withValues(alpha: 0.7)),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Provider / Type',
                      style: TextStyle(
                        color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLight ? scheme.outlineVariant.withValues(alpha: 0.5) : Colors.white12,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedProviderName,
                          dropdownColor: isLight ? scheme.surface : const Color(0xFF262344),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'gemini',
                              child: Text(
                                'Google Gemini (AI Tasks)',
                                style: TextStyle(color: scheme.onSurface),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'email_smtp',
                              child: Text(
                                'Gmail App Password (In-App Sending)',
                                style: TextStyle(color: scheme.onSurface),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'openai',
                              child: Text(
                                'OpenAI (Optional)',
                                style: TextStyle(color: scheme.onSurface),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'anthropic',
                              child: Text(
                                'Anthropic Claude (Optional)',
                                style: TextStyle(color: scheme.onSurface),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedProviderName = val;
                                if (val == 'email_smtp' && keyNameController.text.isEmpty) {
                                  keyNameController.text = 'Gmail App Password';
                                } else if (val == 'gemini' && keyNameController.text.isEmpty) {
                                  keyNameController.text = 'My Gemini Key';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: keyNameController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Key Label / Name',
                        labelStyle: TextStyle(
                          color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                        ),
                        hintText: isSmtp ? 'e.g. Work Gmail App Password' : 'e.g. Personal Gemini Key',
                        hintStyle: TextStyle(
                          color: isLight ? Colors.black38 : Colors.white30,
                        ),
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: keyValController,
                      obscureText: obscure,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: isSmtp ? 'Google App Password (16 chars)' : 'API Key Secret',
                        labelStyle: TextStyle(
                          color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                        ),
                        hintText: isSmtp ? 'xxxx xxxx xxxx xxxx' : 'AIzaSy...',
                        hintStyle: TextStyle(
                          color: isLight ? Colors.black38 : Colors.white30,
                        ),
                        filled: true,
                        fillColor: isLight ? scheme.surfaceContainerHighest : const Color(0xFF262344),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: isLight ? Colors.black54 : Colors.white60,
                          ),
                          onPressed: () => setModalState(() => obscure = !obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSmtp
                          ? 'Generate a 16-character App Password at myaccount.google.com/apppasswords to allow direct in-app email sending.'
                          : 'When provided, MineAI uses your personal Gemini key for AI actions. You can store multiple keys and select the active one.',
                      style: TextStyle(
                        color: isLight ? AppColors.lightSecondaryOnSurface : Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final name = keyNameController.text.trim();
                                final val = keyValController.text.trim();
                                if (val.isEmpty) {
                                  SnackBarHelper.showWarning(context, AppStrings.enterKeyValue);
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  await _service.addApiKey(
                                    keyName: name.isNotEmpty
                                        ? name
                                        : (isSmtp ? 'Gmail App Password' : 'Gemini Key'),
                                    apiKey: val,
                                    providerName: selectedProviderName,
                                  );
                                  if (modalCtx.mounted) Navigator.pop(modalCtx);
                                  await _loadData();
                                  SnackBarHelper.showSuccess(null, AppStrings.keySavedSecurely);
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  SnackBarHelper.showError(null, 'Failed to add key: $e');
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Key',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppScreenHeader(
                  title: 'API Keys & Passwords',
                  centerTitle: true,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? _buildSkeletonLoader(context, scheme, isLight)
                    : RefreshIndicator(
                        color: scheme.primary,
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          children: [
                            _buildInfoBanner(context),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SAVED KEYS (${_apiKeys.length})',
                                  style: TextStyle(
                                    color: isLight
                                        ? AppColors.lightSecondaryOnSurface
                                        : AppColors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  'Select active key to use',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_apiKeys.isEmpty)
                              _buildEmptyState(context)
                            else
                              ..._apiKeys.map((key) => _buildKeyCard(context, key)),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                label: const Text(
                                  'Add New Key or Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _showAddKeyModal,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-End Encrypted',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Gemini API key and Gmail App Password are AES-256 encrypted at rest. Multiple keys can be stored; select which one to keep Active.',
                  style: TextStyle(
                    color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : const Color(0xFF1E1B38).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? scheme.outlineVariant.withValues(alpha: 0.4) : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.key_off_rounded,
            size: 48,
            color: isLight ? Colors.black26 : Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            'No Custom Keys Added',
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'MineAI platform default keys are currently active for your daily credits. Add your own Gemini API key or Gmail App Password anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyCard(BuildContext context, ApiKeyModel key) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final isSmtp = key.providerName == 'email_smtp';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: key.isActive
              ? scheme.primary
              : (isLight ? scheme.outlineVariant.withValues(alpha: 0.5) : Colors.white10),
          width: key.isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSmtp
                      ? Colors.orangeAccent.withValues(alpha: 0.15)
                      : scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSmtp ? Icons.mail_outline_rounded : Icons.auto_awesome_rounded,
                  color: isSmtp ? Colors.orangeAccent : scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key.keyName,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      key.providerDisplayName ?? (isSmtp ? 'Gmail App Password' : 'Google Gemini'),
                      style: TextStyle(
                        color: isSmtp ? Colors.orangeAccent : scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch to toggle active or inactive
              Switch(
                value: key.isActive,
                activeThumbColor: scheme.primary,
                onChanged: (val) => _toggleStatus(key, val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: isLight ? Colors.black12 : Colors.white10,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Key: ',
                    style: TextStyle(
                      color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '•••• •••• •••• ${key.keyLastFour}',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => _deleteKey(key),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(
    BuildContext context,
    ColorScheme scheme,
    bool isLight,
  ) {
    final baseColor = isLight ? Colors.grey[300]! : const Color(0xFF1E1B38);
    final highlightColor = isLight ? Colors.grey[100]! : const Color(0xFF2E2752);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
