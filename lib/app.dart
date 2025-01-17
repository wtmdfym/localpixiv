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
    final List<StackData> stackDatas = [
      StackData(index: 0, child: MyHomePage()),
      StackData(
          index: 1,
          child: Viewer(
            pixivDb: pixivDb,
            backupcollection: backupcollection,
            basicConfigs: configs.basicConfigs,
          )),
      StackData(
          index: 2,
          child: FollowingsDisplayer(
            hostPath: configs.basicConfigs.savePath,
            cacheRate: configs.uiConfigs.imageCacheRate,
            pixivDb: pixivDb,
          )),
      StackData(
          index: 3,
          child: Settings(
            configs: configs,
          )),
      StackData(index: 4, child: ResizableWidget()),
    ];
    return MultiProvider(
        providers: [
          ListenableProvider<StackChangeNotifier>(
            create: (context) {
              StackChangeNotifier stackDataModel = StackChangeNotifier();
              stackDataModel.initData(mainTabCount, stackDatas, 1);
              return stackDataModel;
            },
          ),
          ListenableProvider<ShowInfoNotifier>(
            create: (context) {
              return ShowInfoNotifier();
            },
          ),
          ListenableProvider<WorkBookmarkModel>(
            create: (context) {
              WorkBookmarkModel workBookMarModel = WorkBookmarkModel();
              return workBookMarModel;
            },
          ),
          ListenableProvider<UIConfigUpdateNotifier>(
            create: (context) {
              UIConfigUpdateNotifier configUpdateNotifier =
                  UIConfigUpdateNotifier();
              configUpdateNotifier.initconfigs(configs.uiConfigs);
              return configUpdateNotifier;
            },
          )
        ],
        builder: (context, child) {
          return Selector<UIConfigUpdateNotifier, double>(
              selector: (p0, p1) => p1.uiConfigs.fontSize,
              builder: (context, value, child) {
                final double bodyMediumfontSize = value;
                final double bodyLargeFontSize = bodyMediumfontSize + 2;
                final double bodySmallFontSize = bodyMediumfontSize - 2;
                final double iconSize = bodyMediumfontSize * 1.5;
                return MaterialApp(
                    title: 'Local Pixiv',
                    theme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.cyan,
                          //const Color.fromARGB(255, 88, 253, 247),
                          brightness: Brightness.light),
                      useMaterial3: true,
                      textTheme: TextTheme(
                        displayLarge:
                            TextStyle(fontSize: bodyLargeFontSize + 41),
                        displayMedium:
                            TextStyle(fontSize: bodyMediumfontSize + 31),
                        displaySmall:
                            TextStyle(fontSize: bodySmallFontSize + 24),
                        headlineLarge:
                            TextStyle(fontSize: bodyLargeFontSize + 16),
                        headlineMedium:
                            TextStyle(fontSize: bodyMediumfontSize + 14),
                        headlineSmall:
                            TextStyle(fontSize: bodySmallFontSize + 12),
                        titleLarge: TextStyle(fontSize: bodyLargeFontSize + 6),
                        titleMedium:
                            TextStyle(fontSize: bodyMediumfontSize + 2),
                        titleSmall: TextStyle(fontSize: bodySmallFontSize + 2),
                        bodyLarge: TextStyle(fontSize: bodyLargeFontSize),
                        bodyMedium: TextStyle(fontSize: bodyMediumfontSize),
                        bodySmall: TextStyle(fontSize: bodySmallFontSize),
                        labelLarge: TextStyle(fontSize: bodyLargeFontSize - 2),
                        labelMedium:
                            TextStyle(fontSize: bodyMediumfontSize - 2),
                        labelSmall: TextStyle(fontSize: bodySmallFontSize - 1),
                      ),
                      iconTheme: IconThemeData(
                          size: iconSize, opticalSize: iconSize * 2),
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
                  // 其他Locales
                ],*/
                    builder: (context, child) {
                      final mediaQueryData = MediaQuery.of(context);
                      final constrainedTextScaler =
                          mediaQueryData.textScaler.clamp(
                        minScaleFactor: 1.0,
                        maxScaleFactor: 1.3,
                      );
                      return MediaQuery(
                        data: mediaQueryData.copyWith(
                          textScaler: constrainedTextScaler,
                        ),
                        child: child!,
                      );
                    },
                    home: Scaffold(
                        backgroundColor:
                            const Color.fromARGB(255, 212, 252, 255),
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MutiTabbar(
                              initialIndex: 1,
                              mainTabs: const [
                                Tab(text: 'Home', icon: Icon(Icons.home)),
                                Tab(
                                    text: 'Viewer',
                                    icon: Icon(Icons.view_quilt_rounded)),
                                Tab(
                                    text: 'Followings',
                                    icon: Icon(Icons.view_list)),
                                Tab(
                                    text: 'Settings',
                                    icon: Icon(Icons.settings)),
                                Tab(text: 'Test', icon: Icon(Icons.build))
                              ],
                            ),
                            Consumer<WorkBookmarkModel>(
                              builder: (context, value, child) {
                                if (value.workId != 114514 &&
                                    value.userName != 'Man') {
                                  // 更新数据库
                                  pixivDb
                                      .collection(value.userName)
                                      .updateOne(
                                          mongo.where.eq('id', value.workId),
                                          mongo.modify.set(
                                              'likeData', value.bookmarked))
                                      .then((res) => res.isSuccess
                                          ? {}
                                          : throw 'update failed');
                                  backupcollection
                                      .updateOne(
                                          mongo.where.eq('id', value.workId),
                                          mongo.modify.set(
                                              'likeData', value.bookmarked))
                                      .then((res) => res.isSuccess
                                          ? {}
                                          : throw 'update failed');
                                }
                                return child!;
                              },
                              child: Expanded(
                                  child: LazyLoadIndexedStack(
                                datas: stackDatas,
                                preloadIndex: [1, 2],
                              )),
                            )
                          ],
                        )));
              });
        });
  }
}
