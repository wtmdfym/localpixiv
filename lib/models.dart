import 'package:flutter/material.dart';

//作品信息数据
class WorkInfo {
  // 作品Id
  int id;
  // 作品标题
  String title;
  // 作品类型int or str?
  String type;
  // 作品标签及翻译
  Map<String, dynamic> tags;
  // 作品描述
  String description;
  // 是否为原创作品
  bool isOriginal;
  // 是否收藏
  bool isLiked;
  // 上传日期
  String uploadDate;
  // 作者相关信息
  String userId;
  String userName;
  // 是否为ai生成 1 yes||2 no
  int? aiType;
  // 图片数量
  int? imageCount;
  // 图片路径
  List<dynamic>? imagePath;
  // 小说封面图片路径
  String? coverImagePath;
  // 小说内容
  String? content;
  // 小说字数
  int? characterCount;

  WorkInfo({
    required this.id,
    required this.title,
    required this.type,
    required this.tags,
    required this.description,
    required this.isOriginal,
    required this.isLiked,
    required this.uploadDate,
    required this.userId,
    required this.userName,
    this.aiType = 1,
    this.imageCount = 0,
    this.imagePath = const [''],
    this.coverImagePath = '',
    this.content = '',
    this.characterCount = 0,
  });

  factory WorkInfo.fromJson(Map<String, dynamic> json) {
    int imageCount = json['relative_path']?.length ?? 0;
    //TODO novelcover/id.png
    String coverImagePath = json['coverImagePath'] ?? '';
    return WorkInfo(
        id: json['id'],
        title: json['title'],
        type: json['type'],
        tags: json['tags'],
        description: json['description'],
        isOriginal: json['isOriginal'],
        isLiked: json['likeData'],
        uploadDate: json['uploadDate'],
        userId: json['userId'],
        userName: json['username'],
        aiType: json['aiType'],
        imageCount: imageCount,
        imagePath: json['relative_path'],
        coverImagePath: coverImagePath,
        content: json['content'],
        characterCount: json['characterCount']);
  }
}

/// 作者信息数据
class UserInfo {
  // 作者Id
  String userId;
  // 作者名字
  String userName;
  // 作者头像
  String profileImage;
  // 作者描述
  String userComment;
  // 作者作品路径
  List<WorkInfo> workInfos;
  // 是否还在关注
  bool notFollowingNow = false;

  UserInfo({
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.userComment,
    required this.workInfos,
    this.notFollowingNow = false,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    //RegExp regExp = RegExp(r'bird');
    //regExp.allMatches(json['profileImageUrl'],);
    return UserInfo(
        userId: json['userId'],
        userName: json['userName'],
        profileImage:
            'userProfileImages/${json['userId']}.${json['profileImageUrl']?.substring(103) ?? 'no'}',
        userComment: json['userComment'],
        workInfos: json['workInfos'],
        notFollowingNow: json['not_following_now'] ?? false);
  }
}

/// 总配置信息
class MainConfigs {
  String? savePath;
  Cookies? cookies;
  bool enableProxy = false;
  String? httpProxies;
  String? httpsProxies;
  int? semaphore;
  DownloadType? downloadType;
  String? lastRecordTime;
  bool enableClientPool = false;
  List<ClientPool>? clientPool;
  // UIConfigs uiConfigs = UIConfigs();

  MainConfigs({
    this.savePath,
    this.cookies,
    this.enableProxy = false,
    this.httpProxies,
    this.httpsProxies,
    this.semaphore,
    this.downloadType,
    this.lastRecordTime,
    this.enableClientPool = false,
    this.clientPool,
    // required this.uiConfigs,
  });

  MainConfigs.fromJson(Map<String, dynamic> json) {
    savePath = json['save_path'];
    cookies =
        json['cookies'] != null ? Cookies.fromJson(json['cookies']) : null;
    enableProxy = json['enable_proxy'];
    httpProxies = json['http_proxies'];
    httpsProxies = json['https_proxies'];
    semaphore = json['semaphore'];
    downloadType = json['download_type'] != null
        ? DownloadType.fromJson(json['download_type'])
        : null;
    lastRecordTime = json['last_record_time'];
    enableClientPool = json['enable_client_pool'];
    if (json['client_pool'] != null) {
      clientPool = <ClientPool>[];
      json['client_pool'].forEach((v) {
        clientPool!.add(ClientPool.fromJson(v));
      });
    }
    // uiConfigs = UIConfigs.fromJson(json['uiConfigs']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['save_path'] = savePath;
    if (cookies != null) {
      data['cookies'] = cookies!.toJson();
    }
    data['enable_proxy'] = enableProxy;
    data['http_proxies'] = httpProxies;
    data['https_proxies'] = httpsProxies;
    data['semaphore'] = semaphore;
    if (downloadType != null) {
      data['download_type'] = downloadType!.toJson();
    }
    data['last_record_time'] = lastRecordTime;
    data['enable_client_pool'] = enableClientPool;
    if (clientPool != null) {
      data['client_pool'] = clientPool!.map((v) => v.toJson()).toList();
    }
    // data['uiConfigs'] = uiConfigs.toJson();
    return data;
  }
}

/// UI界面配置信息
class UIConfigs {
  /// 是否在点击userinfo时自动打开
  bool autoOpen = true;

  /// 是否在点击tag时自动搜索
  bool autoSearch = true;

  /// 图片的最大缓存大小与窗口大小的比值，0为无限制，
  double imageCacheRate = 0;

  UIConfigs({
    this.autoOpen = true,
    this.autoSearch = true,
    this.imageCacheRate = 0,
  });

  UIConfigs.fromJson(Map<String, dynamic> json) {
    // TODO
    json = json['uiConfigs'];
    autoOpen = json['autoOpen'];
    autoSearch = json['autoSearch'];
    imageCacheRate = json['imageCacheRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['autoOpen'] = autoOpen;
    data['autoSearch'] = autoSearch;
    data['imageCacheRate'] = imageCacheRate;
    return data;
  }
}

/// Cookies配置信息
class Cookies {
  String? phpsessid;

  Cookies({
    this.phpsessid,
  });

  Cookies.fromJson(Map<String, dynamic> json) {
    phpsessid = json['PHPSESSID'];
  }

  @override
  String toString() {
    final String data = '{PHPSESSID :$phpsessid}';
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PHPSESSID'] = phpsessid;
    return data;
  }
}

/// DownloadType配置信息
class DownloadType {
  bool? illust;
  bool? manga;
  bool? novel;
  bool? ugoira;
  bool? series;

  DownloadType({
    this.illust,
    this.manga,
    this.novel,
    this.ugoira,
    this.series,
  });

  DownloadType.fromJson(Map<String, dynamic> json) {
    illust = json['illust'];
    manga = json['manga'];
    novel = json['novel'];
    ugoira = json['ugoira'];
    series = json['series'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['illust'] = illust;
    data['manga'] = manga;
    data['novel'] = novel;
    data['ugoira'] = ugoira;
    data['series'] = series;
    return data;
  }
}

/// ClientPool配置信息
class ClientPool {
  String? email;
  String? passward;
  Cookies? cookies;

  ClientPool({this.email, this.passward, this.cookies});

  ClientPool.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    passward = json['passward'];
    cookies =
        json['cookies'] != null ? Cookies.fromJson(json['cookies']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['passward'] = passward;
    if (cookies != null) {
      data['cookies'] = cookies!.toJson();
    }
    return data;
  }
}

/// indexedstack datas
class StackData {
  int index;
  String? title;
  Widget child;
  bool notRemoved;

  StackData(
      {required this.index,
      this.title,
      required this.child,
      this.notRemoved = true});
}

/// 搜索操作回调函数
typedef NeedSearchCallback = void Function(String needSearch);

/// 打开新窗口操作回调函数
typedef OpenTabCallback = void Function(String userName);
