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
    String coverImagePath = '';
    if (json['type'] == "novel") {
      RegExp imagere = RegExp("(jpg|jpeg|png|gif)");
      coverImagePath =
          'novelcover/${json['id']}.${imagere.stringMatch(json['coverUrl']!) ?? "no"}';
    }
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
    RegExp imagere = RegExp("(jpg|jpeg|png|gif)");
    return UserInfo(
        userId: json['userId'],
        userName: json['userName'],
        profileImage:
            'userprofileimage/${json['userId']}.${imagere.stringMatch(json['profileImageUrl'] ?? "no") ?? "no"}',
        userComment: json['userComment'],
        workInfos: json['workInfos'],
        notFollowingNow: json['not_following_now'] ?? false);
  }
}

/// Settings of the app.
class Settings {
  /// The path of pixiv filedir, used to load and save works etc.
  final String hostPath;

  /// The language user use.
  final Locale locale;

  /// If don't use mongoDB, app can only support to view local images.
  final bool useMongoDB;

  /// Must correct to connect to MongoDB server.
  final String serverHost;
  final ThemeMode themeMode;
  final Color color;

  /// 是否在点击userinfo时自动打开
  final bool autoOpen;

  /// 是否在点击tag时自动搜索
  final bool autoSearch;

  /// 图片的最大缓存大小与窗口大小的比值，0为无限制，
  final double imageCacheRate;

  /// 字体大小
  final double fontSize;
  WebCrawlerSettings webCrawlerSettings;
  //UIConfigs uiConfigs;

  Settings({
    this.hostPath = "C:/pixiv/",
    this.fontSize = 16,
    this.useMongoDB = true,
    this.serverHost = '',
    required this.locale,
    required this.themeMode,
    required this.color,
    this.autoOpen = true,
    this.autoSearch = true,
    this.imageCacheRate = 1.0,
    required this.webCrawlerSettings,

    //required this.uiConfigs
  });

  factory Settings.fromJson(Map<String, dynamic> json,
      [WebCrawlerSettings? webCrawlerSettings]) {
    final Map<String, ThemeMode> themeModeMap = {
      'system': ThemeMode.system,
      'light': ThemeMode.light,
      'dark': ThemeMode.dark
    };

    return Settings(
      hostPath: json['host_path'],
      fontSize: json['fontSize'],
      useMongoDB: json['useMongoDB'],
      serverHost: json['serverHost'],
      locale: Locale(json['locale']),
      themeMode: themeModeMap[json['themeMode']]!,
      color: Color.from(
          alpha: json['color']['a'],
          red: json['color']['r'],
          green: json['color']['g'],
          blue: json['color']['b']),
      autoOpen: json['autoSearch'],
      autoSearch: json['autoSearch'],
      imageCacheRate: json['imageCacheRate'],
      webCrawlerSettings: webCrawlerSettings ??
          WebCrawlerSettings.fromJson(json['WebCrawlerSettings']),
    );
  }

  Map<String, dynamic> toJson(bool withWebCrawlerSettings) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['host_path'] = hostPath;
    data['fontSize'] = fontSize;
    data['useMongoDB'] = useMongoDB;
    data['serverHost'] = serverHost;
    data['locale'] = locale.languageCode;
    data['themeMode'] = themeMode.name;
    data['color'] = {'a': color.a, 'r': color.r, 'g': color.g, 'b': color.b};

    data['autoOpen'] = autoOpen;
    data['autoSearch'] = autoSearch;

    data['imageCacheRate'] = imageCacheRate;
    if (withWebCrawlerSettings) {
      data['WebCrawlerSettings'] = webCrawlerSettings.toJson();
    }
    return data;
  }
}

/// WebCrawler(python app)配置信息
class WebCrawlerSettings {
  final String hostPath;
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
  WebCrawlerSettings({
    required this.hostPath,
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

  factory WebCrawlerSettings.fromJson(Map<String, dynamic> json) {
    if (json['client_pool'] != null) {
      for (var clientinfo in json['client_pool']) {
        ClientPool.fromJson(clientinfo);
      }
    }
    return WebCrawlerSettings(
        hostPath: json['host_path'],
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
    data['host_path'] = hostPath;
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

/// indexedstack datas
class StackData {
  int index;
  String? title;
  Widget child;

  StackData({required this.index, this.title, required this.child});
}

typedef OpenTabCallback = void Function(String userName);
typedef WorkBookmarkCallback = void Function(
    bool isLiked, int workId, String userName);
