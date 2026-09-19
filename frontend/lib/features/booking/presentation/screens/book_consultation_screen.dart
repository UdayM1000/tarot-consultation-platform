import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/mystic_background.dart';
import '../../../../core/widgets/mystic_button.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../../../../core/widgets/mystic_text_field.dart';
import '../../../../models/time_slot_model.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../controllers/booking_controller.dart';

class BookConsultationScreen extends ConsumerStatefulWidget {
  final int serviceId;

  const BookConsultationScreen({super.key, required this.serviceId});

  @override
  ConsumerState<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends ConsumerState<BookConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _notesController = TextEditingController();
  bool _disclaimerAccepted = false;
  String? _disclaimerError;

  @override
  void dispose() {
    _questionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceDetailProvider(widget.serviceId));
    final bookingState = ref.watch(bookingCreationProvider(widget.serviceId));
    final bookingNotifier = ref.read(bookingCreationProvider(widget.serviceId).notifier);

    return Scaffold(
      body: MysticBackground(
        child: serviceAsync.when(
          loading: () => const Center(
            child: LoadingIndicator(message: 'Loading consultation details...'),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text('Failed to load consultation', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(err.toString(), style: AppTypography.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  MysticButton(text: 'Go Back', onPressed: () => context.pop()),
                ],
              ),
            ),
          ),
          data: (service) {
            return Column(
              children: [
                // Top Custom Navigation Bar
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.astralGold),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'Schedule Consultation',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                  ),
                ),

                // Main Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Service Summary Card
                          MysticCard(
                            padding: const EdgeInsets.all(16),
                            borderColor: AppColors.astralGold.withValues(alpha: 0.35),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.sacredPurple.withValues(alpha: 0.2),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name,
                                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${service.categoryName} • ${service.formattedDuration}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  service.formattedPrice,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.astralGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // 2. Select Session Mode
                          const Text('Consultation Mode', style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _SessionTypeChip(
                                label: 'Live Video',
                                icon: Icons.videocam_outlined,
                                isSelected: bookingState.selectedSessionType == 'VIDEO',
                                onTap: () => bookingNotifier.selectSessionType('VIDEO'),
                              ),
                              const SizedBox(width: 10),
                              _SessionTypeChip(
                                label: 'Voice Audio',
                                icon: Icons.phone_in_talk_outlined,
                                isSelected: bookingState.selectedSessionType == 'AUDIO',
                                onTap: () => bookingNotifier.selectSessionType('AUDIO'),
                              ),
                              const SizedBox(width: 10),
                              _SessionTypeChip(
                                label: 'Live Chat',
                                icon: Icons.chat_bubble_outline,
                                isSelected: bookingState.selectedSessionType == 'CHAT',
                                onTap: () => bookingNotifier.selectSessionType('CHAT'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // 3. Date Selection Strip
                          const Text('Select Date', style: AppTypography.titleSmall),
                          const SizedBox(height: 8),
                          _DateSelectionStrip(
                            selectedDate: bookingState.selectedDate,
                            onDateSelected: (date) => bookingNotifier.loadSlots(date),
                          ),
                          const SizedBox(height: 22),

                          // 4. Available Time Slots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Available Time Slots', style: AppTypography.titleSmall),
                              if (bookingState.selectedSlot != null)
                                Text(
                                  bookingState.selectedSlot!.formattedTimeRange,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.astralGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (bookingState.isSlotsLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: LoadingIndicator(message: 'Calculating reader availability...'),
                              ),
                            )
                          else if (bookingState.slots.isEmpty)
                            MysticCard(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.event_busy, color: AppColors.textMuted, size: 32),
                                    const SizedBox(height: 8),
                                    const Text('No slots available for this date.', style: AppTypography.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Please choose another day on the calendar strip above.',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: bookingState.slots.map((slot) {
                                final isSelected = bookingState.selectedSlot == slot;
                                return _TimeSlotChip(
                                  slot: slot,
                                  isSelected: isSelected,
                                  onTap: slot.available ? () => bookingNotifier.selectSlot(slot) : null,
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 24),

                          // 5. Question Submission
                          MysticTextField(
                            controller: _questionController,
                            label: service.questionRequired
                                ? 'Reading Question / Intention * (Required)'
                                : 'Reading Question / Intention (Optional)',
                            hint: service.questionRequired
                                ? 'e.g. What perspective should I hold regarding my career change?'
                                : 'Enter any specific focus or question',
                            prefixIcon: Icons.help_outline,
                            maxLines: 3,
                            validator: (val) {
                              if (service.questionRequired && (val == null || val.trim().isEmpty)) {
                                return 'Please enter your question for this consultation';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 6. Additional Information (Optional)
                          MysticTextField(
                            controller: _notesController,
                            label: 'Additional Context (Optional)',
                            hint: 'Any background details you wish to share with your reader',
                            prefixIcon: Icons.notes_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),

                          // 7. Platform Ethics & Disclaimer Checkbox
                          MysticCard(
                            padding: const EdgeInsets.all(14),
                            borderColor: _disclaimerError != null
                                ? AppColors.error
                                : AppColors.cardBorder,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _disclaimerAccepted,
                                  activeColor: AppColors.astralGold,
                                  checkColor: AppColors.obsidianBackground,
                                  onChanged: (val) {
                                    setState(() {
                                      _disclaimerAccepted = val ?? false;
                                      if (_disclaimerAccepted) _disclaimerError = null;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _disclaimerAccepted = !_disclaimerAccepted;
                                        if (_disclaimerAccepted) _disclaimerError = null;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'I agree to the platform policy: readings provide intuitive guidance and strictly prohibit inquiries regarding medical advice, legal proceedings, or pregnancy.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_disclaimerError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 12),
                              child: Text(
                                _disclaimerError!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Error Banner if submission failed
                          if (bookingState.errorMessage != null) ...[
                            ErrorBanner(
                              message: bookingState.errorMessage!,
                              onDismiss: () => bookingNotifier.clearError(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          const SizedBox(height: 80), // Padding for sticky bottom bar
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Bottom Booking Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    border: const Border(top: BorderSide(color: AppColors.cardBorder)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Locked',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                            ),
                            Text(
                              service.formattedPrice,
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.astralGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MysticButton(
                            text: 'Confirm Booking',
                            isLoading: bookingState.isSubmitting,
                            onPressed: () => _handleConfirmBooking(service.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleConfirmBooking(int serviceId) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_disclaimerAccepted) {
      setState(() {
        _disclaimerError = 'Please accept the consultation platform ethics & policy.';
      });
      return;
    }

    final bookingNotifier = ref.read(bookingCreationProvider(widget.serviceId).notifier);
    final booking = await bookingNotifier.submitBooking(
      question: _questionController.text.trim(),
      additionalInformation: _notesController.text.trim(),
      disclaimerAccepted: _disclaimerAccepted,
    );

    if (booking != null && mounted) {
      context.push(
        AppRoutes.bookingConfirmation,
        extra: booking,
      );
    }
  }
}

class _SessionTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.sacredPurple.withValues(alpha: 0.25)
                : AppColors.cardSurface,
            border: Border.all(
              color: isSelected ? AppColors.astralGold : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.astralGold : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.astralGold : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSelectionStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateSelectionStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Show next 14 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List.generate(14, (i) => today.add(Duration(days: i + 1)));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final dayName = DateFormat('EEE').format(date).toUpperCase();
          final dayNumber = date.day.toString();
          final monthName = DateFormat('MMM').format(date).toUpperCase();

          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppColors.astralGold.withValues(alpha: 0.18)
                    : AppColors.cardSurface,
                border: Border.all(
                  color: isSelected ? AppColors.astralGold : AppColors.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.astralGold : AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNumber,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.astralGold : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    monthName,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final TimeSlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.available;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: !isAvailable
              ? AppColors.cardSurface.withValues(alpha: 0.4)
              : (isSelected
                  ? AppColors.sacredPurple.withValues(alpha: 0.25)
                  : AppColors.cardSurface),
          border: Border.all(
            color: !isAvailable
                ? AppColors.cardBorder.withValues(alpha: 0.3)
                : (isSelected ? AppColors.astralGold : AppColors.cardBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAvailable ? Icons.access_time : Icons.block,
              size: 14,
              color: !isAvailable
                  ? AppColors.textMuted.withValues(alpha: 0.5)
                  : (isSelected ? AppColors.astralGold : AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              slot.formattedTimeRange,
              style: AppTypography.labelSmall.copyWith(
                color: !isAvailable
                    ? AppColors.textMuted.withValues(alpha: 0.5)
                    : (isSelected ? AppColors.astralGold : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                decoration: !isAvailable ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
