import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/error_banner.dart';
import 'package:tarot_consultation_app/core/widgets/loading_indicator.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_background.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_button.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/features/booking/presentation/controllers/booking_controller.dart';
import 'package:tarot_consultation_app/features/session/presentation/controllers/session_controller.dart';
import 'package:tarot_consultation_app/models/booking_model.dart';
import 'package:tarot_consultation_app/models/session_model.dart';

class ConsultationSessionScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const ConsultationSessionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ConsultationSessionScreen> createState() => _ConsultationSessionScreenState();
}

class _ConsultationSessionScreenState extends ConsumerState<ConsultationSessionScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = ref.read(sessionRoomProvider(widget.bookingId)).session;
      if (session != null && session.isActive && session.startedAt != null) {
        if (mounted) {
          setState(() {
            _elapsed = DateTime.now().difference(session.startedAt!);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionRoomProvider(widget.bookingId));
    final sessionNotifier = ref.read(sessionRoomProvider(widget.bookingId).notifier);

    // Look up booking details for context if available
    final allBookings = ref.watch(myBookingsProvider).bookings;
    final booking = allBookings.cast<BookingModel?>().firstWhere(
          (b) => b?.id == widget.bookingId,
          orElse: () => null,
        );

    final session = sessionState.session;

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.astralGold),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.myBookings);
                    }
                  },
                ),
                title: Text(
                  session?.bookingReference.isNotEmpty == true
                      ? session!.bookingReference
                      : 'Consultation Room',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.astralGold,
                    letterSpacing: 1.0,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.astralGold),
                    onPressed: () => sessionNotifier.loadSession(),
                  ),
                ],
              ),

              if (sessionState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ErrorBanner(
                    message: sessionState.errorMessage!,
                    onDismiss: () => sessionNotifier.loadSession(),
                  ),
                ),

              if (sessionState.isLoading)
                const Expanded(
                  child: Center(
                    child: LoadingIndicator(message: 'Entering consultation room...'),
                  ),
                )
              else if (session != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Room Status & Live Timer Card
                        _buildStatusHeaderCard(session),
                        const SizedBox(height: 16),

                        // Reader & Focus Question Card
                        _buildFocusCard(session, booking),
                        const SizedBox(height: 16),

                        // Meeting Link / Video Provider Access Card
                        _buildMeetingProviderCard(session),
                        const SizedBox(height: 16),

                        // Live Consultation Chat Action
                        _buildChatBanner(context),
                        const SizedBox(height: 24),

                        // Session Lifecycle Action Controls
                        _buildSessionControls(context, session, sessionNotifier, sessionState.isActionLoading),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        const Text('Session could not be initialized', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        MysticButton(
                          text: 'Retry Connection',
                          width: 180,
                          onPressed: () => sessionNotifier.loadSession(),
                        ),
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

  Widget _buildStatusHeaderCard(SessionModel session) {
    Color statusColor = AppColors.astralGold;
    if (session.isActive) {
      statusColor = AppColors.success;
    } else if (session.isEnded) {
      statusColor = AppColors.sacredPurple;
    }

    return MysticCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    session.formattedStatus.toUpperCase(),
                    style: AppTypography.labelLarge.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mode: ${session.sessionType}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          if (session.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBorder.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.astralGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.astralGold),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(_elapsed),
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.astralGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFocusCard(SessionModel session, BookingModel? booking) {
    return MysticCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sacredPurple.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.sacredPurple),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking?.serviceName ?? 'Tarot Consultation',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reader: Master Elysia (Intuitive Mystic)',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (booking?.question != null && booking!.question!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 14),
            Text(
              'CONSULTATION INQUIRY FOCUS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.astralGold,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${booking.question}"',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetingProviderCard(SessionModel session) {
    final joinUrl = session.joinUrl ?? 'https://consult.tarotplatform.com/rooms/${session.externalSessionId ?? "live"}';

    return MysticCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.video_camera_front_outlined, color: AppColors.astralGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Live Room Access',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.obsidianBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.provider,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Secure encrypted video consultation bridge for private reading session.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.obsidianBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    joinUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.astralGold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: joinUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room URL copied to clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 16, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          MysticButton(
            text: 'Launch Consultation Bridge',
            icon: Icons.open_in_new,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Connecting to room: $joinUrl'),
                  backgroundColor: AppColors.cardSurface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatBanner(BuildContext context) {
    return MysticCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/session/${widget.bookingId}/chat'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.astralGold.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: AppColors.astralGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Consultation Chat',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time messages & card notifications',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.astralGold),
        ],
      ),
    );
  }

  Widget _buildSessionControls(
    BuildContext context,
    SessionModel session,
    SessionRoomNotifier notifier,
    bool isActionLoading,
  ) {
    if (session.isScheduled || session.isWaiting) {
      return MysticButton(
        text: 'Start Session (Begin Consultation)',
        icon: Icons.play_arrow,
        isLoading: isActionLoading,
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final ok = await notifier.startSession();
          if (ok && mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Session started! You are now live with the Reader.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    }

    if (session.isActive) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.stop_circle_outlined, color: AppColors.error),
        label: const Text(
          'Conclude Consultation Session',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        onPressed: () => _confirmEndSession(context, notifier),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.sacredPurple, size: 20),
          const SizedBox(width: 10),
          Text(
            'This consultation has concluded.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _confirmEndSession(BuildContext context, SessionRoomNotifier notifier) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text('End Consultation?', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to conclude this reading session? Once ended, this consultation will be marked complete.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue Session', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await notifier.endSession();
              if (ok && mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Consultation session concluded.'),
                    backgroundColor: AppColors.cardSurface,
                  ),
                );
              }
            },
            child: const Text('End Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
