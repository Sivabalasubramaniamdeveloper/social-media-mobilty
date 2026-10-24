import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/support/models/ticket_model.dart';
import 'package:mineai/features/support/services/ticket_service.dart';
import 'package:mineai/instance/locator.dart';
import 'package:shimmer/shimmer.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final TicketService _ticketService = getIt<TicketService>();
  final TextEditingController _searchController = TextEditingController();

  List<TicketModel> _allTickets = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'open', 'in_progress', 'resolved'

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final list = await _ticketService.fetchUserTickets();
      if (mounted) {
        setState(() {
          _allTickets = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TicketModel> get _filteredTickets {
    final query = _searchController.text.trim().toLowerCase();
    return _allTickets.where((t) {
      if (_selectedFilter != 'all') {
        if (_selectedFilter == 'open' && t.status != 'open') return false;
        if (_selectedFilter == 'in_progress' && t.status != 'in_progress') return false;
        if (_selectedFilter == 'resolved' && (t.status != 'resolved' && t.status != 'closed')) return false;
      }
      if (query.isNotEmpty) {
        final matchesSubject = t.subject.toLowerCase().contains(query);
        final matchesModule = t.module.toLowerCase().contains(query);
        final matchesId = t.id.toLowerCase().contains(query);
        return matchesSubject || matchesModule || matchesId;
      }
      return true;
    }).toList();
  }

  IconData _getModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'expenses':
        return Icons.account_balance_wallet_rounded;
      case 'email_helper':
        return Icons.email_rounded;
      case 'tasks':
        return Icons.task_alt_rounded;
      case 'price_comparison':
        return Icons.compare_arrows_rounded;
      case 'mineai_streams':
      case 'ott':
        return Icons.smart_display_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      case 'vault':
        return Icons.lock_outline_rounded;
      case 'diary':
        return Icons.auto_stories_rounded;
      case 'profile_auth':
        return Icons.person_rounded;
      default:
        return Icons.support_agent_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return AppColors.incomeGreen;
      case 'closed':
        return AppColors.secondaryText;
      case 'open':
      default:
        return AppColors.expenseOrange;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final created = await context.push<bool>(RouteNames.createTicket);
            if (created == true) _loadTickets();
          },
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            AppStrings.newTicket,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.sm,
                ),
                child: AppScreenHeader(
                  title: AppStrings.supportTickets,
                  titleSize: AppSizes.fontHeading,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.dashboard);
                    }
                  },
                ),
              ),

              // Search & Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.sm,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isLight
                        ? scheme.surface
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight
                          ? scheme.outlineVariant.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: scheme.onSurface),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppStrings.searchTickets,
                      hintStyle: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                      icon: Icon(
                        Icons.search_rounded,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    _filterChip('all', AppStrings.allTickets, scheme, isLight),
                    _filterChip('open', AppStrings.ticketStatusOpen, scheme, isLight),
                    _filterChip('in_progress', AppStrings.ticketStatusInProgress, scheme, isLight),
                    _filterChip('resolved', AppStrings.ticketStatusResolved, scheme, isLight),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Content List
              Expanded(
                child: _isLoading
                    ? _buildSkeletonList(isLight)
                    : RefreshIndicator(
                        onRefresh: _loadTickets,
                        color: AppColors.primaryPurple,
                        child: _filteredTickets.isEmpty
                            ? _buildEmptyState(scheme)
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSizes.pagePadding,
                                  8,
                                  AppSizes.pagePadding,
                                  80,
                                ),
                                itemCount: _filteredTickets.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildTicketCard(
                                    _filteredTickets[index],
                                    scheme,
                                    isLight,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(
    String key,
    String label,
    ColorScheme scheme,
    bool isLight,
  ) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _selectedFilter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple
                : (isLight
                    ? scheme.surface
                    : Colors.white.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryPurple
                  : (isLight
                      ? scheme.outlineVariant.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    TicketModel ticket,
    ColorScheme scheme,
    bool isLight,
  ) {
    final statusColor = _getStatusColor(ticket.status);
    final isUrgent = ticket.priority.toLowerCase() == 'high' ||
        ticket.priority.toLowerCase() == 'urgent';

    return Container(
      decoration: BoxDecoration(
        color: isLight ? scheme.surface : const Color(0xFF1E1B38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight
              ? scheme.outlineVariant.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await context.push(RouteNames.ticketDetail, extra: ticket);
            _loadTickets();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ticket ID + Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getModuleIcon(ticket.module),
                            size: 16,
                            color: AppColors.primaryPurpleLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket.id,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            ticket.status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subject Title
                Text(
                  ticket.subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description excerpt
                Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Bottom Row: Module Chip + Priority + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isLight
                                ? scheme.surfaceContainerHighest
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.module.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.expenseRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HIGH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.expenseRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(ticket.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: AppColors.primaryPurpleLight,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noTicketsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noTicketsFoundDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList(bool isLight) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isLight
              ? Colors.grey.shade300
              : Colors.white.withValues(alpha: 0.05),
          highlightColor: isLight
              ? Colors.grey.shade100
              : Colors.white.withValues(alpha: 0.12),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}
