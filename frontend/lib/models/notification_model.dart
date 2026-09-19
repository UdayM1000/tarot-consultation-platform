import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERAL',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedTime => DateFormat('MMM d, h:mm a').format(createdAt);

  IconData get typeIcon {
    switch (type.toUpperCase()) {
      case 'READING_COMPLETED':
        return Icons.auto_stories;
      case 'BOOKING_CONFIRMED':
        return Icons.event_available;
      case 'PAYMENT_SUCCESS':
        return Icons.check_circle_outline;
      case 'SESSION_REMINDER':
      case 'SESSION_STARTING':
        return Icons.videocam_outlined;
      case 'NEW_MESSAGE':
        return Icons.chat_bubble_outline;
      case 'BOOKING_CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color get typeColor {
    switch (type.toUpperCase()) {
      case 'READING_COMPLETED':
        return AppColors.sacredPurple;
      case 'BOOKING_CONFIRMED':
      case 'PAYMENT_SUCCESS':
        return AppColors.astralGold;
      case 'SESSION_STARTING':
        return AppColors.success;
      case 'BOOKING_CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
