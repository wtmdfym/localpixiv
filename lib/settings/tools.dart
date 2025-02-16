import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';

InputDecoration getInputDecoration(String labelText, String hintText) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );
}

/// Configs file hander
/// Reads or writes the configs from or to local.
class ConfigFileHander {
  final String filepath;

  const ConfigFileHander(this.filepath);

  /// Read config file.
  Future<Settings> readSettings(bool loadDefault) async {
    final Map<String, dynamic> mainJson;
    if (loadDefault) {
      mainJson =
          jsonDecode(await rootBundle.loadString('jsons/default_config.json'));
      return Settings.fromJson(
          mainJson, await readWebCrawlerSettings(loadDefault));
    }
    if (!await File('${filepath}config.json').exists()) {
      mainJson =
          jsonDecode(await rootBundle.loadString('jsons/default_config.json'));
      return Settings.fromJson(
          mainJson, await readWebCrawlerSettings(loadDefault));
    }
    mainJson = jsonDecode(await File('${filepath}config.json').readAsString());
    return Settings.fromJson(
        mainJson, await readWebCrawlerSettings(loadDefault));
  }

  /// Read webCrawler config file
  Future<WebCrawlerSettings> readWebCrawlerSettings(bool loadDefault) async {
    final Map<String, dynamic> webCrawlerJson;
    if (loadDefault) {
      webCrawlerJson = jsonDecode(
          await rootBundle.loadString('jsons/default_webCrawler_config.json'));
      return WebCrawlerSettings.fromJson(webCrawlerJson);
    }
    if (!await File('${filepath}webCrawler_config.json').exists()) {
      webCrawlerJson = jsonDecode(
          await rootBundle.loadString('jsons/default_webCrawler_config.json'));
      return WebCrawlerSettings.fromJson(webCrawlerJson);
    }
    webCrawlerJson = jsonDecode(
        await File('${filepath}webCrawler_config.json').readAsString());
    return WebCrawlerSettings.fromJson(webCrawlerJson);
  }

  /// Write config file not inclued webCrawler settings.
  Future<bool> writeSettings(Settings settings) async {
    File configFile = File('${filepath}config.json');
    try {
      if (!await configFile.exists()) {
        await configFile.create(recursive: true, exclusive: true);
      }
      configFile.writeAsString(jsonEncode(settings.toJson(false)), flush: true);
      // writeWebCrawlerSettings(settings.webCrawlerSettings);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Write webCrawler config file
  Future<bool> writeWebCrawlerSettings(
      WebCrawlerSettings webCrawlerSettings) async {
    File webCrawlerConfigFile = File('${filepath}webCrawler_config.json');
    try {
      if (!await webCrawlerConfigFile.exists()) {
        await webCrawlerConfigFile.create(recursive: true, exclusive: true);
      }
      webCrawlerConfigFile
          .writeAsString(jsonEncode(webCrawlerSettings.toJson()), flush: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}
