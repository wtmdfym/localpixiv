import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
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
  List<UserInfoNotifier> userInfoNotifers = [
    UserInfoNotifier(UserInfo.fromJson(defaultuserdata)),
    UserInfoNotifier(UserInfo.fromJson(defaultuserdata)),
    UserInfoNotifier(UserInfo.fromJson(defaultuserdata)),
    UserInfoNotifier(UserInfo.fromJson(defaultuserdata)),
  ];
  final TextEditingController _pageController =
      TextEditingController(text: '1/1');
  final List<UserInfo> userInfos = [];

  void futherDataLoader() async {
    mongo.DbCollection followingCollection =
        widget.pixivDb.collection('All Followings');
    //TODO not following user
    int count = await followingCollection
        .count(mongo.where.exists('userName').notExists('not_following_now'));
    reslength = count;
    maxpage = (reslength / pagesize).ceil();
    Stream<Map<String, dynamic>> followings = followingCollection
        .find(mongo.where.exists('userName').excludeFields(['_id']));
    backendDataLoader(followings);
    Timer.periodic(Durations.medium1, (timer) {
      if (userInfos.length < reslength) {
        if (userInfos.length > 4) {
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
  }

  @override
  void initState() {
    super.initState();
    futherDataLoader();
  }

  /// ************************* ///
  /// *********翻页控制********* ///
  /// ************************* ///
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
    if (userInfos.length >= page * pagesize) {
      List<dynamic> info =
          userInfos.sublist((page - 1) * pagesize, page * pagesize);
      for (int i = 0; i < pagesize; i++) {
        userInfoNotifers[i].setInfo(info[i]);
      }
    }
    List<dynamic> info =
        userInfos.sublist((page - 1) * pagesize, userInfos.length);
    for (int i = 0; i < pagesize; i++) {
      try {
        userInfoNotifers[i].setInfo(info[i]);
      } on RangeError {
        userInfoNotifers[i].value = UserInfo.fromJson(defaultuserdata);
      }
    }

    _pageController.text = '$page/$maxpage';

    //print(page);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: FittedBox(
                // showinfo信号监听
                child: NotificationListener(
                    onNotification: (notification) {
                      return false;
                    },
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 15,
                      children: [
                        FollowingInfoDisplayer(
                            hostPath: widget.hostPath,
                            userInfoNotifer: userInfoNotifers[0]),
                        FollowingInfoDisplayer(
                            hostPath: widget.hostPath,
                            userInfoNotifer: userInfoNotifers[1]),
                        FollowingInfoDisplayer(
                            hostPath: widget.hostPath,
                            userInfoNotifer: userInfoNotifers[2]),
                        FollowingInfoDisplayer(
                            hostPath: widget.hostPath,
                            userInfoNotifer: userInfoNotifers[3]), //翻页控件
                        Row(
                          spacing: 300,
                          children: [
                            ElevatedButton.icon(
                              onPressed: prevPage,
                              icon: Icon(
                                Icons.navigate_before,
                                size: 30,
                              ),
                              label:
                                  Text('Prev', style: TextStyle(fontSize: 20)),
                            ),
                            SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: _pageController,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    labelText: "页码",
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
