import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show Db, DbCollection, where, modify;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'localization/localization.dart';
import 'settings/pages/basic_page.dart';
import 'pages/home_page.dart';
import 'pages/viewer_page.dart';
import 'pages/followings_page.dart';
import 'pages/tag_page.dart';
import 'settings/settings_view.dart';
import 'settings/settings_controller.dart';
import 'common/customnotifier.dart';
import 'widgets/super_tabview.dart';

class MyApp extends StatelessWidget {
  MyApp(
      {super.key,
      required this.useMongoDB,
      required this.pixivDb,
      required this.backupDb,
      required this.settingsController}) {
    // Check whether the database connection is successful.
    if (useMongoDB) {
      assert(pixivDb.isConnected && backupDb.isConnected,
          'Connect Error: Can\'t connect MongoDB server!');
    }
  }
  final bool useMongoDB;
  final Db pixivDb;
  final Db backupDb;

  final SettingsController settingsController;
  final int mainTabCount = 5;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    late final DbCollection backupCollection;

    void bookmarkWork(bool isLiked, int workId, String userName) {
      if (!useMongoDB) {
        return;
      }
      if (workId != 114514 && userName != 'Man') {
        // Update dtabase
        pixivDb
            .collection(userName)
            .updateOne(where.eq('id', workId), modify.set('likeData', isLiked))
            .then((res) => res.isSuccess ? {} : throw 'update failed');
        backupCollection
            .updateOne(where.eq('id', workId), modify.set('likeData', isLiked))
            .then((res) => res.isSuccess ? {} : throw 'update failed');
      }
    }

    if (useMongoDB) {
      backupCollection = backupDb.collection('backup of pixiv infos');
    }

    return MultiProvider(
      providers: [
        ListenableProvider<SuperTabViewNotifier>(
          create: (context) {
            SuperTabViewNotifier addStackNotifier = SuperTabViewNotifier();
            addStackNotifier.init(settingsController, pixivDb, bookmarkWork);
            return addStackNotifier;
          },
        ),
        ListenableProvider<SearchNotifier>(create: (context) {
          return SearchNotifier();
        })
      ],
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (context, child) => ToastificationWrapper(
          child: MaterialApp(
            onGenerateTitle: (context) => MyLocalizations.of(context).appTitle,
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
              final constrainedTextScaler = mediaQueryData.textScaler.clamp(
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
                body: useMongoDB
                    ? SuperTabView(
                        initialIndex: 1,
                        preloadIndex: [1],
                        maintainTabDatas: [
                          TabData(
                              title:
                                  'Home', // MyLocalizations.of(context).tabTitle('h'),
                              icon: Icon(Icons.home_outlined),
                              canBeClosed: false,
                              child: MyHomePage()),
                          TabData(
                              title:
                                  'Viewer', //MyLocalizations.of(context).tabTitle('v'),
                              icon: Icon(Icons.view_quilt_outlined),
                              canBeClosed: false,
                              child: ViewerPage(
                                controller: settingsController,
                                useMongoDB: useMongoDB,
                                backupcollection: backupCollection,
                                onBookmarked: bookmarkWork,
                              )),
                          TabData(
                              title:
                                  'Followings', //MyLocalizations.of(context).tabTitle('f'),
                              icon: Icon(Icons.view_list_outlined),
                              canBeClosed: false,
                              child: FollowingsPage(
                                controller: settingsController,
                                pixivDb: pixivDb,
                                onBookmarked: bookmarkWork,
                              )),
                          TabData(
                              title: 'Tags',
                              icon: Icon(Icons.view_column_outlined),
                              canBeClosed: false,
                              child: TagPage(
                                controller: settingsController,
                                tagCollection: pixivDb.collection('All Tags'),
                              )),
                          TabData(
                              title:
                                  'Settings', //MyLocalizations.of(context).tabTitle('s'),
                              icon: Icon(Icons.settings_outlined),
                              canBeClosed: false,
                              child: SettingsView(
                                controller: settingsController,
                              )),
                        ],
                      )
                    : /*Builder(
                      builder: (context) {
                        final TextEditingController controller =
                            TextEditingController();
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('No MongoDB Connection'),
                                  content: Column(
                                    children: [
                                      Text(
                                          'Enter your mongoDB server path, or you can only use basic function.'),
                                      TextField(
                                        controller: controller,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: Text('Connect')),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {}, child: Text('OK')),
                                  ],
                                ));
                        return ViewerPage(
                            controller: settingsController,
                            useMongoDB: useMongoDB,
                            onBookmarked: bookmarkWork);
                      },
                    ),*/
                    ViewerPage(
                        controller: settingsController,
                        useMongoDB: useMongoDB,
                        onBookmarked: bookmarkWork)),
          ),
        ),
      ),
    );
  }
}
