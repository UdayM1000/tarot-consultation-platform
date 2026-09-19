import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/theme/theme_provider.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tarot_consultation_app/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:tarot_consultation_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:tarot_consultation_app/features/profile/presentation/widgets/change_password_dialog.dart';
import 'package:tarot_consultation_app/features/profile/presentation/widgets/edit_profile_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  void _showEthicsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.midnightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.sacredPurple.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.shield_moon_outlined, color: AppColors.astralGold, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Sacred Ethics & Code',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Our Sanctuary operates on the pillars of spiritual integrity, free will, and non-judgmental guidance:',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildEthicsPoint(
                icon: Icons.favorite_border,
                title: 'Free Will & Empowerment',
                description:
                    'Divination illuminates potentials and archetypes; the seeker retains sovereign agency and free will over all life decisions.',
              ),
              _buildEthicsPoint(
                icon: Icons.medical_services_outlined,
                title: 'Boundaries & Prohibitions',
                description:
                    'Readings strictly prohibit diagnosis of medical conditions, legal or courtroom predictions, financial speculation, and third-party spying.',
              ),
              _buildEthicsPoint(
                icon: Icons.lock_outline,
                title: 'Strict Secrecy & Discretion',
                description:
                    'All inquiries, card spreads, rune casts, and chat transmissions remain entirely confidential between the seeker and reader.',
              ),
              _buildEthicsPoint(
                icon: Icons.psychology_outlined,
                title: 'Non-Judgmental Compassion',
                description:
                    'Every seeker is welcomed into an inclusive space honoring diverse spiritual paths without dogma or prejudice.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildEthicsPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.astralGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.astralGold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.astralGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.midnightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(
              'Depart Sanctuary?',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you wish to conclude your sacred session? You can sign back in at any time to resume your readings.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Remain',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).logout();
              router.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authControllerProvider).user;
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user ?? authUser;
    final themeMode = ref.watch(themeModeProvider);
    final unreadCount = ref.watch(notificationCenterProvider).unreadCount;

    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'Seeker Sanctuary',
          style: AppTypography.titleLarge.copyWith(color: AppColors.astralGold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.astralGold),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.astralGold),
            tooltip: 'Refresh Profile',
            onPressed: () => ref.read(profileControllerProvider.notifier).loadProfile(),
          ),
        ],
      ),
      body: profileState.isLoading && user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.astralGold),
            )
          : RefreshIndicator(
              color: AppColors.astralGold,
              backgroundColor: AppColors.cardSurface,
              onRefresh: () => ref.read(profileControllerProvider.notifier).loadProfile(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Identity Header Card
                  MysticCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldButtonGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.astralGold.withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user?.initials ?? 'S',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.obsidianBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name.isNotEmpty == true ? user!.name : 'Mystic Seeker',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'seeker@tarotplatform.com',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.sacredPurple.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.sacredPurple.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Text(
                                user?.roleDisplay ?? 'Seeker',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.sacredPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.astralGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user?.formattedMemberSince ?? 'Sacred Initiate',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.astralGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Journey & Activity Metrics Strip
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.calendar_month_outlined,
                          count: '${profileState.bookingCount}',
                          label: 'Consultations',
                          onTap: () => context.push(AppRoutes.myBookings),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.auto_stories_outlined,
                          count: '${profileState.readingCount}',
                          label: 'Readings',
                          onTap: () => context.push(AppRoutes.myReadings),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.notifications_none,
                          count: '$unreadCount',
                          label: 'Alerts',
                          onTap: () => context.push(AppRoutes.notifications),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 8),
                  MysticCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.person_outline,
                          title: 'Full Name',
                          subtitle: user?.name.isNotEmpty == true ? user!.name : 'Not set',
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
                        _buildSettingTile(
                          icon: Icons.email_outlined,
                          title: 'Sacred Email',
                          subtitle: user?.email ?? 'Not set',
                          trailing: const Icon(Icons.lock, size: 16, color: AppColors.textMuted),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
                        _buildSettingTile(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          subtitle: user?.phone?.isNotEmpty == true ? user!.phone! : 'Add phone number',
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.edit_note, color: AppColors.astralGold),
                          title: Text(
                            'Edit Personal Details',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.astralGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.astralGold),
                          onTap: () {
                            if (user != null) {
                              EditProfileDialog.show(context, user);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Security Section
                  _buildSectionHeader('Account Security'),
                  const SizedBox(height: 8),
                  MysticCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_reset, color: AppColors.astralGold),
                          title: const Text('Account Password', style: AppTypography.titleSmall),
                          subtitle: Text(
                            'Last protected with SHA-256 JWT security',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                          trailing: TextButton(
                            onPressed: () => ChangePasswordDialog.show(context),
                            child: Text(
                              'Change',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.astralGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
                        _buildSettingTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Session Authentication',
                          subtitle: 'Stateless JWT active & verified',
                          trailing: const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Preferences Section
                  _buildSectionHeader('Preferences & Experience'),
                  const SizedBox(height: 8),
                  MysticCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: AppColors.astralGold,
                          ),
                          title: const Text('Sanctuary Aesthetic', style: AppTypography.titleSmall),
                          subtitle: Text(
                            isDark ? 'Mystic Obsidian (Dark)' : 'Astral Ivory (Light)',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeTrackColor: AppColors.astralGold,
                            onChanged: (_) {
                              ref.read(themeModeProvider.notifier).toggleTheme();
                            },
                          ),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.shield_moon_outlined, color: AppColors.astralGold),
                          title: const Text('Sacred Ethics & Code of Conduct', style: AppTypography.titleSmall),
                          subtitle: Text(
                            'Free will, discretion & divination boundaries',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          onTap: () => _showEthicsBottomSheet(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign Out Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Sign Out of Sanctuary',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: () => _showLogoutConfirmation(context),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Tarot & Rune Consultation Platform • v1.0.0',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.astralGold,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return MysticCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.astralGold, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.astralGold),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      trailing: trailing,
    );
  }
}
