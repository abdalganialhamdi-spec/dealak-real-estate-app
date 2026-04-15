class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.183.151.121:8000/api/v1',
  );

  static const String auth = '/auth';
  static String get login => '$auth/login';
  static String get register => '$auth/register';
  static String get logout => '$auth/logout';
  static String get me => '$auth/me';
  static String get refresh => '$auth/refresh';
  static String get forgotPassword => '$auth/forgot-password';
  static String get resetPassword => '$auth/reset-password';

  static const String properties = '/properties';
  static String get featuredProperties => '$properties/featured';
  static String get myProperties => '$properties/my';
  static String propertyImages(int id) => '$properties/$id/images';
  static String propertyImage(int id, int imageId) => '$properties/$id/images/$imageId';
  static String propertySimilar(int id) => '$properties/$id/similar';
  static String propertyBySlug(String slug) => '$properties/slug/$slug';

  static const String search = '/search';
  static String get searchNearby => '$search/nearby';
  static String get searchSuggestions => '$search/suggestions';
  static String get savedSearches => '$search/saved';

  static const String favorites = '/favorites';
  static String favoriteCheck(int id) => '$favorites/check/$id';

  static const String conversations = '/conversations';
  static String conversationMessages(int id) => '$conversations/$id/messages';
  static String conversationRead(int id) => '$conversations/$id/read';

  static const String deals = '/deals';
  static String dealPayments(int id) => '$deals/$id/payments';

  static const String reviews = '/reviews';
  static String propertyReviews(int id) => '$reviews/property/$id';

  static const String notifications = '/notifications';
  static String get unreadCount => '$notifications/unread-count';
  static String get readAll => '$notifications/read-all';
  static String notificationRead(String id) => '$notifications/$id/read';
  static String get deviceToken => '$notifications/device-token';

  static const String requests = '/requests';

  static String get userProfile => '/users/profile';
  static String get userAvatar => '/users/avatar';
  static String get userPassword => '/users/password';
  static String userById(int id) => '/users/$id';

  static const String admin = '/admin';
  static String get adminDashboard => '$admin/dashboard';
  static String get adminUsers => '$admin/users';
  static String adminUserStatus(int id) => '$admin/users/$id/status';
  static String get adminPendingProperties => '$admin/properties/pending';
  static String adminApproveProperty(int id) => '$admin/properties/$id/approve';
  static String get adminReports => '$admin/reports';
}
