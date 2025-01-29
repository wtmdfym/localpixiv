import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart'
    show Db, DbCollection, SelectorBuilder, where;

import '../models.dart';

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
    Map<String, dynamic> following, Db pixivDb) async {
  final List<WorkInfo> workInfos = [];
  DbCollection userCollection = pixivDb.collection(following['userName']);
  // TODO 按照上传时间排序
  await userCollection
      .find(where
          .exists('id')
          .excludeFields(['_id']).sortBy('id', descending: true))
      .forEach((info) {
    workInfos.add(WorkInfo.fromJson(info));
  });
  following['workInfos'] = workInfos;
  //following['profileImage'] = '';
  return UserInfo.fromJson(following);
}

/// Convert pixiv jump link to dircect link.
const Map<String, String> _convertMap = {
  '!': '%21',
  '"': '%22',
  '#': '%23',
  '\$': '%24',
  '%': '%25',
  '&': '%26',
  '\'': '%27',
  '(': '%28',
  ')': '%29',
  '*': '%2A',
  '+': '%2B',
  ',': '%2C',
  '/': '%2F',
  ':': '%3A',
  ';': '%3B',
  '<': '%3C',
  '=': '%3D',
  '>': '%3E',
  '?': '%3F',
  '@': '%40',
  '[': '%5B',
  ']': '%5D',
  '^': '%5E',
  '`': '%60',
  '{': '%7B',
  '|': '%7C',
  '}': '%7D',
  '~': '%7E'
};

String linkConverter(String link) {
  // /jump.php?
  link = link.replaceAll('/jump.php?', '');
  // Special character
  for (MapEntry entry in _convertMap.entries) {
    link = link.replaceAll(entry.value, entry.key);
  }
  return link;
}

class DataController {
  final DbCollection backupcollection;

  /// Amount of data loaded at a time
  final int buffer;
  late int _maxPage;

  /// Actual displayed page size
  final int pageSize;

  /// Make sure all data is updated before next load
  bool _onLoad = false;
  late SelectorBuilder _selector;
  final List<int> _loadedIndexs = [];
  final Map<int, List> _results = {};

  DataController({
    required this.backupcollection,
    required this.buffer,
    required this.pageSize,
  }) {
    // Make sure the buffer is an integer multiple of the pageSize.
    assert(buffer % pageSize == 0);
    assert(buffer > pageSize);
  }

  Future<void> _bufferLoader(int page) async {
    final int loadIndex = (pageSize * (page - 1) / buffer).floor();
    if (_loadedIndexs.contains(loadIndex)) {
      return;
    }

    final List bufferResults = [];
    await backupcollection
        .find(_selector.skip(loadIndex * buffer).limit(buffer))
        .forEach((data) => bufferResults.add(data));
    _results[loadIndex] = bufferResults;
    _loadedIndexs.add(loadIndex);
  }

  Future<List<dynamic>> getPageData(int page) async {
    final int loadIndex = (pageSize * (page - 1) / buffer).floor();
    if (!_loadedIndexs.contains(loadIndex)) await _bufferLoader(page);
    if (page == _maxPage) {
      return _results[loadIndex]!
          .sublist((page - 1) * pageSize - loadIndex * buffer);
    }
    return _results[loadIndex]!.sublist(
        (page - 1) * pageSize - loadIndex * buffer,
        page * pageSize - loadIndex * buffer);
  }

  bool set(SelectorBuilder selector, int maxPage) {
    if (_onLoad) return false;
    _onLoad = true;
    _reset();
    _selector = selector;
    _maxPage = maxPage;
    return true;
  }

  void _reset() {
    if (!_onLoad) return;
    _onLoad = false;
    _loadedIndexs.clear();
    _results.clear();
  }
}
