import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';

//自定义的作品信息变更捕捉器
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
    ///赋值 这里需要注意的是 如果没有给 ValueNotifier 赋值 WorkInfo 对象时
    /// value 会出现空指针异常
    value.id = id;

    ///通知更新
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

// 作品信息显示通知器
class ShowInfoNotification extends Notification {
  ShowInfoNotification(this.msg);
  final WorkInfo msg;
}

//自定义的作者信息变更捕捉器
class UserInfoNotifier extends ValueNotifier<UserInfo> {
  UserInfoNotifier(super.workInfo);

  void setInfo(UserInfo newinfo) {
    value = newinfo;
    notifyListeners();
  }

  void setInfoJson(Map<String, dynamic> json) {
    value.userId = json['userId'];
    value.userName = json['username'];
    value.description = json['description'];
    value.imagePath = json['relative_path'];
    notifyListeners();
  }
}

// 作品收藏操作通知器
class WorkBookMarkNotification extends Notification {
  WorkBookMarkNotification(this.id, this.userName, this.bookmarked);
  final int id;
  final String userName;
  final bool bookmarked;
}

// 标签搜索操作通知器
class TagSearchNotification extends Notification {
  TagSearchNotification(this.tag);
  final String tag;
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
}
class DataModel with ChangeNotifier {
  Map<String, String> _data = {};

  Map<String, String> get data => _data;

  void increment(newdata) {
    _data = newdata;
    notifyListeners(); // 通知监听者数据已改变
  }
}*/
