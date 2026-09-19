import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  /// Live production backend deployed on Render
  static const String liveProductionUrl = 'https://tarot-consultation-platform.onrender.com';

  /// Compile-time environment variable override
  /// Override at build time via: --dart-define=API_BASE_URL=... or --dart-define-from-file=.env
  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: liveProductionUrl,
  );

  /// Automatically resolves base URL: defaults to live Render backend or uses compile-time override
  static String get defaultBaseUrl {
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }
    return liveProductionUrl;
  }

  /// WebSocket URL for STOMP chat
  static String get defaultWsUrl {
    final httpUrl = defaultBaseUrl;
    if (httpUrl.startsWith('https://')) {
      return httpUrl.replaceFirst('https://', 'wss://') + '/ws/chat';
    } else if (httpUrl.startsWith('http://')) {
      return httpUrl.replaceFirst('http://', 'ws://') + '/ws/chat';
    }
    return 'wss://tarot-consultation-platform.onrender.com/ws/chat';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Authentication Endpoints
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  // User Profile
  static const String currentUser = '/api/v1/users/me';
  static const String updateProfile = '/api/v1/users/me';
  static const String changePassword = '/api/v1/users/me/password';

  // Services & Categories
  static const String services = '/api/v1/services';
  static const String categories = '/api/v1/services/categories';

  // Availability & Bookings
  static const String availability = '/api/v1/availability';
  static const String bookings = '/api/v1/bookings';
  static String cancelBooking(int id) => '/api/v1/bookings/$id/cancel';

  // Payments
  static const String createPaymentOrder = '/api/v1/payments/create-order';
  static const String verifyPayment = '/api/v1/payments/verify';

  // Readings, Reviews, Notifications, Sessions
  static const String readings = '/api/v1/readings';
  static const String reviews = '/api/v1/reviews';
  static const String notifications = '/api/v1/notifications';
  static String markNotificationRead(int id) => '/api/v1/notifications/$id/read';
  static const String unreadNotificationCount = '/api/v1/notifications/unread-count';
  static const String sessions = '/api/v1/sessions';
  static String sessionByBooking(int bookingId) => '/api/v1/sessions/$bookingId';
  static String startSession(int bookingId) => '/api/v1/sessions/$bookingId/start';
  static String endSession(int bookingId) => '/api/v1/sessions/$bookingId/end';

  // Chat Endpoints
  static const String chatMessages = '/api/v1/chat/messages';
  static String bookingChatMessages(int bookingId) => '/api/v1/chat/$bookingId/messages';
  static String markChatRead(int bookingId) => '/api/v1/chat/$bookingId/read';
}
