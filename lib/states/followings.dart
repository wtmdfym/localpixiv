import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/defaultdatas.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/userdisplayer.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';

class FollowingsDisplayer extends StatefulWidget {
  const FollowingsDisplayer(
      {super.key,
      required this.hostPath,
      // required this.cacheRate,
      required this.pixivDb});
  final String hostPath;
  // final double cacheRate;
  final mongo.Db pixivDb;
  @override
  State<StatefulWidget> createState() => _FollowingsDisplayerState();
}

class _FollowingsDisplayerState extends State<FollowingsDisplayer> {
  // 初始化
  int page = 1;
  int maxpage = 1;
  int reslength = 0;
  final int pagesize = 4;
  final InfosNotifier<UserInfo> userInfosNotifer = InfosNotifier([
    defaultUserInfo,
    defaultUserInfo,
    defaultUserInfo,
    defaultUserInfo,
  ]);
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');
  final List<UserInfo> userInfos = [];

  void dataLoader() async {
    mongo.DbCollection followingCollection =
        widget.pixivDb.collection('All Followings');
    // 计算page
    reslength = await followingCollection.count(mongo.where.exists('userName'));
    maxpage = (reslength / pagesize).ceil();
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
        changePage();
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    dataLoader();
  }

  // 翻页控制
  void prevPage() {
    if (page > 1) {
      page -= 1;
      changePage();
    }
  }

  void jumpToPage() {
    int newpage =
        int.parse(_pageController.text.replaceFirst(RegExp('/.+'), ''));
    if (page == newpage) {
    } else if ((0 < newpage) && (newpage <= maxpage)) {
      page = newpage;
      changePage();
    } else {
      _pageController.text = '$page/$maxpage';
    }
  }

  void nextPage() {
    if (page < maxpage) {
      page += 1;
      changePage();
    }
  }

  void changePage() {
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
    userInfosNotifer.setInfos(info);
    _pageController.text = '$page/$maxpage';
  }

  @override
  Widget build(BuildContext context) {
    void openTabCallback(String userName) {
      context.read<StackChangeNotifier>().addStack(
          userName,
          UserDetailsDisplayer(
            hostPath: widget.hostPath,
            userName: userName,
            pixivDb: widget.pixivDb,
            // cacheRate: widget.cacheRate,
            onWorkBookmarked: (isLiked, workId, userName) =>
                Provider.of<WorkBookmarkModel>(context, listen: false)
                    .changebookmark(
              isLiked,
              workId,
              userName,
            ),
          ));
    }

    return Center(
        child: FittedBox(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: ValueListenableBuilder(
                    valueListenable: userInfosNotifer,
                    builder: (context, userInfos, child) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 15,
                          children: [
                            for (int i = 0; i < pagesize; i++)
                              FollowingInfoDisplayer(
                                hostPath: widget.hostPath,
                                // cacheRate: widget.cacheRate,
                                userInfo: userInfos[i],
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
                            // 翻页控件
                            Row(
                              spacing: 300,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: prevPage,
                                  icon: Icon(
                                    Icons.navigate_before,
                                    size: 30,
                                  ),
                                  label: Text('Prev',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: _pageController,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        labelText: "Page",
                                        //icon: Icon(Icons.search),
                                      ),
                                    )),
                                ElevatedButton.icon(
                                    onPressed: jumpToPage,
                                    icon: Icon(
                                      Icons.next_plan_outlined,
                                      size: 30,
                                    ),
                                    label: Text("Jump",
                                        style: TextStyle(fontSize: 20))),
                                ElevatedButton.icon(
                                    onPressed: nextPage,
                                    icon: Icon(
                                      Icons.navigate_next,
                                      size: 30,
                                    ),
                                    iconAlignment: IconAlignment.end,
                                    label: Text("Next",
                                        style: TextStyle(fontSize: 20))),
                              ],
                            )
                          ],
                        )))));
  }
}
