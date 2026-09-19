import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/notifications/domain/notification_state.dart';
import 'package:tarot_consultation_app/features/reviews/domain/review_state.dart';
import 'package:tarot_consultation_app/models/notification_model.dart';
import 'package:tarot_consultation_app/models/review_model.dart';

void main() {
  group('ReviewSubmissionState Tests', () {
    test('initial state defaults to 5 stars and empty comment', () {
      const state = ReviewSubmissionState();

      expect(state.rating, 5);
      expect(state.comment, '');
      expect(state.isSubmitting, isFalse);
      expect(state.isSubmitted, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates rating and submitted flags', () {
      const state = ReviewSubmissionState();

      final updated = state.copyWith(
        rating: 4,
        comment: 'Very helpful reading',
        isSubmitted: true,
      );

      expect(updated.rating, 4);
      expect(updated.comment, 'Very helpful reading');
      expect(updated.isSubmitted, isTrue);
    });

    test('copyWith resets errorMessage when null function provided', () {
      const state = ReviewSubmissionState(errorMessage: 'Validation failed');
      expect(state.errorMessage, 'Validation failed');

      final cleared = state.copyWith(errorMessage: () => null);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('PublicReviewsState Tests', () {
    test('initial state has empty list and false loading', () {
      const state = PublicReviewsState();

      expect(state.reviews, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates reviews list correctly', () {
      const state = PublicReviewsState();

      final review = ReviewModel(
        id: 1,
        customerId: 2,
        customerName: 'Seeker',
        bookingId: 101,
        rating: 5,
        comment: 'Wonderful!',
        createdAt: DateTime.now(),
      );

      final updated = state.copyWith(
        reviews: [review],
        isLoading: false,
      );

      expect(updated.reviews.length, 1);
      expect(updated.reviews.first.comment, 'Wonderful!');
    });
  });

  group('NotificationCenterState Tests', () {
    test('initial state has 0 unreadCount and empty notifications', () {
      const state = NotificationCenterState();

      expect(state.notifications, isEmpty);
      expect(state.unreadCount, 0);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates notifications list and unread count', () {
      const state = NotificationCenterState();

      final notif = NotificationModel(
        id: 1,
        userId: 5,
        title: 'New Message',
        message: 'Hello seeker',
        type: 'NEW_MESSAGE',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final updated = state.copyWith(
        notifications: [notif],
        unreadCount: 1,
      );

      expect(updated.notifications.length, 1);
      expect(updated.unreadCount, 1);
      expect(updated.notifications.first.isRead, isFalse);
    });
  });
}
