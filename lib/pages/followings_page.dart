import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, where;
import 'package:provider/provider.dart';

import '../widgets/page_displayer.dart';
import '../containers/user_container.dart';
import '../common/customnotifier.dart';
import '../common/defaultdatas.dart';
import '../common/tools.dart';
import '../models.dart';
import '../settings/settings_controller.dart';
import 'user_detail_page.dart';

/// A page to show brief information about following users.
class FollowingsPage extends StatefulWidget {
  const FollowingsPage({
    super.key,
    required this.controller,
    required this.pixivDb,
    required this.onBookmarked,
  });
  final SettingsController controller;
  final Db pixivDb;
  final WorkBookmarkCallback onBookmarked;

  @override
  State<StatefulWidget> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  // 初始化
  int maxpage = 1;
  int reslength = 0;
  final int pagesize = 8;
  final int workCountOnShow = 4;
  final ListNotifier<UserInfo> userInfosNotifer = ListNotifier<UserInfo>([]);
  final List<UserInfo> userInfos = [];

  void dataLoader() async {
    final DbCollection followingCollection =
        widget.pixivDb.collection('All Followings');
    // 计算page
    reslength = await followingCollection.count(where.exists('userName'));
    maxpage = (reslength / pagesize).ceil();
    // 异步加载数据
    Stream<Map<String, dynamic>> followings = followingCollection
        .find(where.exists('userName').excludeFields(['_id']));
    followings.forEach((following) {
      if (following['newestWorks'] != null) {
        final List<WorkInfo> workInfo = [
          for (Map<String, dynamic> workinfojson in following['newestWorks'])
            WorkInfo.fromJson(workinfojson)
        ];
        // 检查workInfos数量是否正常
        assert(workInfo.length <= workCountOnShow);
        if (workInfo.length < workCountOnShow) {
          workInfo.addAll([
            for (int i = workInfo.length; i <= workCountOnShow; i++)
              defaultWorkInfo
          ]);
        }
        following['workInfos'] = workInfo;
        userInfos.add(UserInfo.fromJson(following));
      } else {
        fetchUserInfo(following, widget.pixivDb).then((userInfo) {
          userInfos.add(userInfo);
        });
      }
    });
    // 当有足够数据或加载完成时显示
    Timer.periodic(Durations.medium1, (timer) {
      if ((userInfos.length > pagesize) || (userInfos.length == reslength)) {
        setState(() {
          changePage(1);
          timer.cancel();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    dataLoader();
  }

  void changePage(int page) {
    List<UserInfo> info = [];
    if (userInfos.length >= page * pagesize) {
      info = userInfos.sublist((page - 1) * pagesize, page * pagesize);
      for (int i = 0; i < pagesize; i++) {}
    } else {
      info = userInfos.sublist((page - 1) * pagesize, userInfos.length);
      if (info.length < pagesize) {
        info.addAll([
          for (int i = info.length; i < pagesize; i++) defaultUserInfo,
        ]);
      }
    }
    userInfosNotifer.setList(info);
  }

  @override
  Widget build(BuildContext context) {
    void openTabCallback(String userName) {
      context
          .read<SuperTabViewNotifier>()
          .addStack<UserDetailPage>(userName, {'userName': userName});
    }

    return Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
            valueListenable: userInfosNotifer,
            builder: (context, userInfos, child) {
              if (userInfos.length < pagesize) {
                return SizedBox();
              }

              return PageDisplayer(
                maxPage: maxpage,
                pageSize: pagesize,
                columnCount: 1,
                onPageChange: (page) => changePage(page),
                scrollable: true,
                children: [
                  for (UserInfo userInfo in userInfos)
                    UserContainer(
                      height: 240,
                      controller: widget.controller,
                      userInfo: userInfo,
                      onTab: (userName) => openTabCallback(userName),
                      onWorkBookmarked: widget.onBookmarked,
                    ),
                ],
              );
            }));
  }
}
