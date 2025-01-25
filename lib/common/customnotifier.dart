import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:localpixiv/pages/user_detail_page.dart';
import 'package:localpixiv/pages/work_detail_page.dart';
import 'package:localpixiv/settings/settings_controller.dart';
import 'package:localpixiv/widgets/super_tabview.dart';
import '../models.dart';

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

class AddStackNotifier with ChangeNotifier {
  late String _newTitle;
  late Widget _newStack;
  late SettingsController _controller;
  late Db _pixivDb;
  late WorkBookmarkCallback _onWorkBookmarked;
  bool needAdd = false;

  TabData? get newData {
    if (needAdd) {
      needAdd = false;
      return TabData(title: _newTitle, canBeClosed: true, child: _newStack);
    } else {
      return null;
    }
  }

  void init(SettingsController controller, Db pixivDb,
      WorkBookmarkCallback onWorkBookmarked) {
    _controller = controller;
    _pixivDb = pixivDb;
    _onWorkBookmarked = onWorkBookmarked;
  }

  void addStack<T extends Widget>(
      String title, Map<String, dynamic> arguments) {
    _newTitle = title;
    if (T == WorkDetailPage) {
      assert(arguments.containsKey('workInfo'), 'Argument error.');
      _newStack = WorkDetailPage(
        controller: _controller,
        workInfo: arguments['workInfo'],
        onBookmarked: _onWorkBookmarked,
      );
    } else if (T == UserDetailPage) {
      _newStack = UserDetailPage(
          controller: _controller,
          userInfo: arguments['userInfo'],
          userName: arguments['userName'],
          pixivDb: _pixivDb,
          onWorkBookmarked: _onWorkBookmarked);
    } else {
      throw 'Unsupport Widget!';
    }
    needAdd = true;
    notifyListeners();
  }
}
