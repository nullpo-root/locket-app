import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/app_config.dart';
import '../models/moment_model.dart';

class WidgetSyncService {
  static final WidgetSyncService _instance = WidgetSyncService._internal();
  factory WidgetSyncService() => _instance;
  WidgetSyncService._internal();

  /// Initialize home_widget with the App Group ID for iOS
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(AppConfig.appGroup);
      debugPrint('[WidgetSyncService] Initialized with AppGroup: ${AppConfig.appGroup}');
    } catch (e) {
      debugPrint('[WidgetSyncService] Error initializing HomeWidget: $e');
    }
  }

  /// Sync the latest moment to both iOS and Android Home Screen Widgets
  Future<bool> syncMomentToWidget(Moment moment) async {
    try {
      debugPrint('[WidgetSyncService] Syncing moment from ${moment.senderName} to Home Screen...');

      // 1. Prepare image path accessible to widget
      String widgetAccessibleImagePath = moment.imagePath;

      // On iOS, files must reside in the App Group shared container
      if (Platform.isIOS) {
        final sharedDirectory = await HomeWidget.getWidgetData<String>('app_group_dir');
        // Fallback or copy to container
        final File sourceFile = File(moment.imagePath);
        if (await sourceFile.exists()) {
          // home_widget provides renderFlutterWidget or we can save image directly
          widgetAccessibleImagePath = moment.imagePath;
        }
      }

      // Format time
      final timeFormatted = DateFormat('h:mm a').format(moment.createdAt);
      final dateFormatted = DateFormat('MMM d').format(moment.createdAt);

      // 2. Save metadata to shared UserDefaults / SharedPreferences
      await HomeWidget.saveWidgetData<String>('moment_id', moment.id);
      await HomeWidget.saveWidgetData<String>('sender_name', moment.senderName);
      await HomeWidget.saveWidgetData<String>('caption', moment.caption);
      await HomeWidget.saveWidgetData<String>('time_ago', '$timeFormatted • $dateFormatted');
      await HomeWidget.saveWidgetData<String>('image_path', widgetAccessibleImagePath);

      // 3. Trigger Home Screen Widget refresh
      await HomeWidget.updateWidget(
        name: AppConfig.androidWidgetName,
        iOSName: AppConfig.iOSWidgetName,
      );

      debugPrint('[WidgetSyncService] Successfully requested widget update on iOS & Android!');
      return true;
    } catch (e) {
      debugPrint('[WidgetSyncService] Failed to sync to widget: $e');
      return false;
    }
  }

  /// Check if the app was launched by tapping a Home Screen widget
  Future<Uri?> getInitiallyLaunchedUri() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      debugPrint('[WidgetSyncService] Error checking widget launch URI: $e');
      return null;
    }
  }

  /// Listen for deep link events when app is already in memory
  void registerInteractivityCallback(void Function(Uri?) onUri) {
    HomeWidget.widgetClicked.listen(onUri);
  }
}
