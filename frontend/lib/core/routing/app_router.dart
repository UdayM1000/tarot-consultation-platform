import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tarot_consultation_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:tarot_consultation_app/features/auth/presentation/screens/login_screen.dart';
import 'package:tarot_consultation_app/features/auth/presentation/screens/register_screen.dart';
import 'package:tarot_consultation_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:tarot_consultation_app/features/booking/presentation/screens/book_consultation_screen.dart';
import 'package:tarot_consultation_app/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:tarot_consultation_app/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:tarot_consultation_app/features/home/presentation/screens/home_screen.dart';
import 'package:tarot_consultation_app/features/payment/presentation/screens/payment_checkout_screen.dart';
import 'package:tarot_consultation_app/features/payment/presentation/screens/payment_success_screen.dart';
import 'package:tarot_consultation_app/features/services/presentation/screens/service_detail_screen.dart';
import 'package:tarot_consultation_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/presentation/screens/my_readings_screen.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/presentation/screens/reading_detail_screen.dart';
import 'package:tarot_consultation_app/features/session/presentation/screens/consultation_chat_screen.dart';
import 'package:tarot_consultation_app/features/session/presentation/screens/consultation_session_screen.dart';
import 'package:tarot_consultation_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:tarot_consultation_app/models/booking_model.dart';
import 'package:tarot_consultation_app/models/payment_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState.isAuthenticated;
      final currentPath = state.uri.path;

      final isAuthRoute = currentPath == AppRoutes.login ||
          currentPath == AppRoutes.register ||
          currentPath == AppRoutes.forgotPassword;

      final isSplash = currentPath == AppRoutes.splash;

      // Allow splash screen to finish checking auth status
      if (isSplash) return null;

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuth && !isAuthRoute) {
        return AppRoutes.login;
      }

      // If authenticated and trying to access login/register, redirect to home
      if (isAuth && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final serviceId = int.tryParse(idStr ?? '') ?? 0;
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookConsultation,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final serviceId = int.tryParse(idStr ?? '') ?? 0;
          return BookConsultationScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        builder: (context, state) {
          final booking = state.extra as BookingModel;
          return BookingConfirmationScreen(booking: booking);
        },
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentCheckout,
        builder: (context, state) {
          final idStr = state.pathParameters['bookingId'];
          final bookingId = int.tryParse(idStr ?? '') ?? 0;
          return PaymentCheckoutScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        builder: (context, state) {
          final payment = state.extra as PaymentModel;
          return PaymentSuccessScreen(payment: payment);
        },
      ),
      GoRoute(
        path: AppRoutes.sessionRoom,
        builder: (context, state) {
          final idStr = state.pathParameters['bookingId'];
          final bookingId = int.tryParse(idStr ?? '') ?? 0;
          return ConsultationSessionScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.sessionChat,
        builder: (context, state) {
          final idStr = state.pathParameters['bookingId'];
          final bookingId = int.tryParse(idStr ?? '') ?? 0;
          return ConsultationChatScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: AppRoutes.myReadings,
        builder: (context, state) => const MyReadingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.readingDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final readingId = int.tryParse(idStr ?? '') ?? 0;
          return ReadingDetailScreen(readingId: readingId);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
