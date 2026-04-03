class Endpoints {
  static const String baseUrl = 'https://cuentitos.mx';

  // Auth
  static const String login = '/api/auth/mobile/login';
  static const String verify = '/api/auth/mobile/verify';
  static const String refresh = '/api/auth/mobile/refresh';

  // Data
  static const String me = '/api/mobile/me';
  static const String stories = '/api/mobile/stories';
  static String story(String id) => '/api/mobile/stories/$id';
  static String storyAudio(String id) => '/api/stories/$id/audio';
  static const String fcmToken = '/api/mobile/fcm-token';
  static const String playlists = '/api/mobile/playlists';
  static String playlist(String id) => '/api/mobile/playlists/$id';

  // Website endpoints used via WebView
  static const String checkout = '/api/checkout';
  static const String billing = '/api/billing';
  static const String onboard = '/api/onboard';
  static const String tier = '/api/tier';
  static const String deliveryTime = '/api/delivery-time';
  static const String childrenUpdate = '/api/children';
  static const String parentUpdate = '/api/parent';
}
