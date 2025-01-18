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
class ListNotifier<T> extends ValueNotifier<List<T>> {
  ListNotifier(super._value);

  void setList(List<T> newList) {
    value = newList;
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

enum StackOperation { init, add, remove, changeIndex }

/// stack 变更通知器

class StackChangeNotifier with ChangeNotifier {
  late final int _mainTabCount;
  StackOperation operation = StackOperation.init;
  final List<String> _titles = [];
  final List<StackData> _stackDatas = [];
  int _index = 0;
  int _historyIndex = 0;
  int _removeIndex = 0;

  int get mainTabCount => _mainTabCount;
  List<String> get titles => _titles;
  List<StackData> get stackDatas => _stackDatas;
  int get index => _index;
  int get removeIndex => _removeIndex;

  void initData(
      int mainTabCount, List<StackData> stackDatas, int initialIndex) {
    _mainTabCount = mainTabCount;
    _stackDatas.addAll(stackDatas);
    _index = initialIndex;
  }

  void addStack(String title, Widget newStack) {
    _stackDatas.add(
        StackData(index: _stackDatas.length, title: title, child: newStack));
    _titles.add(title);
    _index = _stackDatas.length - 1;
    operation = StackOperation.add;
    notifyListeners();
  }

  void removeAt(int findex) {
    _titles.removeAt(findex);
    // update current index
    // is tail
    if (findex == _titles.length) {
      if (_titles.isEmpty) {
        _index = _historyIndex;
      } else {
        _index--;
      }
    }
    // medium
    else {
      // next one
      _index = findex + _mainTabCount;
    }
    _stackDatas.removeAt(findex + _mainTabCount);
    _removeIndex = findex + _mainTabCount;
    operation = StackOperation.remove;
    notifyListeners();
  }

  void changeIndex(int findex, bool ismainTabs) {
    if (ismainTabs) {
      _index = findex;
      _historyIndex = findex;
    } else {
      _index = findex + _mainTabCount;
    }
    operation = StackOperation.changeIndex;
    notifyListeners();
  }
}
