import 'package:flutter/material.dart';
import 'package:localpixiv/common/defaultdatas.dart';
import 'package:localpixiv/models.dart';

/// 作品信息变更捕捉器
class WorkInfoNotifier extends ValueNotifier<WorkInfo> {
  WorkInfoNotifier(super.workInfo);

  void setInfo(WorkInfo newinfo) {
    value = newinfo;
    notifyListeners();
  }

  void setInfoJson(Map<String, dynamic> json) {
    value.id = json['id'];
    value.title = json['title'];
    value.type = json['type'];
    value.tags = json['tags'];
    value.description = json['description'];
    value.isOriginal = json['isOriginal'];
    value.isLiked = json['likeData'];
    value.uploadDate = json['uploadDate'];
    value.userId = json['userId'];
    value.userName = json['username'];
    //value.imageCount = json['imageCount']!;
    value.imagePath = json['relative_path'];
    value.imageCount = value.imagePath?.length ?? 0;
    value.coverImagePath = json['coverImagePath'];
    value.content = json['content'];
    notifyListeners();
  }

  void setId(int id) {
    /// 赋值 这里需要注意的是 如果没有给 ValueNotifier 赋值 WorkInfo 对象时
    /// value 会出现空指针异常
    value.id = id;

    /// 通知更新
    notifyListeners();
  }

  void settitle(String title) {
    value.title = title;
    notifyListeners();
  }

  void setimageCount(int imageCount) {
    value.imageCount = imageCount;
    notifyListeners();
  }

  void setimagepath(List<String> imagePath) {
    value.imagePath = imagePath;
    notifyListeners();
  }

  void bookmark(bool isliked) {
    value.isLiked = isliked;
  }
}

/// 自定义的作者信息变更捕捉器
class UserInfoNotifier extends ValueNotifier<UserInfo> {
  UserInfoNotifier(super.workInfo);

  void setInfo(UserInfo newinfo) {
    value = newinfo;
    notifyListeners();
  }

  void setInfoJson(Map<String, dynamic> json) {
    value.userId = json['userId'];
    value.userName = json['username'];
    value.profileImage = json['profileImage'];
    value.userComment = json['userComment'];
    value.workInfos = json['workInfos'];
    notifyListeners();
  }
}

/// 信息变更通知器
class InfosNotifier<T> extends ValueNotifier<List<T>> {
  InfosNotifier(super.info);

  void setInfos(List<T> newinfo) {
    value = newinfo;
    notifyListeners();
  }
}

/// 作品信息显示通知器
class ShowInfoNotifier with ChangeNotifier {
  WorkInfo _workInfo = defaultWorkInfo;
  WorkInfo get workInfo => _workInfo;
  void updateInfo(WorkInfo newworkInfo) {
    _workInfo = newworkInfo;
    notifyListeners();
  }
}

/// 作品收藏操作通知器
class WorkBookmarkModel with ChangeNotifier {
  bool _bookmarked = false;
  int _workId = 114514;
  String _userName = 'Man';

  bool get bookmarked => _bookmarked;
  int get workId => _workId;
  String get userName => _userName;

  void changebookmark(bool bookmarked, int workId, String userName) {
    _bookmarked = bookmarked;
    _workId = workId;
    _userName = userName;
    notifyListeners();
  }
}

/*
class CmdData extends InheritedWidget {
  const CmdData({
    super.key,
    required this.data,
    required super.child,
  });
  
  final Map<String,String> data;

  static CmdData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CmdData>();
  }

  static CmdData of(BuildContext context) {
    final CmdData? result = maybeOf(context);
    assert(result != null, 'No data found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CmdData oldWidget) => data != oldWidget.data;
}*/

/// stack 变更通知器
class StackChangeNotifier with ChangeNotifier {
  late final int _mainTabCount;
  int historyIndex = 0;
  //int _lastremoved = -1;
  // index of stake that not be removed
  final List<int> alive = [];

  final List<String> _titles = [];
  final List<StackData> _stackDatas = [];
  List<int> _loadedIndex = [];
  int _index = 0;

  int get mainTabCount => _mainTabCount;
  List<String> get titles => _titles;
  List<StackData> get stackDatas => _stackDatas;
  List<int> get loadedIndex => _loadedIndex;
  int get index => _index;
  //int get lastremoved => _lastremoved;

  void initData(
      int mainTabCount, List<StackData> stackDatas, List<int> preloadIndexes) {
    _mainTabCount = mainTabCount;
    _stackDatas.addAll(stackDatas);
    _loadedIndex = preloadIndexes;
  }

  void addStack(String title, Widget newStack) {
    _stackDatas.add(
        StackData(index: _stackDatas.length, title: title, child: newStack));
    _titles.add(title);
    _index = _stackDatas.length - 1;
    alive.add(_index - _mainTabCount);
    notifyListeners();
  }

  void removeAt(int findex) {
    //_lastremoved = index + _mainTabCount;
    int trueindex = alive[findex];
    _titles.removeAt(findex);
    alive.removeAt(findex);

    // jump removed widgets
    /*
    int count = index;
    while (count >= 0) {
      if (stackDatas[index + _mainTabCount].notRemoved) {
        count--;
        continue;
      }
      index++;
    }*/

    // update current index
    // is tail
    //if (newindex + _mainTabCount == _stackDatas.length) {
    if (findex == alive.length) {
      if (alive.isEmpty) {
        _index = historyIndex;
      } else {
        //_index--;
        _index = alive[findex - 1] + _mainTabCount;
      }
    }
    // medium
    else {
      // next one
      _index = alive[findex] + _mainTabCount;
    }

    /*else {
      // update following children
      for (StackData data in _stackDatas.sublist(newindex + _mainTabCount)) {
        data.index--;
      }
    }*/

    //_stackDatas.removeAt(index + _mainTabCount);

    // use Container replace child
    _stackDatas[trueindex + _mainTabCount].child = Container();
    _stackDatas[trueindex + _mainTabCount].notRemoved = false;

    // update loadedindexs
    for (int i = 0; i < _loadedIndex.length; i++) {
      if (trueindex == _loadedIndex[i]) {
        loadedIndex.removeAt(i);
      } else if (trueindex < _loadedIndex[i]) {
        _loadedIndex[i]--;
      }
    }
    notifyListeners();
  }

  void changeIndex(int findex, bool ismainTabs) {
    if (ismainTabs) {
      _index = findex;
      historyIndex = findex;
    } else {
      int trueindex = alive[findex];
      _index = trueindex + _mainTabCount;
    }
    notifyListeners();
  }

  void updateLoadedIndex(int index) {
    _loadedIndex.add(index);
  }
}

/// UI设置更新通知器
class UIConfigUpdateNotifier with ChangeNotifier {
  // late final MainConfigs _configs;
  late final UIConfigs _uiConfigs;

  // MainConfigs get configs => _configs;
  UIConfigs get uiConfigs => _uiConfigs;

  void initconfigs(UIConfigs uiConfigs) {
    // _configs = configs;
    _uiConfigs = uiConfigs;
    notifyListeners();
  }

  /*
  void updateMainConfigs(String key, dynamic value) {
    // TODO 不需要通知
    if (key == 'savePath') {
      _configs.savePath = value;
    }
    else if (key == 'cookies') {
      _configs.cookies = value;
    } else if (key == 'enableProxy') {
      _configs.enableProxy = value;
    } else if (key == 'httpProxies') {
      _configs.httpProxies = value;
    } else if (key == 'httpsProxies') {
      _configs.httpsProxies = value;
    } else if (key == 'semaphore') {
      _configs.semaphore = value;
    } else if (key == 'downloadType') {
      _configs.downloadType = value;
    } else if (key == 'lastRecordTime') {
      _configs.lastRecordTime = value;
    } else if (key == 'enableClientPool') {
      _configs.enableClientPool = value;
    } else if (key == 'clientPool') {
      _configs.clientPool = value;
    } else {
      throw 'Invalid key!';
    }
    // notifyListeners();
  }
  */
  void updateUiConfigsMap(Map<String, dynamic> updates) {
    for (MapEntry entry in updates.entries) {
      if (entry.key == 'autoOpen') {
        _uiConfigs.autoOpen = entry.value;
      } else if (entry.key == 'autoSearch') {
        _uiConfigs.autoSearch = entry.value;
      } else if (entry.key == 'imageCacheRate') {
        _uiConfigs.imageCacheRate = entry.value;
      } else if (entry.key == 'fontSize') {
        _uiConfigs.fontSize = entry.value;
      } else {
        throw 'Invalid key!';
      }
    }

    notifyListeners();
  }

  void updateUiConfigs(String key, dynamic value) {
    if (key == 'autoOpen') {
      _uiConfigs.autoOpen = value;
    } else if (key == 'autoSearch') {
      _uiConfigs.autoSearch = value;
    } else if (key == 'imageCacheRate') {
      _uiConfigs.imageCacheRate = value;
    } else if (key == 'fontSize') {
      _uiConfigs.fontSize = value;
    } else {
      throw 'Invalid key!';
    }

    notifyListeners();
  }
}
