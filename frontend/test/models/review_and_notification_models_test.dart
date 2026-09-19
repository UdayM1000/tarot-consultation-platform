import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/models/create_review_request_model.dart';
import 'package:tarot_consultation_app/models/notification_model.dart';
import 'package:tarot_consultation_app/models/review_model.dart';

void main() {
  group('ReviewModel Serialization & Helpers', () {
    final sampleReviewJson = {
      'id': 10,
      'customerId': 5,
      'customerName': 'Seeker Alice',
      'bookingId': 101,
      'rating': 5,
      'comment': 'Profound guidance and very accurate insight.',
      'approved': true,
      'createdAt': '2026-09-19T18:00:00',
    };

    test('should parse ReviewModel correctly from JSON', () {
      final review = ReviewModel.fromJson(sampleReviewJson);

      expect(review.id, 10);
      expect(review.customerId, 5);
      expect(review.customerName, 'Seeker Alice');
      expect(review.bookingId, 101);
      expect(review.rating, 5);
      expect(review.comment, 'Profound guidance and very accurate insight.');
      expect(review.approved, isTrue);
      expect(review.ratingStars, '★★★★★');
    });

    test('ratingStars renders 3 stars correctly', () {
      final review = ReviewModel.fromJson({...sampleReviewJson, 'rating': 3});
      expect(review.ratingStars, '★★★☆☆');
    });

    test('should serialize ReviewModel to JSON', () {
      final review = ReviewModel.fromJson(sampleReviewJson);
      final json = review.toJson();

      expect(json['id'], 10);
      expect(json['bookingId'], 101);
      expect(json['rating'], 5);
    });

    test('CreateReviewRequestModel serialization', () {
      const request = CreateReviewRequestModel(
        bookingId: 101,
        rating: 5,
        comment: 'Brilliant reading!',
      );
      final json = request.toJson();

      expect(json['bookingId'], 101);
      expect(json['rating'], 5);
      expect(json['comment'], 'Brilliant reading!');
    });
  });

  group('NotificationModel Serialization & Helpers', () {
    final sampleNotificationJson = {
      'id': 20,
      'userId': 5,
      'title': 'Your Reading is Ready!',
      'message': 'Your Celtic Cross reading results have been published.',
      'type': 'READING_COMPLETED',
      'isRead': false,
      'createdAt': '2026-09-19T18:10:00',
    };

    test('should parse NotificationModel correctly from JSON', () {
      final notif = NotificationModel.fromJson(sampleNotificationJson);

      expect(notif.id, 20);
      expect(notif.userId, 5);
      expect(notif.title, 'Your Reading is Ready!');
      expect(notif.type, 'READING_COMPLETED');
      expect(notif.isRead, isFalse);
      expect(notif.typeIcon, Icons.auto_stories);
      expect(notif.typeColor, AppColors.sacredPurple);
    });

    test('should map icon and color for BOOKING_CONFIRMED and PAYMENT_SUCCESS', () {
      final bookingNotif = NotificationModel.fromJson({
        ...sampleNotificationJson,
        'type': 'BOOKING_CONFIRMED',
      });
      expect(bookingNotif.typeIcon, Icons.event_available);
      expect(bookingNotif.typeColor, AppColors.astralGold);

      final paymentNotif = NotificationModel.fromJson({
        ...sampleNotificationJson,
        'type': 'PAYMENT_SUCCESS',
      });
      expect(paymentNotif.typeIcon, Icons.check_circle_outline);
    });

    test('copyWith updates fields properly', () {
      final notif = NotificationModel.fromJson(sampleNotificationJson);
      final read = notif.copyWith(isRead: true);

      expect(read.isRead, isTrue);
      expect(read.id, 20);
    });
  });
}
