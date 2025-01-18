import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

/// cookies 格式化为 map
Map<String, String> cookiesFormater(String orgcookies) {
  RegExpMatch? matched = RegExp(r'(?<=[\{,\,,\s]\PHPSESSID\:\s).*?(?=[\},\,])')
      .firstMatch(orgcookies);
  if (matched != null) {
    return {'PHPSESSID': matched[0]!.trim()};
  }

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

/// 异步加载图片
Future<ImageProvider> imageFileLoader(String imagePath,
    {int width = 400,
    int height = 480,
    double cacheRate = 1.0,
    ResizeImagePolicy policy = ResizeImagePolicy.fit}) async {
  ImageProvider image;
  final File file = File(imagePath);
  final bool exists = await file.exists();
  if (exists) {
    image = FileImage(file);
  } else {
    // 若图片不存在就加载默认图片
    image = AssetImage('images/default.png');
  }
  return cacheRate == 0
      ? image
      : ResizeImage(image,
          width: (width * cacheRate).toInt(),
          height: (height * cacheRate).toInt(),
          policy: policy,
          allowUpscaling: true);
}

/// 从数据库获取UserInfo
Future<UserInfo> fetchUserInfo(
    Map<String, dynamic> following, mongo.Db pixivDb) async {
  final List<WorkInfo> workInfos = [];
  mongo.DbCollection userCollection = pixivDb.collection(following['userName']);
  // TODO 按照上传时间排序
  await userCollection
      .find(mongo.where
          .exists('id')
          .excludeFields(['_id']).sortBy('id', descending: true))
      .forEach((info) {
    workInfos.add(WorkInfo.fromJson(info));
  });
  following['workInfos'] = workInfos;
  //following['profileImage'] = '';
  return UserInfo.fromJson(following);
}
