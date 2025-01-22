import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, DbCollection, where;
import 'package:provider/provider.dart';

import '../containers/user_container.dart';
import '../common/customnotifier.dart';
import '../common/defaultdatas.dart';
import '../common/tools.dart';
import '../models.dart';
import '../settings/settings_controller.dart';
import '../widgets/page_controller_row.dart';
import 'user_detail_page.dart';

class FollowingsDisplayer extends StatefulWidget {
  const FollowingsDisplayer({
    super.key,
    required this.controller,
    required this.pixivDb,
    required this.onBookmarked,
  });
  final SettingsController controller;
  final Db pixivDb;
  final WorkBookmarkCallback onBookmarked;

  @override
  State<StatefulWidget> createState() => _FollowingsDisplayerState();
}

class _FollowingsDisplayerState extends State<FollowingsDisplayer> {
  // 初始化
  int maxpage = 1;
  int reslength = 0;
  final int pagesize = 8;
  final int workCountOnSisplay = 4;
  late final ListNotifier<UserInfo> userInfosNotifer;
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
        assert(workInfo.length <= pagesize);
        if (workInfo.length < pagesize) {
          workInfo.addAll([
            for (int i = workInfo.length; i <= workCountOnSisplay; i++)
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
        changePage(1);
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    userInfosNotifer =
        ListNotifier([for (int i = 0; i <= pagesize; i++) defaultUserInfo]);
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
          .read<AddStackNotifier>()
          .addStack<UserDetailPage>(userName, {'userName': userName});
    }

    return Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: userInfosNotifer,
          builder: (context, userInfos, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.only(right: 12),
                shrinkWrap: true,
                itemCount: pagesize,
                cacheExtent: 240,
                itemBuilder: (context, index) => UserContainer(
                  height: 240,
                  controller: widget.controller,
                  userInfo: userInfos[index],
                  onTab: (userName) => openTabCallback(userName),
                  onWorkBookmarked: widget.onBookmarked,
                ),
              )),
              // 翻页控件
              PageControllerRow(
                maxpage: maxpage,
                pagesize: pagesize,
                onPageChange: (page) => changePage(page),
              )
            ],
          ),
        ));
  }
}
