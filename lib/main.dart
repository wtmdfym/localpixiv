import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db;
//import 'package:window_manager_plus/window_manager_plus.dart';

import 'app.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';

void main() async {
  // Initi window.
  WidgetsFlutterBinding.ensureInitialized();
  /*if (kIsDesktop) {
    final window = WidgetsBinding.instance.window as FlutterWindow;
    window.minSize = Size(800, 600);
    window.size = Size(1024, 768);
  }*/
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(1440, 900),
    size: Size(1600, 960),
    center: true,
    backgroundColor: Colors.grey,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // read config files
  final settingsController = SettingsController(SettingsService());
  // Load the user's preferred settings while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  // Connect to database
  bool useMongoDB = settingsController.useMongoDB;
  final Db pixivDb = Db('mongodb://localhost:27017/pixiv');
  final Db backupDb = Db('mongodb://localhost:27017/backup');
  try {
    await pixivDb.open();
    await backupDb.open();
  } on Exception {
    useMongoDB = false;
  } finally {
    runApp(MyApp(
      useMongoDB: useMongoDB,
      pixivDb: pixivDb,
      backupDb: backupDb,
      settingsController: settingsController,
    ));
  }
}

/*
在 Powershell 中打开新窗口，准备运行脚本。

将 PUB_HOSTED_URL 设置为镜像站点。

C:> $env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
content_copy
将 FLUTTER_STORAGE_BASE_URL 设置为镜像站点。

C:> $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
*/
