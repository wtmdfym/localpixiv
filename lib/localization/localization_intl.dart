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

  String get appTitle {
    return Intl.message(
      'Local Pixiv',
      name: 'appTitle',
      desc: 'Title for the application',
    );
  }

  // Setting
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
          'other': 'Other Settings'
        },
        name: 'settingsTitle',
        desc: 'Titles of different settingPages',
        args: [choice],
      );

  // Theme
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
        'other': 'Select key error'
      },
      name: 'settingsContain',
      args: [choice]);
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
