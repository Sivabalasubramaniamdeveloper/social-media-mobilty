import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/utils/toast_helper.dart';
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
        showToast('Failed to load API keys: $e');
      }
    }
  }

  Future<void> _toggleStatus(ApiKeyModel key, bool newStatus) async {
    try {
      await _service.updateApiKeyStatus(key.id, newStatus);
      await _loadData();
      showToast(newStatus ? 'API Key activated' : 'API Key paused');
    } catch (e) {
      showToast('Could not update key: $e');
    }
  }

  Future<void> _deleteKey(ApiKeyModel key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B38),
        title: const Text('Delete Key', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${key.keyName}"? Future AI requests will fall back to MineAI default key.',
          style: const TextStyle(color: AppColors.secondaryText),
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
      try {
        await _service.deleteApiKey(key.id);
        await _loadData();
        showToast('API Key deleted');
      } catch (e) {
        showToast('Failed to delete key: $e');
      }
    }
  }

  void _showAddKeyModal() {
    final keyNameController = TextEditingController();
    final keyValController = TextEditingController();
    String selectedProviderName = 'gemini';
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B192E),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Provider / Type',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262344),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedProviderName,
                          dropdownColor: const Color(0xFF262344),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'gemini',
                              child: Text(
                                'Google Gemini (AI Tasks)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'email_smtp',
                              child: Text(
                                'Gmail App Password (In-App Email Sending)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'openai',
                              child: Text(
                                'OpenAI (Optional)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'anthropic',
                              child: Text(
                                'Anthropic Claude (Optional)',
                                style: TextStyle(color: Colors.white),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Key Label / Name',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        hintText: isSmtp ? 'e.g. Work Gmail App Password' : 'e.g. My Gemini Pro Key',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF262344),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: isSmtp ? 'Google App Password (16 chars)' : 'API Key Secret',
                        labelStyle: const TextStyle(color: AppColors.secondaryText),
                        hintText: isSmtp ? 'xxxx xxxx xxxx xxxx' : 'AIzaSy...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF262344),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white60,
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
                          : 'When provided, MineAI uses your personal Gemini API key for all AI operations. If left empty, MineAI default key is used.',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final name = keyNameController.text.trim();
                          final val = keyValController.text.trim();
                          if (val.isEmpty) {
                            showToast('Please enter key value');
                            return;
                          }
                          try {
                            await _service.addApiKey(
                              keyName: name.isNotEmpty ? name : (isSmtp ? 'Gmail App Password' : 'Gemini Key'),
                              apiKey: val,
                              providerName: selectedProviderName,
                            );
                            if (modalCtx.mounted) Navigator.pop(modalCtx);
                            await _loadData();
                            showToast('Key saved securely');
                          } catch (e) {
                            showToast('Failed to add key: $e');
                          }
                        },
                        child: const Text(
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
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          children: [
                            _buildInfoBanner(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SAVED KEYS',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  '${_apiKeys.length} configured',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_apiKeys.isEmpty) _buildEmptyState() else ..._apiKeys.map(_buildKeyCard),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                label: const Text(
                                  'Add New Key or Password',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.accentLavender, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-End Encrypted',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Your Gemini API key and Gmail App Password are AES-256 encrypted at rest. When your Gemini key is saved, your personal quota is used for AI actions.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(Icons.key_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          const Text(
            'No Custom Keys Added',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'MineAI platform default keys are currently active for your daily credits. Add your own Gemini API key or Gmail App Password anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyCard(ApiKeyModel key) {
    final isSmtp = key.providerName == 'email_smtp';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: key.isActive ? AppColors.primaryPurple.withValues(alpha: 0.4) : Colors.white10,
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
                      : AppColors.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSmtp ? Icons.mail_outline_rounded : Icons.auto_awesome_rounded,
                  color: isSmtp ? Colors.orangeAccent : AppColors.accentLavender,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      key.providerDisplayName ?? (isSmtp ? 'Gmail App Password' : 'Google Gemini'),
                      style: TextStyle(
                        color: isSmtp ? Colors.orangeAccent : AppColors.primaryPurpleLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: key.isActive,
                activeThumbColor: AppColors.primaryPurple,
                onChanged: (val) => _toggleStatus(key, val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Key: ',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                  ),
                  Text(
                    '•••• •••• •••• ${key.keyLastFour}',
                    style: const TextStyle(
                      color: Colors.white70,
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
}
