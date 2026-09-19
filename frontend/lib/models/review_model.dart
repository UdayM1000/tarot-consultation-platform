import 'package:intl/intl.dart';

class ReviewModel {
  final int id;
  final int customerId;
  final String customerName;
  final int bookingId;
  final int rating;
  final String comment;
  final bool approved;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.bookingId,
    required this.rating,
    required this.comment,
    this.approved = true,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int? ?? 0,
      customerId: json['customerId'] as int? ?? 0,
      customerName: json['customerName'] as String? ?? 'Seeker',
      bookingId: json['bookingId'] as int? ?? 0,
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String? ?? '',
      approved: json['approved'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'approved': approved,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get ratingStars => '★' * rating + '☆' * (5 - rating);
  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);
}
