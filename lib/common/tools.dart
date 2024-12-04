import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

/// cookies 格式化为 map
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

/// configs文件管理器
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

/// 异步加载图片
Future<ImageProvider> imageFileLoader(String? imagePath,
    [int? width, int? height, double? cacheRate]) async {
  ImageProvider image;
  if (imagePath != null) {
    File file = File(imagePath);
    bool exists = await file.exists();
    if (exists) {
      image = FileImage(file);
    } else {
      image = AssetImage('assets/images/default.png');
    }
  } else {
    // 若图片不存在就加载默认图片
    image = AssetImage('assets/images/default.png');
  }
  if (width != null && height != null) {
    if (cacheRate != null) {
      return ResizeImage(image,
          width: cacheRate == 0 ? width : width * cacheRate.toInt(),
          height: cacheRate == 0 ? height : height * cacheRate.toInt(),
          policy: ResizeImagePolicy.fit);
    }
    return ResizeImage(image,
        width: width, height: height, policy: ResizeImagePolicy.fit);
  } else {
    return image;
    //TODO big image open policy
    //ResizeImage(image,
    //    width: 5120, height: 2880, policy: ResizeImagePolicy.fit);
    //ResizeImage.resizeIfNeeded(2560, 1440, image);
  }
}

/// 从数据库获取UserInfo
Future<UserInfo> fetchUserInfo(
    Map<String, dynamic> following, mongo.Db pixivDb) async {
  final List<WorkInfo> workInfos = [];
  mongo.DbCollection userCollection = pixivDb.collection(following['userName']);
  await userCollection
      .find(mongo.where.exists('id').excludeFields(['_id']))
      .forEach((info) {
    workInfos.add(WorkInfo.fromJson(info));
  });
  following['workInfos'] = workInfos;
  following['profileImage'] = '';
  return UserInfo.fromJson(following);
}
