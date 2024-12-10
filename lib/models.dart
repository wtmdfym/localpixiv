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
    //TODO novelcovers/id.png
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
            'userprofileimage/${json['userId']}.${json['profileImageUrl']?.substring(103) ?? 'no'}',
        userComment: json['userComment'],
        workInfos: json['workInfos'],
        notFollowingNow: json['not_following_now'] ?? false);
  }
}

/// 总配置信息
class Configs {
  BasicConfigs basicConfigs;
  WebCrawlerConfigs webCrawlerConfigs;
  UIConfigs uiConfigs;

  Configs(
      {required this.basicConfigs,
      required this.webCrawlerConfigs,
      required this.uiConfigs});

  factory Configs.fromJson(Map<String, dynamic> json) {
    return Configs(
        basicConfigs: BasicConfigs.fromJson(json['BasicConfigs']),
        webCrawlerConfigs:
            WebCrawlerConfigs.fromJson(json['WebCrawlerConfigs']),
        uiConfigs: UIConfigs.fromJson(json['UIConfigs']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BasicConfigs'] = basicConfigs.toJson();
    data['WebCrawlerConfigs'] = webCrawlerConfigs.toJson();
    data['UIConfigs'] = uiConfigs.toJson();
    return data;
  }
}

/// 基本配置信息
class BasicConfigs {
  String savePath;

  BasicConfigs({
    this.savePath = 'C:/',
  });

  factory BasicConfigs.fromJson(Map<String, dynamic> json) {
    return BasicConfigs(savePath: json['save_path']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['save_path'] = savePath;
    return data;
  }
}

/// Cookies配置信息
class Cookies {
  String phpsessid;

  Cookies({
    this.phpsessid = '',
  });

  factory Cookies.fromJson(Map<String, dynamic> json) {
    return Cookies(phpsessid: json['PHPSESSID']);
  }

  @override
  String toString() {
    final String data = '{PHPSESSID :$phpsessid}';
    return data;
  }

  Map<String, String> toJson() {
    final Map<String, String> data = {};
    data['PHPSESSID'] = phpsessid;
    return data;
  }
}

/// DownloadType配置信息
class DownloadType {
  bool illust;
  bool manga;
  bool novel;
  bool ugoira;
  bool series;

  DownloadType({
    this.illust = true,
    this.manga = true,
    this.novel = false,
    this.ugoira = true,
    this.series = false,
  });

  factory DownloadType.fromJson(Map<String, dynamic> json) {
    return DownloadType(
      illust: json['illust'],
      manga: json['manga'],
      novel: json['novel'],
      ugoira: json['ugoira'],
      series: json['series'],
    );
  }

  Map<String, bool> toJson() {
    final Map<String, bool> data = {};
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
  Cookies cookies;

  ClientPool({this.email, this.passward, required this.cookies});

  factory ClientPool.fromJson(Map<String, dynamic> json) {
    return ClientPool(
        email: json['email'],
        passward: json['passward'],
        cookies: Cookies.fromJson(json['cookies']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['passward'] = passward;
    data['cookies'] = cookies.toJson();
    return data;
  }
}

/// web crawler(python app)配置信息
class WebCrawlerConfigs {
  Cookies cookies;
  bool enableProxy;
  String httpProxies;
  String httpsProxies;
  bool enableIPixiv;
  String ipixivHostPath;
  int semaphore;
  DownloadType downloadType;
  String lastRecordTime;
  bool enableClientPool;
  List<ClientPool?> clientPool;
  WebCrawlerConfigs({
    required this.cookies,
    required this.enableProxy,
    required this.httpProxies,
    required this.httpsProxies,
    required this.enableIPixiv,
    required this.ipixivHostPath,
    required this.semaphore,
    required this.downloadType,
    required this.lastRecordTime,
    required this.enableClientPool,
    required this.clientPool,
  });

  factory WebCrawlerConfigs.fromJson(Map<String, dynamic> json) {
    if (json['client_pool'] != null) {
      for (var clientinfo in json['client_pool']) {
        ClientPool.fromJson(clientinfo);
      }
    }
    return WebCrawlerConfigs(
        cookies: Cookies.fromJson(json['cookies']),
        enableProxy: json['enable_proxy'],
        httpProxies: json['http_proxies'],
        httpsProxies: json['https_proxies'],
        enableIPixiv: json['enableIPixiv'],
        ipixivHostPath: json['ipixivHostPath'],
        semaphore: json['semaphore'],
        downloadType: DownloadType.fromJson(json['download_type']),
        lastRecordTime: json['last_record_time'],
        enableClientPool: json['enable_client_pool'],
        clientPool: json['client_pool'] != null
            ? [
                for (var clientinfo in json['client_pool'])
                  ClientPool.fromJson(clientinfo)
              ]
            :
    [
          ]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cookies'] = cookies.toJson();
    data['enable_proxy'] = enableProxy;
    data['http_proxies'] = httpProxies;
    data['https_proxies'] = httpsProxies;
    data['enableIPixiv'] = enableIPixiv;
    data['ipixivHostPath'] = ipixivHostPath;
    data['semaphore'] = semaphore;
    data['download_type'] = downloadType.toJson();
    data['last_record_time'] = lastRecordTime;
    data['enable_client_pool'] = enableClientPool;
    data['client_pool'] = clientPool.map((v) => v?.toJson() ?? {}).toList();
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
    required this.autoOpen,
    required this.autoSearch,
    required this.imageCacheRate,
  });

  factory UIConfigs.fromJson(Map<String, dynamic> json) {
    return UIConfigs(
        autoOpen: json['autoSearch'],
        autoSearch: json['autoSearch'],
        imageCacheRate: json['imageCacheRate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['autoOpen'] = autoOpen;
    data['autoSearch'] = autoSearch;
    data['imageCacheRate'] = imageCacheRate;
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

/// 收藏操作回调函数
typedef WorkBookmarkCallback = void Function(
    bool isLiked, int workId, String userName);

/// 改变index回调函数
typedef ChangeIndexCallback = void Function(int index);
