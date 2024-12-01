import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/userdisplayer.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

Map<String, dynamic> defaultuserdata = {
  "userId": "1",
  "userName": "Man",
  'profileImage': '',
  "userComment": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌+و(◠ڼ◠)٩ =꒰ঌ(🎀ᗜ v ᗜ 🌸)໒꒱✅\n" * 5,
  "workInfos": [
    WorkInfo.fromJson(defaultworkdata),
    WorkInfo.fromJson(defaultworkdata),
    WorkInfo.fromJson(defaultworkdata),
    WorkInfo.fromJson(defaultworkdata)
  ]
};

const defaultworkdata = {
  "type": "illust",
  "id": 114514,
  "title": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌",
  "description": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌+و(◠ڼ◠)٩ =꒰ঌ(🎀ᗜ v ᗜ 🌸)໒꒱✅",
  "tags": {
    "水着": "泳装",
    "女の子": "女孩子",
    "オリジナル": "原创",
    "太もも": "大腿",
    "海": "sea",
    "浮き輪": "游泳圈",
    "イラスト": "插画"
  },
  "userId": "114514",
  "username": "Man",
  "uploadDate": "2042",
  "likeData": true,
  "isOriginal": true,
  "imageCount": 1,
  "relative_path": ["what can I say"]
};

class FollowingsDisplayer extends StatefulWidget {
  const FollowingsDisplayer(
      {super.key, required this.hostPath, required this.pixivDb});
  final String hostPath;
  final mongo.Db pixivDb;
  @override
  State<StatefulWidget> createState() => _FollowingsDisplayerState();
}

class _FollowingsDisplayerState extends State<FollowingsDisplayer> {
  ///************************///
  ///*********初始化*********///
  ///************************///
  int page = 1;
  int maxpage = 1;
  int reslength = 0;
  final int pagesize = 4;
  final InfosNotifier<UserInfo> userInfosNotifer = InfosNotifier([
    UserInfo.fromJson(defaultuserdata),
    UserInfo.fromJson(defaultuserdata),
    UserInfo.fromJson(defaultuserdata),
    UserInfo.fromJson(defaultuserdata),
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
      userInfos.add(fetchUserInfo(following, widget.pixivDb));
    });
    // 当有足够数据或加载完成时显示
    Timer.periodic(Durations.medium1, (timer) {
      if ((userInfos.length > 4) || (userInfos.length < reslength)) {
        changePage();
        timer.cancel();
      }
    });
  } /*
    backendDataLoader(followings);
    Timer.periodic(Durations.medium1, (timer) {
      if (userInfos.length < reslength) {
        if (userInfos.length > 5) {
          changePage();
          timer.cancel();
        }
      } else {
        changePage();
        timer.cancel();
      }
    });
  }

  void backendDataLoader(Stream<Map<String, dynamic>> followings) async {
    followings.forEach((following) {
      if (following['not_following_now'] != null) {
        //TODO not following user
      } else {
        List<WorkInfo> workInfos = [];
        mongo.DbCollection userCollection =
            widget.pixivDb.collection(following['userName']);
        userCollection
            .find(mongo.where.exists('id').excludeFields(['_id']))
            .forEach((info) {
          workInfos.add(WorkInfo.fromJson(info));
        });
        following['workInfos'] = workInfos;
        following['profileImage'] = '';
        userInfos.add(UserInfo.fromJson(following));
      }
    });
  }*/

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
          for (int i = info.length; i < pagesize; i++)
            UserInfo.fromJson(defaultuserdata)
        ]);
      }
    }
    userInfosNotifer.setInfos(info);
    _pageController.text = '$page/$maxpage';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: FittedBox(
                child: ValueListenableBuilder(
                    valueListenable: userInfosNotifer,
                    builder: (context, userInfos, child) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 15,
                          children: [
                            FollowingInfoDisplayer(
                                hostPath: widget.hostPath,
                                userInfo: userInfos[0]),
                            FollowingInfoDisplayer(
                                hostPath: widget.hostPath,
                                userInfo: userInfos[1]),
                            FollowingInfoDisplayer(
                                hostPath: widget.hostPath,
                                userInfo: userInfos[2]),
                            FollowingInfoDisplayer(
                                hostPath: widget.hostPath,
                                userInfo: userInfos[3]),
                            //翻页控件
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
