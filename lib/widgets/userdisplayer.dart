import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, where;

import '../settings/settings_controller.dart';
import '../common/defaultdatas.dart';
import '../common/tools.dart';
import '../models.dart';
import 'divided_stack.dart';
import 'should_rebuild_widget.dart';
import 'workloader.dart';
import 'workcontainer.dart';

class FollowingInfoDisplayer extends StatefulWidget {
  const FollowingInfoDisplayer({
    super.key,
    required this.controller,
    this.width = 2320,
    this.height = 300,
    required this.userInfo,
    required this.onTab,
    required this.onWorkBookmarked,
  });
  final SettingsController controller;
  final int width;
  final int height;
  final UserInfo userInfo;
  final OpenTabCallback onTab;
  final WorkBookmarkCallback onWorkBookmarked;
  @override
  State<StatefulWidget> createState() => _FollowingInfoDisplayerState();
}

class _FollowingInfoDisplayerState extends State<FollowingInfoDisplayer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late AnimationController _mouseClickAnimationController;
  final List<WorkInfo> workInfos = [];

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _mouseEOAnimationController = AnimationController(
      vsync: this,
    );
    _mouseClickAnimationController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _mouseEOAnimationController.dispose();
    _mouseClickAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    workInfos.clear();
    workInfos.addAll(widget.userInfo.workInfos.sublist(0, 4));

    return MouseRegion(
        // 进入
        onEnter: (details) => _mouseEOAnimationController.forward(),
        // 离开
        onExit: (details) => _mouseEOAnimationController.reverse(),
        // onHover: (event) => print('object'),
        child: FittedBox(
            clipBehavior: Clip.hardEdge,
            child: GestureDetector(
              // 点击事件监听
              onTapDown: (details) => _mouseClickAnimationController.forward(),
              onTapUp: (details) => _mouseClickAnimationController.reverse(),
              onTapCancel: () => _mouseClickAnimationController.reverse(),
              onTap: () => widget.onTab(widget.userInfo.userName),
              //onDoubleTap: () {},
              child: Container(
                      width: widget.width.toDouble(),
                      height: widget.height.toDouble(),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: widget.userInfo.notFollowingNow
                              ? Colors.brown
                              : Colors.grey[350]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          // 作者头像
                          SizedBox(
                              width: 240,
                              height: 240,
                              child: ImageLoader(
                                path:
                                    '${widget.controller.hostPath}${widget.userInfo.profileImage}',
                                width: 240,
                                height: 240,
                                cacheRate: widget.controller.imageCacheRate,
                              )),
                          // 作者名字和描述
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              width: 480,
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    widget.userInfo.userName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium
                                    /*TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: )*/
                                    ,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    width: 480,
                                    height: 200,
                                    child: SingleChildScrollView(
                                        child: SelectableText(
                                      widget.userInfo.userComment,
                                    )),
                                  )
                                ],
                              )),
                          // 作者的最新作品
                          for (int i = 0; i < 4; i++)
                            Expanded(
                                child: WorkContainer(
                              hostPath: widget.controller.hostPath,
                              workInfo: workInfos[i],
                              width: 360,
                              height: widget.height - 20,
                              cacheRate: widget.controller.imageCacheRate,
                              onBookmarked: (isLiked, workId, userName) =>
                                  widget.onWorkBookmarked(
                                isLiked,
                                workId,
                                userName,
                              ),
                              backgroundColor: Colors.white,
                            )),
                        ],
                      ))
                  .animate(
                      controller: _mouseEOAnimationController, autoPlay: false)
                  .scaleX(begin: 1.0, end: 1.01, duration: 100.ms)
                  .scaleY(begin: 1.0, end: 1.02, duration: 100.ms)
                  .animate(
                      controller: _mouseClickAnimationController,
                      autoPlay: false)
                  .color(duration: 50.ms, blendMode: BlendMode.darken),
            )));
  }
}

class UserDetailsDisplayer extends StatefulWidget {
  UserDetailsDisplayer({
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
  State<StatefulWidget> createState() => _UserDetailsDisplayerState();
}

class _UserDetailsDisplayerState extends State<UserDetailsDisplayer> {
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
      padding: EdgeInsets.all(20),
      dividedDirection: Axis.vertical,
      leftWidget: Row(
        spacing: 30,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: ImageLoader(
              path: '${widget.controller.hostPath}${_userInfo.profileImage}',
              width: 240,
              height: 240,
              cacheRate: widget.controller.imageCacheRate,
            ),
          ),
          Expanded(
              child: Text(
            'UserName: ${_userInfo.userName}',
            style: Theme.of(context).textTheme.titleMedium,
          )),
          Expanded(
              flex: 2,
              child: Text(
                _userInfo.userComment,
              )),
        ],
      ),
      rightWidget: LayoutBuilder(builder: (context, constraints) {
        int newRawCount = (constraints.maxWidth / 400).ceil();

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
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: pages + 1,
                  itemBuilder: (context, index) {
                    if (index == pages) {
                      if (loadIndex + 1 < totalloadCount) {
                        _retrieveData();
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(strokeWidth: 6),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
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
                          padding: EdgeInsets.only(right: 20),
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
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 30,
                  ),
                );
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
                        padding: EdgeInsets.only(right: 20),
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
