import 'package:localpixiv/common/tools.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
//import 'package:window_manager_plus/window_manager_plus.dart';
import 'package:localpixiv/models.dart';

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

  // 读取配置文件
  Configs configs = await configReader('jsons/config.json');
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
  mongo.Db pixivDb = mongo.Db('mongodb://localhost:27017/pixiv');
  await pixivDb.open();
  mongo.Db backupdb = mongo.Db('mongodb://localhost:27017/backup');
  await backupdb.open();
  mongo.DbCollection backupcollection =
      backupdb.collection('backup of pixiv infos');
  runApp(MyApp(
    pixivDb: pixivDb,
    backupcollection: backupcollection,
    configs: configs,
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
