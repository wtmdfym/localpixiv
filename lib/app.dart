import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/customwidgets.dart';
//import 'package:localpixiv/common/custom_notifier.dart';
import 'package:localpixiv/models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localpixiv/states/home.dart';
import 'package:localpixiv/states/viewer.dart';
import 'package:localpixiv/states/followings.dart';
import 'package:localpixiv/states/settings.dart';

//import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.pixivDb,
      required this.backupcollection,
      required this.process,
      required this.configs});
  final mongo.Db pixivDb;
  final mongo.DbCollection backupcollection;
  final Process process;
  final Configs configs;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //WebSocketChannel _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
    //final wsManager = WebSocketManager();
    //wsManager.initWebSocket('ws://localhost:8765');

    // 设置接收消息的回调函数
    //wsManager.setOnMessageCallback((message) {
    //  print('Received message: $message');
    //});
    ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 88, 253, 247)),
          useMaterial3: true,
        ),
        /*
        localizationsDelegates: [
          // 本地化的代理类
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // 美国英语
          const Locale('zh', 'CN'), // 中文简体
          //其他Locales
        ],*/
        home: DefaultTabController(
            length: 5,
            child: Scaffold(
                backgroundColor: const Color.fromARGB(255, 212, 252, 255),
                appBar: TabBar(
                  onTap: (value) {
                    currentIndex.value = value;
                  },
                  tabs: const [
                    Tab(text: 'Home', icon: Icon(Icons.home)),
                    Tab(text: 'Viewer', icon: Icon(Icons.view_quilt_rounded)),
                    Tab(text: 'Followings', icon: Icon(Icons.view_list)),
                    Tab(text: 'Settings', icon: Icon(Icons.settings)),
                    Tab(text: 'Test', icon: Icon(Icons.build))
                  ],
                ),
                body: /*TabBarView(
                children: [
                  const Icon(Icons.directions_car),
                  Viewer(
                    db: db,
                    //channel: _channel
                  ),
                  const Icon(Icons.directions_bike),
                  const Icon(Icons.downloading),
                ],
              ),*/
                    Center(
                        child: ValueListenableBuilder(
                            valueListenable: currentIndex,
                            builder: (context, value, child) {
                              return //ChangeNotifierProvider(
                                  //create: (context) => DataModel(), // 创建数据模型的实例
                                  //child:
                                  ProsteIndexedStack(
                                index: value,
                                children: [
                                  IndexedStackChild(
                                      child: MyHomePage(process: process)),
                                  IndexedStackChild(
                                      child: Viewer(
                                        pixivDb: pixivDb,
                                        backupcollection: backupcollection,
                                        process: process,
                                        configs: configs,
                                      ),
                                      preload: true), // 预加载的页面
                                  IndexedStackChild(
                                      child: FollowingsDisplayer(
                                        hostPath: configs.savePath!,
                                        pixivDb: pixivDb,
                                      ),
                                      preload: true),
                                  IndexedStackChild(
                                      child: Settings(
                                    configs: configs,
                                  )),
                                  IndexedStackChild(
                                    child: MyDraggable(),
                                  ),
                                ],
                                //)
                              );
                            }))))
        /*
      Scaffold(body: 
      VerticalTabs(
        selectedTabTextStyle: TextStyle(color: Colors.red),
        unSelectedTabTextStyle: TextStyle(color: Colors.grey),
        tabs: <String>[
          'Home',
          'Viewer',
          'Followings',
          'Settings',
        ],
        contents: <Widget>[
          Icon(Icons.directions_car),
          Viewer(),
          Icon(Icons.directions_bike),
          Icon(Icons.downloading),
        ],
      ),
    ));*/
        );
  }
}
