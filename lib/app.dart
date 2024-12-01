import 'package:flutter/material.dart';
import 'package:localpixiv/common/customwidgets.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
//import 'package:flutter_localizations/flutter_localizations.dart';

import 'models.dart';
import 'widgets/lazyloadtabview.dart';
import 'states/home.dart';
import 'states/viewer.dart';
import 'states/followings.dart';
import 'states/settings.dart';
import 'common/customnotifier.dart';

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.pixivDb,
      required this.backupcollection,
      required this.configs});
  final mongo.Db pixivDb;
  final mongo.DbCollection backupcollection;
  final Configs configs;
  final int mainTabCount = 5;
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
        home: MainTabPage(
            pixivDb: pixivDb,
            backupcollection: backupcollection,
            configs: configs)

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

// This widget is the root of the application.
class MainTabPage extends StatefulWidget {
  const MainTabPage(
      {super.key,
      required this.pixivDb,
      required this.backupcollection,
      required this.configs});
  final mongo.Db pixivDb;
  final mongo.DbCollection backupcollection;
  final Configs configs;

  @override
  State<StatefulWidget> createState() {
    return MainTabPageState();
  }
}

class MainTabPageState extends State<MainTabPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final int mainTabCount = 5;
    final List<StackData> stackDatas = [
      StackData(index: 0, child: MyHomePage()),
      StackData(
          index: 1,
          child: Viewer(
            pixivDb: widget.pixivDb,
            backupcollection: widget.backupcollection,
            configs: widget.configs,
          )),
      StackData(
          index: 2,
          child: FollowingsDisplayer(
            hostPath: widget.configs.savePath!,
            pixivDb: widget.pixivDb,
          )),
      StackData(
          index: 3,
          child: Settings(
            configs: widget.configs,
          )),
      StackData(index: 4, child: MyDraggable()),
    ];

    //WebSocketChannel _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
    //final wsManager = WebSocketManager();
    //wsManager.initWebSocket('ws://localhost:8765');

    // 设置接收消息的回调函数
    //wsManager.setOnMessageCallback((message) {
    //  print('Received message: $message');
    //});
    return MultiProvider(
        providers: [
          ListenableProvider<StackChangeNotifier>(
            create: (context) {
              StackChangeNotifier stackDataModel = StackChangeNotifier();
              stackDataModel.initData(
                  mainTabCount,
                  stackDatas, //mainStacks,
                  [1, 2]);
              return stackDataModel;
            },
          ),
          ListenableProvider<WorkBookMarkModel>(
            create: (context) {
              WorkBookMarkModel workBookMarModel = WorkBookMarkModel();
              return workBookMarModel;
            },
          ),
        ],
        builder: (context, child) {
          return DefaultTabController(
              length: mainTabCount,
              child: Scaffold(
                  backgroundColor: const Color.fromARGB(255, 212, 252, 255),
                  appBar: MutiTabbar(
                    mainTabs: const [
                      Tab(text: 'Home', icon: Icon(Icons.home)),
                      Tab(text: 'Viewer', icon: Icon(Icons.view_quilt_rounded)),
                      Tab(text: 'Followings', icon: Icon(Icons.view_list)),
                      Tab(text: 'Settings', icon: Icon(Icons.settings)),
                      Tab(text: 'Test', icon: Icon(Icons.build))
                    ],
                  ),
                  body: Consumer<WorkBookMarkModel>(
                    builder: (context, value, child) {
                      if (value.workId != 114514 && value.userName != 'Man') {
                        // 更新数据库
                        widget.pixivDb
                            .collection(value.userName)
                            .updateOne(mongo.where.eq('id', value.workId),
                                mongo.modify.set('likeData', value.bookmarked))
                            .then((res) =>
                                res.isSuccess ? {} : throw 'update failed');
                        widget.backupcollection
                            .updateOne(mongo.where.eq('id', value.workId),
                                mongo.modify.set('likeData', value.bookmarked))
                            .then((res) =>
                                res.isSuccess ? {} : throw 'update failed');
                      }
                      return child!;
                    },
                    child: Center(
                        child: LazyLoadIndexedStack(children: stackDatas)),
                  )));
        } //)

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
