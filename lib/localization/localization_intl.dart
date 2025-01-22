import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

/*
import 'messages_en.dart' deferred as messages_en ;
import 'messages_zh.dart' deferred as messages_zh;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'en': messages_en.loadLibrary,
  'zh': messages_zh.loadLibrary,
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'en':
      return messages_en.messages;
    case 'zh':
      return messages_zh.messages;
    default:
      return null;
  }
}
*/
//dart run intl_translation:extract_to_arb --output-dir=lib\localization \ lib\localization\localization_intl.dart
//dart run intl_translation:generate_from_arb --output-dir=lib\localization lib\localization\localization_intl.dart lib\localization\intl_*.arb
class MyLocalizations {
  static Future<MyLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return MyLocalizations();
    });
  }

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations)!;
  }

  // App

  String get appTitle {
    return Intl.message(
      'Local Pixiv',
      name: 'appTitle',
      desc: 'Title for the application',
    );
  }

  /*
  String tabTitle(String choice) => Intl.select(
        choice,
        {
          'h': 'Home',
          'v': 'Viewer',
          'f': 'Following',
          's': 'Settings',
          'other': ''
        },
        args: [choice],
        name: 'tabTitle',
      );
  */
  // Loader
  String loader(String choice) => Intl.select(
        choice,
        {
          'ii':
              'Invalid image data! The image file may be corrupted. It will be deleted automatically.',
          'ei': 'Error loading image',
          'other': ''
        },
        args: [choice],
        name: 'loader',
      );
  // Containers
  String like(String isLiked) => Intl.select(
      isLiked, {'y': 'Cancel Bookmark', 'n': 'Bookmark', 'other': ''},
      args: [isLiked],
      name: 'like',
      desc:
          'Show tooltip to tell user if they click the button what will happen.');

  String pageController(String operation) => Intl.select(
        operation,
        {'p': 'Prev', 'j': 'Jump', 'n': 'Next', 'i': 'Page', 'other': ''},
        args: [operation],
        name: 'pageController',
      );

  String get notFollowingWarn =>
      Intl.message('NOT FOLLOWING NOW!', name: 'notFollowingWarn');

  // Pages
  String homePage(String choice) => Intl.select(
        choice,
        {
          'ef': '( ･ω･)☞   (:3 」∠)',
          'ew': 'Enter work Id',
          'eu': 'Enter user Id',
          'ek': 'Enter keywords',
          'er': '٩( ᐛ )و',
          'ce': 'ConnectError:\nProxy inaccessible',
          'ped': 'Please checking proxy settings.',
          'b': 'Start',
          's': 'Stop',
          'c': 'Clear',
          'cf': 'Followings',
          'ci': 'Id',
          'cu': 'User',
          'ct': 'Tags',
          'cr': 'Ranking',
          'other': ''
        },
        args: [choice],
        name: 'homePage',
      );
  String get noMoreData => Intl.message(
        'No more data',
        name: 'noMoreData',
      );
  String viewerPage(String choice) => Intl.select(
        choice,
        {
          's': 'Search',
          'as': 'Advanced Search',
          'l': 'Loading......',
          'other': ''
        },
        args: [choice],
        name: 'viewerPage',
      );
  // Settings
  String inputHintText(String hintText) =>
      Intl.message('Please input $hintText',
          name: 'inputHintText', args: [hintText]);
  String invalidFormat(String text) => Intl.message('Invalid format of $text',
      name: 'invalidFormat', args: [text]);
  String settingsTitle(String choice) => Intl.select(
        choice,
        {
          'basic': 'Basic Settings',
          'theme': 'Theme Settings',
          'search': 'Search Settings',
          'performance': 'Performance Settings',
          'webCrawler': 'WebCrawler Settings',
          'other': 'Other Settings',
          'about': 'About',
        },
        name: 'settingsTitle',
        desc: 'Titles of different settingPages',
        args: [choice],
      );

  String theme(String choice) => Intl.select(
      choice,
      {
        'system': 'System Theme',
        'light': 'Light Theme',
        'dark': 'Dark Theme',
        'other': 'Select key error'
      },
      name: 'theme',
      args: [choice]);

  String get setFontSize {
    return Intl.message(
      'FontSize (This is an example.)',
      name: 'setFontSize',
      desc: 'FontSize example',
    );
  }

  String settingsContain(String choice) => Intl.select(
      choice,
      {
        'hostPath': 'Host Path',
        'chooseColor': 'Click to select color you want to change',
        'enable': 'Enable',
        'proxy': 'Proxy',
        'resverseProxy': 'Resverse Proxy',
        'resverseProxyExample': 'Resverse Proxy (eg i.pximg.net)',
        'downloadstyle': 'Download Style',
        'concurrency': 'Concurrency',
        'largerThanOne': 'Concurrency must large than 1',
        'clientPool': 'ClientPool',
        'add': 'Add',
        'autoOpen': 'Auto open user detial page when click user infos',
        'autoSearch': 'Auto search when click tag',
        'icr': 'ImageCacheRate',
        'nl': 'Not limited',
        'other': 'Select key error'
      },
      name: 'settingsContain',
      args: [choice]);

  // Dialogs
  String actions(String action) => Intl.select(
      action, {'y': 'Yes', 'n': 'No', 'a': 'Apply', 'c': 'Cancel', 'other': ''},
      name: 'actions', args: [action]);
  String account(String choice) => Intl.select(
      choice,
      {
        'ne': 'Account Name or E-mail',
        'c': 'Account Cookie',
        'i': 'Account Info',
        'other': ''
      },
      name: 'account',
      args: [choice]);
  String get openLink => Intl.message('Open Link ?', name: 'openLink');
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
    return MyLocalizations.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
