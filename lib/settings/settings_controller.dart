import 'package:flutter/material.dart';

import '../models.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);
  // Basic
  // Theme
  // Search
  // Performance
  // Web Crawler

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Basic
  late String _hostPath;
  late Locale _locale;
  // Theme
  late ThemeData _themeData;
  late ThemeData _darkThemeData;
  late ThemeMode _themeMode;
  late double _fontsize;
  late TextTheme _textTheme;
  late IconThemeData _iconTheme;
  late Color _color;
  // Search
  late bool _autoOpen;
  late bool _autoSearch;

  // Performance
  late double _imageCacheRate;
  // Web Crawler
  late WebCrawlerSettings _webCrawlerSettings;

  // Allow Widgets to read the user's preferred ThemeMode.
  // Basic
  String get hostPath => _hostPath;
  Locale get locale => _locale;
  // Theme
  ThemeData get themeData => _themeData;
  ThemeData get darkThemeData => _darkThemeData;
  ThemeMode get themeMode => _themeMode;
  double get fontsize => _fontsize;
  //TextTheme get textTheme => _textTheme;
  //IconThemeData get iconTheme => _iconTheme;
  Color get color => _color;
  // Search
  bool get autoOpen => _autoOpen;
  bool get autoSearch => _autoSearch;
  // Performance
  double get imageCacheRate => _imageCacheRate;
  // Web Crawler
  WebCrawlerSettings get webCrawlerSettings => _webCrawlerSettings;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    Settings settings = await _settingsService.settings();
    // Basic
    _hostPath = settings.hostPath;
    _locale = settings.locale;
    // Theme
    _themeMode = settings.themeMode;
    _fontsize = settings.fontSize;
    _color = settings.color;
    _textTheme = _getTextTheme(_fontsize);
    _iconTheme = _getIconTheme(_fontsize);
    _themeData = ThemeData(
        colorScheme: _getLightColorScheme(_color),
        textTheme: _textTheme,
        iconTheme: _iconTheme,
        useMaterial3: true);
    _darkThemeData = ThemeData(
        colorScheme: _getDarkColorScheme(_color),
        textTheme: _textTheme,
        iconTheme: _iconTheme,
        useMaterial3: true);
    // Search
    _autoOpen = settings.autoOpen;
    _autoSearch = settings.autoSearch;
    // Performance
    _imageCacheRate = settings.imageCacheRate;
    // Web Crawler
    _webCrawlerSettings = settings.webCrawlerSettings;

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  // Basic
  Future<void> updateHostPath(String? newHostPath) async {
    if (newHostPath == null) return;
    if (newHostPath == _hostPath) return;
    _hostPath = newHostPath;
    updateWebCrawlerSettings(WebCrawlerSettings(
        hostPath: hostPath,
        cookies: _webCrawlerSettings.cookies,
        enableProxy: _webCrawlerSettings.enableProxy,
        httpProxies: _webCrawlerSettings.httpProxies,
        httpsProxies: _webCrawlerSettings.httpsProxies,
        enableIPixiv: _webCrawlerSettings.enableIPixiv,
        ipixivHostPath: _webCrawlerSettings.ipixivHostPath,
        semaphore: _webCrawlerSettings.semaphore,
        downloadType: _webCrawlerSettings.downloadType,
        lastRecordTime: _webCrawlerSettings.lastRecordTime,
        enableClientPool: _webCrawlerSettings.enableClientPool,
        clientPool: _webCrawlerSettings.clientPool));
    await _save();
  }

  /// Update and persist the Locale based on the user's selection.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners();
    await _save();
  }

  // Theme
  /// Update and persist the ThemeData based on the user's selection.
  Future<void> _updateThemeData() async {
    _themeData = ThemeData(
        colorScheme: _getLightColorScheme(_color),
        textTheme: _textTheme,
        iconTheme: _iconTheme,
        useMaterial3: true);
    _darkThemeData = ThemeData(
        colorScheme: _getDarkColorScheme(_color),
        textTheme: _textTheme,
        iconTheme: _iconTheme,
        useMaterial3: true);
    notifyListeners();

    await _save();
  }

  Future<void> updateColorScheme(Color? newColor) async {
    if (newColor == null) return;
    if (_color == newColor) return;
    _color = newColor;
    _updateThemeData();
    //await _settingsService.updateFontsize(newColor);
  }

  ColorScheme _getLightColorScheme(Color color) {
    return ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
  }

  ColorScheme _getDarkColorScheme(Color color) {
    return ColorScheme.fromSeed(
        seedColor: color,
        //const Color.fromARGB(255, 88, 253, 247),
        brightness: Brightness.dark);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();
    _save();
  }

  /// Update and persist the Fontsize based on the user's selection.
  Future<void> updateFontsize(double? newFontSize) async {
    if (newFontSize == null) return;
    if (newFontSize == _fontsize) return;
    _fontsize = newFontSize;
    _textTheme = _getTextTheme(newFontSize);
    // Make sure the size of icon is fit the size of font
    _iconTheme = _getIconTheme(newFontSize);
    _updateThemeData();
  }

  TextTheme _getTextTheme(double fontSize) {
    final double bodyMediumfontSize = fontSize;
    final double bodyLargeFontSize = bodyMediumfontSize + 2;
    final double bodySmallFontSize = bodyMediumfontSize - 2;
    return TextTheme(
      displayLarge: TextStyle(fontSize: bodyLargeFontSize + 41),
      displayMedium: TextStyle(fontSize: bodyMediumfontSize + 31),
      displaySmall: TextStyle(fontSize: bodySmallFontSize + 24),
      headlineLarge: TextStyle(fontSize: bodyLargeFontSize + 16),
      headlineMedium: TextStyle(fontSize: bodyMediumfontSize + 14),
      headlineSmall: TextStyle(fontSize: bodySmallFontSize + 12),
      titleLarge: TextStyle(fontSize: bodyLargeFontSize + 6),
      titleMedium: TextStyle(fontSize: bodyMediumfontSize + 2),
      titleSmall: TextStyle(fontSize: bodySmallFontSize + 2),
      bodyLarge: TextStyle(fontSize: bodyLargeFontSize),
      bodyMedium: TextStyle(fontSize: bodyMediumfontSize),
      bodySmall: TextStyle(fontSize: bodySmallFontSize),
      labelLarge: TextStyle(fontSize: bodyLargeFontSize - 2),
      labelMedium: TextStyle(fontSize: bodyMediumfontSize - 2),
      labelSmall: TextStyle(fontSize: bodySmallFontSize - 1),
    );
  }

  IconThemeData _getIconTheme(double iconSize) {
    return IconThemeData(
        size: iconSize * 1.25,
        opticalSize: iconSize * 2,
        applyTextScaling: false);
  }

  // Search
  /// Update and persist the autoOpen based on the user's selection.
  Future<void> updateAutoOpen(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _autoOpen) return;
    _autoOpen = newValue;
    await _save();
  }

  /// Update and persist the AutoSearch based on the user's selection.
  Future<void> updateAutoSearch(bool? newValue) async {
    if (newValue == null) return;
    if (newValue == _autoSearch) return;
    _autoSearch = newValue;
    await _save();
  }

  // Performance
  /// Update and persist the ImageCacheRate based on the user's selection.
  Future<void> updateImageCacheRate(double? newValue) async {
    if (newValue == null) return;
    if (newValue == _imageCacheRate) return;
    _imageCacheRate = newValue;
    await _save();
  }

  // Web Crawler
  Future<void> updateWebCrawlerSettings(
      WebCrawlerSettings? newWebCrawlerSettings) async {
    if (newWebCrawlerSettings == null) return;
    if (newWebCrawlerSettings == _webCrawlerSettings) return;
    _webCrawlerSettings = newWebCrawlerSettings;
    // Just save to file, don't need to update UI.
    // notifyListeners();
    await _settingsService.updateWebCrawlerSettings(newWebCrawlerSettings);
  }

  /// Persist the changes to a local database or the internet using the
  /// SettingService.
  Future<bool> _save() async {
    /*configWriter('jsons/config.json', widget.configs).then((success) => success
        ? {}
        : resultDialog(
            context.mounted ? context : null, 'Save configs', false));*/
    return await _settingsService.updateSettings(Settings(
      hostPath: _hostPath,
      locale: _locale,
      themeMode: _themeMode,
      color: _color,
      webCrawlerSettings: _webCrawlerSettings,
    ));
  }
}
