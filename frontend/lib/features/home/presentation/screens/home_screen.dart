import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/error_banner.dart';
import 'package:tarot_consultation_app/core/widgets/loading_indicator.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_background.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_button.dart';
import 'package:tarot_consultation_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tarot_consultation_app/features/services/presentation/controllers/services_controller.dart';
import 'package:tarot_consultation_app/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:tarot_consultation_app/features/services/presentation/widgets/category_pill_list.dart';
import 'package:tarot_consultation_app/features/services/presentation/widgets/policy_disclaimer_card.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/features/services/presentation/widgets/service_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final unreadCount = ref.watch(notificationCenterProvider).unreadCount;
    final servicesState = ref.watch(servicesCatalogProvider);
    final servicesNotifier = ref.read(servicesCatalogProvider.notifier);

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.astralGold,
            backgroundColor: AppColors.cardSurface,
            onRefresh: () => servicesNotifier.refresh(),
            child: CustomScrollView(
              slivers: [
                // Top Custom Header / App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => context.push(AppRoutes.profile),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.goldButtonGradient,
                                ),
                                child: Center(
                                  child: Text(
                                    user?.initials ?? 'S',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.obsidianBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Blessed greetings,',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                                  ),
                                  Text(
                                    user?.name ?? 'Seeker',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none, color: AppColors.astralGold),
                                  tooltip: 'Notifications',
                                  onPressed: () => context.push(AppRoutes.notifications),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      child: Text(
                                        unreadCount > 9 ? '9+' : '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.auto_stories, color: AppColors.astralGold),
                              tooltip: 'Reading Journal',
                              onPressed: () => context.push(AppRoutes.myReadings),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_month_outlined, color: AppColors.astralGold),
                              tooltip: 'My Consultations',
                              onPressed: () => context.push(AppRoutes.myBookings),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_outline, color: AppColors.astralGold),
                              tooltip: 'Seeker Profile',
                              onPressed: () => context.push(AppRoutes.profile),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppColors.textMuted),
                              tooltip: 'Sign Out',
                              onPressed: () async {
                                await ref.read(authControllerProvider.notifier).logout();
                                if (context.mounted) {
                                  context.go(AppRoutes.login);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Platform Ethics & Disclaimer Banner
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: PolicyDisclaimerCard(),
                  ),
                ),

                // Reading Journal Quick Access Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: MysticCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () => context.push(AppRoutes.myReadings),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sacredPurple.withValues(alpha: 0.2),
                              border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(Icons.auto_stories, color: AppColors.astralGold, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Spiritual Reading Journal',
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Review your past Tarot spreads, Rune casts, and guidance',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.astralGold),
                        ],
                      ),
                    ),
                  ),
                ),

                // Section Title: Sacred Consultations
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Discover Consultations',
                              style: AppTypography.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose your divination medium to receive intuitive guidance',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Filter Pills
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CategoryPillList(
                      categories: servicesState.categories,
                      selectedCategoryId: servicesState.selectedCategoryId,
                      onCategorySelected: (categoryId) {
                        servicesNotifier.selectCategory(categoryId);
                      },
                    ),
                  ),
                ),

                // Error Banner if catalog loading failed
                if (servicesState.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          ErrorBanner(
                            message: servicesState.errorMessage!,
                            onDismiss: () => servicesNotifier.clearError(),
                          ),
                          const SizedBox(height: 12),
                          MysticButton(
                            text: 'Retry Loading Services',
                            onPressed: () => servicesNotifier.loadInitialData(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Loading Spinner State
                if (servicesState.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: LoadingIndicator(message: 'Revealing consultations...'),
                    ),
                  )
                // Empty State
                else if (servicesState.services.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.style_outlined, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 16),
                            const Text(
                              'No Readings Available',
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no consultations found in this category at this moment.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            MysticButton(
                              text: 'View All Readings',
                              width: 180,
                              onPressed: () => servicesNotifier.selectCategory(null),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                // Services List
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = servicesState.services[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ServiceCard(
                              service: service,
                              onTap: () {
                                context.push(AppRoutes.serviceDetailPath(service.id));
                              },
                            ),
                          );
                        },
                        childCount: servicesState.services.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
