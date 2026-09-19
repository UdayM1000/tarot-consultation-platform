class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String serviceDetail = '/service/:id';
  static const String bookConsultation = '/service/:id/book';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String myBookings = '/my-bookings';
  static const String paymentCheckout = '/payment/checkout/:bookingId';
  static const String paymentSuccess = '/payment/success';
  static const String sessionRoom = '/session/:bookingId';
  static const String sessionChat = '/session/:bookingId/chat';
  static const String myReadings = '/readings';
  static const String readingDetail = '/reading/:id';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static String serviceDetailPath(int id) => '/service/$id';
  static String bookConsultationPath(int id) => '/service/$id/book';
  static String paymentCheckoutPath(int bookingId) => '/payment/checkout/$bookingId';
  static String sessionRoomPath(int bookingId) => '/session/$bookingId';
  static String sessionChatPath(int bookingId) => '/session/$bookingId/chat';
  static String readingDetailPath(int id) => '/reading/$id';
}
