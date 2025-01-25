import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

import 'en.dart';
import 'zh.dart';

class MyLocalizations {
  MyLocalizations(
    this.locale,
  );

  final Locale locale;

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations)!;
  }

  static Map<String, dynamic> supportedLocales = {
    'en': enLocalizedValues,
    'zh': zhlocalizedValues,
  };

  Map<String, dynamic> get _stringMap =>
      supportedLocales[locale.languageCode] ?? enLocalizedValues;

  // General
  String get inputHintText => 'Please input......';
  String get invalidFormat => 'Invalid format!';
  // App
  String get appTitle => _stringMap['app_title'];

  String tabTitle(String choice) =>
      _stringMap['tab_title'][choice] ?? 'Select key error';

  // Pages
  String homePage(String choice) =>
      _stringMap['home_page'][choice] ?? 'Select key error';
  String viewerPage(String choice) =>
      _stringMap['viewer_page'][choice] ?? 'Select key error';
  String userDetialPage(String choice) =>
      _stringMap['user_detial_page'][choice] ?? 'Select key error';

  String settingsPage(String choice) =>
      _stringMap['settings_page'][choice] ?? 'Select key error';
  // Settings_pages
  String basicPage(String choice) =>
      _stringMap['basic_page'][choice] ?? 'Select key error';
  String themePage(String choice) =>
      _stringMap['theme_page'][choice] ?? 'Select key error';
  String searchPage(String choice) =>
      _stringMap['search_page'][choice] ?? 'Select key error';
  String performancePage(String choice) =>
      _stringMap['performance_page'][choice] ?? 'Select key error';
  String webCrawlerPage(String choice) =>
      _stringMap['webCrawler_page'][choice] ?? 'Select key error';
  String otherPage(String choice) =>
      _stringMap['other_page'][choice] ?? 'Select key error';
  String aboutPage(String choice) =>
      _stringMap['about_page'][choice] ?? 'Select key error';
  // Widgets
  String loader(String choice) =>
      _stringMap['loader'][choice] ?? 'Select key error';

  String bookmarkToolTip(String isLiked) =>
      _stringMap['bookmark_tool_tip'][isLiked] ?? 'Select key error';

  String pageController(String operation) =>
      _stringMap['page_controller'][operation] ?? 'Select key error';

  String get notFollowingWarn => _stringMap['not_following_warn'];

  // Dialogs TODO
  String actions(String action) =>
      _stringMap['actions'][action] ?? 'Select key error';
  String account(String choice) =>
      _stringMap['account'][choice] ?? 'Select key error';
  String get openLink => _stringMap['open_link'];
}

//Locale代理类
class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
