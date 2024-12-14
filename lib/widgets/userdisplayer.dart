import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/widgets/divided_stack.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, where;

import 'package:localpixiv/common/defaultdatas.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/workloader.dart';
import 'package:localpixiv/widgets/workcontainer.dart';
import 'package:provider/provider.dart';

class FollowingInfoDisplayer extends StatefulWidget {
  const FollowingInfoDisplayer({
    super.key,
    required this.hostPath,
    this.width = 2320,
    this.height = 300,
    required this.cacheRate,
    required this.userInfo,
    required this.onTab,
    required this.onWorkBookmarked,
  });
  final String hostPath;
  final int width;
  final int height;
  final double cacheRate;
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
                                    '${widget.hostPath}${widget.userInfo.profileImage}',
                                width: 240,
                                height: 240,
                                cacheRate: widget.cacheRate,
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
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: context
                                                .watch<UIConfigUpdateNotifier>()
                                                .uiConfigs
                                                .fontSize +
                                            4),
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
                              hostPath: widget.hostPath,
                              workInfo: workInfos[i],
                              width: 360,
                              height: widget.height - 20,
                              cacheRate: widget.cacheRate,
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
    required this.hostPath,
    required this.cacheRate,
    this.userInfo,
    this.userName,
    this.pixivDb,
    required this.onWorkBookmarked,
  }) {
    assert((userInfo != null) || ((pixivDb != null) && (userName != null)));
  }

  final String hostPath;
  final double cacheRate;
  final UserInfo? userInfo;
  final String? userName;
  final Db? pixivDb;
  final WorkBookmarkCallback onWorkBookmarked;

  @override
  State<StatefulWidget> createState() => _UserDetailsDisplayerState();
}

class _UserDetailsDisplayerState extends State<UserDetailsDisplayer> {
  final int rawCount = 6;
  final int onceLoad = 4;
  late final ScrollController _scrollController = ScrollController();
  int loadIndex = 0;
  final ValueNotifier<int> pages = ValueNotifier(0);
  final List<WorkInfo> loadedList = [];
  UserInfo _userInfo = defaultUserInfo;
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

  @override
  void initState() {
    super.initState();
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
              path: '${widget.hostPath}${_userInfo.profileImage}',
              width: 240,
              height: 240,
              cacheRate: widget.cacheRate,
            ),
          ),
          Expanded(
              child: Text(
            'UserName: ${_userInfo.userName}',
            style: TextStyle(
                fontSize:
                    context.watch<UIConfigUpdateNotifier>().uiConfigs.fontSize +
                        4),
          )),
          Expanded(
              flex: 2,
              child: Text(
                _userInfo.userComment,
              )),
        ],
      ),
      rightWidget: LayoutBuilder(
        builder: (context, constraints) {
          int rawCount = (constraints.maxWidth / 400).ceil();
          int totalloadCount =
              (_userInfo.workInfos.length / rawCount / onceLoad).ceil();
          //pages.value = (loadedList.length / rawCount).ceil();
          return ValueListenableBuilder(
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
                                hostPath: widget.hostPath,
                                workInfo: info,
                                cacheRate: widget.cacheRate,
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
          );
        },
      ),
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
