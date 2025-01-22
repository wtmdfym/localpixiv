import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'localization/localization_intl.dart';
import 'settings/pages/basic_page.dart';
import 'pages/home_page.dart';
import 'pages/viewer_page.dart';
import 'pages/followings_page.dart';
import 'settings/settings_view.dart';
import 'settings/settings_controller.dart';
import 'common/customnotifier.dart';
import 'widgets/super_tabview.dart';
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
    void bookmarkWork(bool isLiked, int workId, String userName) {
      if (workId != 114514 && userName != 'Man') {
        // Update dtabase
        pixivDb
            .collection(userName)
            .updateOne(mongo.where.eq('id', workId),
                mongo.modify.set('likeData', isLiked))
            .then((res) => res.isSuccess ? {} : throw 'update failed');
        backupcollection
            .updateOne(mongo.where.eq('id', workId),
                mongo.modify.set('likeData', isLiked))
            .then((res) => res.isSuccess ? {} : throw 'update failed');
      }
    }

    return MultiProvider(
      providers: [
        ListenableProvider<AddStackNotifier>(
          create: (context) {
            AddStackNotifier addStackNotifier = AddStackNotifier();
            addStackNotifier.init(settingsController, pixivDb, bookmarkWork);
            return addStackNotifier;
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
              body: SuperTabView(
                initialIndex: 1,
                maintainTabDatas: [
                  TabData(
                      title:
                          'Home', // MyLocalizations.of(context).tabTitle('h'),
                      icon: Icon(Icons.home),
                      canBeClosed: false,
                      child: MyHomePage()),
                  TabData(
                      title:
                          'Viewer', //MyLocalizations.of(context).tabTitle('v'),
                      icon: Icon(Icons.view_quilt_rounded),
                      canBeClosed: false,
                      child: ViewerPage(
                        controller: settingsController,
                        pixivDb: pixivDb,
                        backupcollection: backupcollection,
                        onBookmarked: bookmarkWork,
                      )),
                  TabData(
                      title:
                          'Followings', //MyLocalizations.of(context).tabTitle('f'),
                      icon: Icon(Icons.view_list),
                      canBeClosed: false,
                      child: FollowingsDisplayer(
                        controller: settingsController,
                        pixivDb: pixivDb,
                        onBookmarked: bookmarkWork,
                      )),
                  TabData(
                      title:
                          'Settings', //MyLocalizations.of(context).tabTitle('s'),
                      icon: Icon(Icons.settings),
                      canBeClosed: false,
                      child: SettingsView(
                        controller: settingsController,
                      )),
                ],
                preloadIndex: [1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
