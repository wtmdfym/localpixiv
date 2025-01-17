import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/defaultdatas.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/page_controller_row.dart';
import 'package:localpixiv/widgets/userdisplayer.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';

class FollowingsDisplayer extends StatefulWidget {
  const FollowingsDisplayer(
      {super.key,
      required this.hostPath,
      required this.cacheRate,
      required this.pixivDb});
  final String hostPath;
  final double cacheRate;
  final mongo.Db pixivDb;
  @override
  State<StatefulWidget> createState() => _FollowingsDisplayerState();
}

class _FollowingsDisplayerState extends State<FollowingsDisplayer> {
  // 初始化
  ValueNotifier<int> maxpage = ValueNotifier(1);
  int reslength = 0;
  final int pagesize = 8;
  final ListNotifier<UserInfo> userInfosNotifer = ListNotifier([
    defaultUserInfo,
    defaultUserInfo,
    defaultUserInfo,
    defaultUserInfo,
  ]);
  final List<UserInfo> userInfos = [];

  void dataLoader() async {
    mongo.DbCollection followingCollection =
        widget.pixivDb.collection('All Followings');
    // 计算page
    reslength = await followingCollection.count(mongo.where.exists('userName'));
    maxpage.value = (reslength / pagesize).ceil();
    // 异步加载数据
    Stream<Map<String, dynamic>> followings = followingCollection
        .find(mongo.where.exists('userName').excludeFields(['_id']));
    followings.forEach((following) {
      if (following['newestWorks'] != null) {
        final List<WorkInfo> workInfo = [
          for (Map<String, dynamic> workinfojson in following['newestWorks'])
            WorkInfo.fromJson(workinfojson)
        ];
        // 检查workInfos数量是否正常
        assert(workInfo.length <= 4);
        if (workInfo.length < 4) {
          workInfo.addAll(
              [for (int i = workInfo.length; i <= 4; i++) defaultWorkInfo]);
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
      if ((userInfos.length > 4) || (userInfos.length == reslength)) {
        changePage(1);
        timer.cancel();
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
      context.read<StackChangeNotifier>().addStack(
          userName,
          UserDetailsDisplayer2(
            hostPath: widget.hostPath,
            userName: userName,
            pixivDb: widget.pixivDb,
            cacheRate: widget.cacheRate,
            onWorkBookmarked: (isLiked, workId, userName) =>
                Provider.of<WorkBookmarkModel>(context, listen: false)
                    .changebookmark(
              isLiked,
              workId,
              userName,
            ),
          ));
    }

    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: ValueListenableBuilder(
                    valueListenable: userInfosNotifer,
                    builder: (context, userInfos, child) => ListView.separated(
                          padding: EdgeInsets.only(left: 12, right: 20),
                          shrinkWrap: true,
                          itemCount: pagesize,
                          itemBuilder: (context, index) =>
                              FollowingInfoDisplayer(
                            hostPath: widget.hostPath,
                            cacheRate: widget.cacheRate,
                            userInfo: userInfos[index],
                            onTab: (userName) => openTabCallback(userName),
                            onWorkBookmarked: (isLiked, workId, userName) =>
                                Provider.of<WorkBookmarkModel>(context,
                                        listen: false)
                                    .changebookmark(
                              isLiked,
                              workId,
                              userName,
                            ),
                          ),
                          separatorBuilder: (context, index) => Divider(),
                        ))),
            // 翻页控件
            PageControllerRow(
              maxpage: maxpage,
              pagesize: pagesize,
              onPageChange: (page) => changePage(page),
            )
          ],
        ));
  }
}
