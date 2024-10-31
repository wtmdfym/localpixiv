import 'dart:convert';
import 'dart:io';

import 'package:localpixiv/models.dart';

// cookies 格式化为 map
Map<String, String> cookiesFormater(String orgcookies) {
  Map<String, String> cookies = {};
  for (String cookie in orgcookies.split(";")) {
    List<String> temp = cookie.split("=");
    String key = temp[0];
    String value = '';
    for (String ttemp in temp.sublist(1)) {
      value += ttemp;
    }
    RegExp re = RegExp(r' ');
    key = key.replaceAll(re, '');
    value = value.replaceAll(re, '');
    cookies[key] = value;
  }
  return cookies;
}

// configs文件管理器
dynamic configManger(String configfilepath, String operation,
    [Configs? configs]) {
  File jsonFile;

  if (operation == 'r') {
    if (File(configfilepath).existsSync()) {
      jsonFile = File(configfilepath);
    } else {
      jsonFile = File('jsons/default_config.json');
    }
    String json = jsonFile.readAsStringSync();
    Configs configs = Configs.fromJson(jsonDecode(json));
    return configs;
  } else if (operation == 'w' && configs != null) {
    try {
      jsonFile = File(configfilepath);
      jsonFile.writeAsString(jsonEncode(configs), flush: true);
      return true;
    } catch (e) {
      return false;
    }
  }
}
