
enum Environment { home, hotspot, production }

class ApiConfig {
  /// 1. Change this string variable to switch your network
  static const Environment _currentEnv = Environment.hotspot;

  /// 2. Defining IP addresses
  static const String _homeIp = "http://10.10.8.119:8000";

  /// Update this when the host device gets a new hotspot IP
  static const String _hotsoptIp = "http://192.168.42.158:8000";

  // Future live server domain
  static const String _productionUrl = "https://api.taunggyidirectory.com";

  /// 3. Core Getter
  static String get baseIp {
    switch (_currentEnv) {
      case Environment.home:
        return _homeIp;
      case Environment.hotspot:
        return _hotsoptIp;
      case Environment.production:
        return _productionUrl;
    }
  }

  /// 4. Feature Endpoints
  static String get authUrl => "$baseIp/auth";
  static String get categoriesUrl => "$baseIp/categories";
  static String get placesUrl => "$baseIp/places";
  static String get reviewsUrl => "$baseIp/reviews";
  static String get profileUrl => "$baseIp/profile";
}
