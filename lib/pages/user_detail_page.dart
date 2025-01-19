import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, where;

import '../containers/info_container.dart';
import '../containers/work_container.dart';
import '../settings/settings_controller.dart';
import '../common/defaultdatas.dart';
import '../common/tools.dart';
import '../models.dart';
import '../widgets/divided_stack.dart';
import '../widgets/should_rebuild_widget.dart';

/// A page to show detail information about a user.
class UserDetailPage extends StatefulWidget {
  UserDetailPage({
    super.key,
    required this.controller,
    this.userInfo,
    this.userName,
    this.pixivDb,
    required this.onWorkBookmarked,
  }) {
    assert((userInfo != null) || ((pixivDb != null) && (userName != null)));
  }

  final SettingsController controller;
  final UserInfo? userInfo;
  final String? userName;
  final Db? pixivDb;
  final WorkBookmarkCallback onWorkBookmarked;

  @override
  State<StatefulWidget> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  int rawCount = 6;
  final int onceLoad = 4;
  late final ScrollController _scrollController = ScrollController();
  int loadIndex = 0;
  final ValueNotifier<int> pages = ValueNotifier(0);
  final List<WorkInfo> loadedList = [];
  UserInfo _userInfo = defaultUserInfo;
  // TODO 优化数据加载
  void _retrieveData() {
    Future.delayed(Durations.medium1, () {
      if ((loadIndex + 1) * onceLoad * rawCount <= _userInfo.workInfos.length) {
        loadedList.addAll(_userInfo.workInfos.sublist(
            loadIndex * rawCount * onceLoad,
            (loadIndex + 1) * rawCount * onceLoad));
      } else {
        loadedList.addAll(_userInfo.workInfos.sublist(
            loadIndex * rawCount * onceLoad, _userInfo.workInfos.length));
      }
      loadIndex++;
      pages.value = (loadedList.length / rawCount).ceil();
    });
  }

  late int totalloadCount;
  @override
  void initState() {
    super.initState();
    totalloadCount = (_userInfo.workInfos.length / rawCount / onceLoad).ceil();
    /*_scrollController.addListener(() {
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent * 0.75) {
        setState(() {
          _retrieveData();
        });
      }
    });*/
    if (widget.userInfo != null) {
      _userInfo = widget.userInfo!;
      _retrieveData();
    } else {
      widget.pixivDb!
          .collection('All Followings')
          .findOne(where.eq('userName', widget.userName).excludeFields(['_id']))
          .then((info) {
        fetchUserInfo(info!, widget.pixivDb!).then((userinfo) {
          setState(() {
            _userInfo = userinfo;
            _retrieveData();
            //loadedList = _userInfo.workInfos;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DividedStack(
      padding: const EdgeInsets.all(8),
      dividedDirection: Axis.vertical,
      leftWidget: UserInfoContainer(
          userInfo: _userInfo,
          hostPath: widget.controller.hostPath,
          imageCacheRate: widget.controller.imageCacheRate),
      rightWidget: LayoutBuilder(builder: (context, constraints) {
        int newRawCount = rawCount;
        if (constraints.maxWidth > 0) {
          newRawCount = (constraints.maxWidth / 400).ceil();
        }

        //pages.value = (loadedList.length / rawCount).ceil();
        return ShouldRebuildWidget(
            shouldRebuild: (oldWidget, newWidget) {
              if (rawCount != newRawCount) {
                rawCount = newRawCount;
                totalloadCount =
                    (_userInfo.workInfos.length / newRawCount / onceLoad)
                        .ceil();
                return true;
              } else {
                return false;
              }
            },
            child: ValueListenableBuilder(
              valueListenable: pages,
              builder: (context, value, child) {
                int pages = (loadedList.length / rawCount).ceil();
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: pages + 1,
                    itemBuilder: (context, index) {
                      if (index == pages) {
                        if (loadIndex + 1 < totalloadCount) {
                          _retrieveData();
                          return Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(strokeWidth: 6),
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 48,
                              child: Text(
                                'No more data',
                              ),
                            ),
                          );
                        }
                      } else {
                        List<WorkInfo> rowInfos;
                        if ((index + 1) * rawCount <= loadedList.length) {
                          rowInfos = loadedList.sublist(
                              index * rawCount, (index + 1) * rawCount);
                        } else {
                          rowInfos = loadedList.sublist(
                              index * rawCount, loadedList.length);
                        }
                        return Padding(
                            padding:
                                const EdgeInsets.only(right: 12, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 16,
                              children: [
                                for (WorkInfo info in rowInfos)
                                  Expanded(
                                      child: WorkContainer(
                                    hostPath: widget.controller.hostPath,
                                    workInfo: info,
                                    cacheRate: widget.controller.imageCacheRate,
                                    onBookmarked: (isLiked, workId, userName) =>
                                        widget.onWorkBookmarked(
                                      isLiked,
                                      workId,
                                      userName,
                                    ),
                                  ))
                              ],
                            ));
                      }
                    });
                //int pages = value;
                /*final List<Widget> children = [];
              for (int index = 0; index < pages; index++) {
                if (index == pages) {
                  if (loadIndex + 1 < totalloadCount) {
                    children.add(Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 6),
                      ),
                    ));
                  } else {
                    children.add(Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 48,
                        child: Text(
                          'No more data',
                        ),
                      ),
                    ));
                  }
                } else {
                  List<WorkInfo> rowInfos;
                  if ((index + 1) * rawCount <= loadedList.length) {
                    rowInfos = loadedList.sublist(
                        index * rawCount, (index + 1) * rawCount);
                  } else {
                    rowInfos =
                        loadedList.sublist(index * rawCount, loadedList.length);
                  }
                  children.addAll([
                    Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16,
                          children: [
                            for (WorkInfo info in rowInfos)
                              Expanded(
                                  child: WorkContainer(
                                hostPath: widget.hostPath,
                                workInfo: info,
                                onBookmarked: (isLiked, workId, userName) =>
                                    widget.onWorkBookmarked(
                                  isLiked,
                                  workId,
                                  userName,
                                ),
                              ))
                          ],
                        )),
                    Divider(
                      height: 30,
                    )
                  ]);
                }
              }
              return ListView(
                controller: _scrollController,
                children: children,
              );*/
              },
            ));
      }),
      additionalWidgets: [
        Positioned(
            right: 5,
            bottom: 5,
            child: IconButton(
              icon: Icon(Icons.arrow_upward),
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(125, 158, 158, 158))),
              onPressed: () => _scrollController.jumpTo(0),
            ))
      ],
    );
  }
}
