import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'localization/localization_intl.dart';
import 'models.dart';
import 'settings/pages/basic_page.dart';
import 'widgets/lazyloadtabview.dart';
import 'pages/home_page.dart';
import 'pages/viewer_page.dart';
import 'pages/followings_page.dart';
import 'settings/settings_view.dart';
import 'settings/settings_controller.dart';
import 'common/customnotifier.dart';
// import 'common/customwidgets.dart';

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.pixivDb,
      required this.backupcollection,
      required this.settingsController});
  final mongo.Db pixivDb;
  final mongo.DbCollection backupcollection;
  final int mainTabCount = 5;
  final SettingsController settingsController;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final List<StackData> stackDatas = [
      StackData(index: 0, child: MyHomePage()),
      StackData(
          index: 1,
          child: Viewer(
            controller: settingsController,
            pixivDb: pixivDb,
            backupcollection: backupcollection,
          )),
      StackData(
          index: 2,
          child: FollowingsDisplayer(
            controller: settingsController,
            pixivDb: pixivDb,
          )),
      StackData(
          index: 3,
          child: SettingsView(
            controller: settingsController,
          )),
      StackData(index: 4, child: Text('Working......')),
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
      ],
      child: ListenableBuilder(
          listenable: settingsController,
          builder: (context, child) => ToastificationWrapper(
                child: MaterialApp(
                  title: 'Local Pixiv',
                  // Providing a restorationScopeId allows the Navigator built by the
                  // MaterialApp to restore the navigation stack when a user leaves and
                  // returns to the app after it has been killed while running in the
                  // background.
                  restorationScopeId: 'app',
                  localizationsDelegates: const [
                    MyLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  locale: settingsController.locale,
                  supportedLocales: const [
                    Locale('en', ''), // English, no country code
                    Locale('zh', ''),
                  ],
                  theme: settingsController.themeData,
                  darkTheme: settingsController.darkThemeData,
                  themeMode: settingsController.themeMode,
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
                  // Define a function to handle named routes in order to support
                  // Flutter web url navigation and deep linking.
                  onGenerateRoute: (RouteSettings routeSettings) {
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) {
                        switch (routeSettings.name) {
                          case '${SettingsView.routeName}${BasicSettingsPage.routeName}':
                            return SearchBar();
                          default:
                            return ErrorWidget(
                                'Routes Error: Target route not exist ---> ${routeSettings.name}');
                        }
                      },
                    );
                  },
                  home: Scaffold(
                      // backgroundColor: const Color.fromARGB(255, 212, 252, 255),
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
                          Tab(text: 'Followings', icon: Icon(Icons.view_list)),
                          Tab(text: 'Settings', icon: Icon(Icons.settings)),
                          Tab(text: 'Test', icon: Icon(Icons.build))
                        ],
                        controller: settingsController,
                        pixivDb: pixivDb,
                      ),
                      Consumer<WorkBookmarkModel>(
                        builder: (context, value, child) {
                          if (value.workId != 114514 &&
                              value.userName != 'Man') {
                            // Update dtabase
                            pixivDb
                                .collection(value.userName)
                                .updateOne(
                                    mongo.where.eq('id', value.workId),
                                    mongo.modify
                                        .set('likeData', value.bookmarked))
                                .then((res) =>
                                    res.isSuccess ? {} : throw 'update failed');
                            backupcollection
                                .updateOne(
                                    mongo.where.eq('id', value.workId),
                                    mongo.modify
                                        .set('likeData', value.bookmarked))
                                .then((res) =>
                                    res.isSuccess ? {} : throw 'update failed');
                          }
                          return child!;
                        },
                        child: Expanded(
                            child: LazyLoadIndexedStack(
                          datas: stackDatas,
                          preloadIndex: //[3],
                              [1],
                        )),
                      )
                    ],
                  )),
                ),
              )),
    );
  }
}
