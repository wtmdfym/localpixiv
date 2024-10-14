import 'package:flutter/material.dart';
import 'package:localpixiv/pages/viewer.dart';
import 'package:mongo_dart/mongo_dart.dart' as abab;
import 'package:proste_indexed_stack/proste_indexed_stack.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.db});
  final abab.Db db;

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
              seedColor: const Color.fromARGB(255, 0, 255, 247)),
          useMaterial3: true,
        ),
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
                backgroundColor: const Color.fromARGB(255, 212, 252, 255),
                appBar: AppBar(
                    bottom: TabBar(
                  onTap: (value) {
                    currentIndex.value = value;
                  },
                  tabs: const [
                    Tab(text: 'Home', icon: Icon(Icons.home)),
                    Tab(text: 'Viewer', icon: Icon(Icons.view_quilt_rounded)),
                    Tab(text: 'Followings', icon: Icon(Icons.view_list)),
                    Tab(text: 'Settings', icon: Icon(Icons.settings)),
                  ],
                )),
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
                              return ProsteIndexedStack(
                                index: value,
                                children: [
                                  IndexedStackChild(
                                      child: const Icon(Icons.directions_car)),
                                  IndexedStackChild(
                                      child: Viewer(db: db),
                                      preload: true), // 预加载的页面
                                  IndexedStackChild(
                                      child: const Icon(Icons.directions_bike)),
                                  IndexedStackChild(
                                      child: const Icon(Icons.downloading)),
                                ],
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
