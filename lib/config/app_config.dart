class AppConfig {
  static const String appName = 'Locket';
  static const String appGroup = 'group.com.example.locketApp';
  static const String iOSWidgetName = 'LocketWidget';
  static const String androidWidgetName = 'LocketAppWidgetProvider';

  // Toggle true when Firebase is configured (google-services.json & GoogleService-Info.plist)
  static const bool useFirebase = false;

  // Widget deep link scheme
  static const String deepLinkScheme = 'locket';
}
