import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
//import 'package:window_manager_plus/window_manager_plus.dart';

import 'app.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';

void main() async {
  // 初始化窗口
  WidgetsFlutterBinding.ensureInitialized();
  /*if (kIsDesktop) {
    final window = WidgetsBinding.instance.window as FlutterWindow;
    window.minSize = Size(800, 600);
    window.size = Size(1024, 768);
  }*/
  // 必须加上这一行。
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
  // Connect to database
  mongo.Db pixivDb = mongo.Db('mongodb://localhost:27017/pixiv');
  await pixivDb.open();
  mongo.Db backupdb = mongo.Db('mongodb://localhost:27017/backup');
  await backupdb.open();
  mongo.DbCollection backupcollection =
      backupdb.collection('backup of pixiv infos');
  // read config files
  final settingsController = SettingsController(SettingsService());
  // Load the user's preferred settings while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  runApp(MyApp(
    pixivDb: pixivDb,
    backupcollection: backupcollection,
    settingsController: settingsController,
  ));
}

/*
在 Powershell 中打开新窗口，准备运行脚本。

将 PUB_HOSTED_URL 设置为镜像站点。

C:> $env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
content_copy
将 FLUTTER_STORAGE_BASE_URL 设置为镜像站点。

C:> $env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
*/
