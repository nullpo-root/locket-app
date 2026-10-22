import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/camera_screen.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/widget_sync_service.dart';

List<CameraDescription> _availableCameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay (Dark status bar & navigation)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize camera
  try {
    _availableCameras = await availableCameras();
  } catch (e) {
    debugPrint('[Main] No camera found or error: $e');
  }

  // Initialize Core Services
  await StorageService().initialize();
  await AuthService().initialize();
  await WidgetSyncService().initialize();

  runApp(const LocketApp());
}

class LocketApp extends StatefulWidget {
  const LocketApp({super.key});

  @override
  State<LocketApp> createState() => _LocketAppState();
}

class _LocketAppState extends State<LocketApp> {
  @override
  void initState() {
    super.initState();
    _handleWidgetLaunch();
  }

  Future<void> _handleWidgetLaunch() async {
    // Check if launched from Home Screen Widget
    final launchedUri = await WidgetSyncService().getInitiallyLaunchedUri();
    if (launchedUri != null) {
      debugPrint('[LocketApp] Launched from Home Widget with URI: $launchedUri');
    }

    // Listen while app is in foreground/background
    WidgetSyncService().registerInteractivityCallback((uri) {
      debugPrint('[LocketApp] Widget clicked while active: $uri');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFFFD500), // Locket iconic gold
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD500),
          secondary: Color(0xFFFFD500),
          surface: Color(0xFF1C1C1E),
          background: Colors.black,
        ),
        fontFamily: '.SF Pro Text',
        useMaterial3: true,
      ),
      home: CameraScreen(cameras: _availableCameras),
    );
  }
}
