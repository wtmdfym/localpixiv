import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/common/tools.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/workcontainer.dart';
import 'package:provider/provider.dart';
//import 'package:mongo_dart/mongo_dart.dart' as mongo;

class FollowingInfoDisplayer extends StatefulWidget {
  const FollowingInfoDisplayer({
    super.key,
    required this.hostPath,
    this.width = 200,
    this.height = 200,
    //required this.userInfoNotifer
    required this.userInfo,
  });
  final String hostPath;
  final double width;
  final double height;
  //final UserInfoNotifier userInfoNotifer;
  final UserInfo userInfo;
  @override
  State<StatefulWidget> createState() => _FollowingInfoDisplayerState();
}

class _FollowingInfoDisplayerState extends State<FollowingInfoDisplayer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late AnimationController _mouseClickAnimationController;
  //final List<WorkInfoNotifier> workInfoNotifers = [];
  final List<WorkInfo> workInfos = [];
  //TODO not following user
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
    /*workInfoNotifers.addAll([
      for (WorkInfo workInfo
          in widget.userInfoNotifer.value.workInfos.sublist(0, 4))
        WorkInfoNotifier(workInfo)
    ]);*/

    /*widget.userInfoNotifer.addListener(() {
      for (int index = 0; index < 4; index++) {
        try {
          //workInfoNotifers[index].value =
          workInfos[index]=
              widget.userInfoNotifer.value.workInfos[index];
        } catch (e) {
          assert(e.toString().contains('RangeError (length)'));
        }
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    workInfos.clear();
    workInfos.addAll(widget.userInfo.workInfos.sublist(0, 4));
    void showUserDetail() {
      //List<dynamic>? imagePaths = widget.workInfoNotifier.value.imagePath;
      UserInfo userInfo = widget.userInfo; //widget.userInfoNotifer.value;
      //WorkInfo info = widget.userInfoNotifer.value.workInfos[0];
      //userInfo.workInfos = [for (int i = 0; i < 50; i++) info];
      /*Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false,
            builder: (context) => UserDetailsDisplayer(
                hostPath: widget.hostPath, userInfo: userInfo)));*/
      context.read<StackChangeNotifier>().addStack(userInfo.userName,
          UserDetailsDisplayer(hostPath: widget.hostPath, userInfo: userInfo));
    }

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
              onTap: () => showUserDetail(),
              //onDoubleTap: () {},
              child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: widget.userInfo.notFollowingNow
                              ? Colors.brown
                              : Colors.grey[350]),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          //TODO 封装为单个widget
                          SizedBox(
                              width: 240,
                              height: 240,
                              child: FutureBuilder<ImageProvider>(
                                  future: imageFileLoader(
                                    '${widget.hostPath}${widget.userInfo.profileImage}',
                                    240,
                                    240,
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<ImageProvider> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Image(
                                        image: snapshot.data!,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          if (error.toString() ==
                                              'Exception: Codec failed to produce an image, possibly due to invalid image data.') {
                                            File('${widget.hostPath}${widget.userInfo.profileImage}')
                                                .delete();
                                          }
                                          return Center(
                                              child: Text(
                                            '${error.toString()} It will be deleted automatically.',
                                            style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 20),
                                          ));
                                        },
                                      ).animate().fadeIn(duration: 500.ms);
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  })),
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              width: 480,
                              child: Column(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 异步加载图片
                                  SelectableText(
                                    'UserName: ${widget.userInfo.userName //widget.userInfoNotifer.value.userName
                                    }',
                                    style: TextStyle(fontSize: 24),
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: 220,
                                    child: SingleChildScrollView(
                                        child: SelectableText(
                                      widget.userInfo.userComment,
                                      //userInfoNotifer.value.userComment,
                                      style: TextStyle(fontSize: 20),
                                    )),
                                  )
                                ],
                              )),
                          ImageContainer(
                            hostPath: widget.hostPath,
                            workInfo: workInfos[0],
                            width: 360,
                            height: 270,
                            backgroundColor: Colors.white,
                          ),
                          ImageContainer(
                            hostPath: widget.hostPath,
                            workInfo: workInfos[1],
                            width: 360,
                            height: 270,
                            backgroundColor: Colors.white,
                          ),
                          ImageContainer(
                            hostPath: widget.hostPath,
                            workInfo: workInfos[2],
                            width: 360,
                            height: 270,
                            backgroundColor: Colors.white,
                          ),
                          ImageContainer(
                            hostPath: widget.hostPath,
                            workInfo: workInfos[3],
                            width: 360,
                            height: 270,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ))
                  .animate(
                      controller: _mouseEOAnimationController, autoPlay: false)
                  //.color(blendMode: BlendMode.darken)
                  //.scaleX(begin: 1.0, end: 1.02)
                  .scaleXY(begin: 1.0, end: 1.02, duration: 100.ms)
                  .animate(
                      controller: _mouseClickAnimationController,
                      autoPlay: false)
                  .color(duration: 50.ms, blendMode: BlendMode.darken),
            )));
  }
}

class UserDetailsDisplayer extends StatefulWidget {
  const UserDetailsDisplayer({
    super.key,
    required this.hostPath,
    required this.userInfo,
    //required this.pixivDb
  });
  final String hostPath;
  final UserInfo userInfo;

  //final mongo.Db pixivDb;
  @override
  State<StatefulWidget> createState() => _UserDetailsDisplayerState();
}

class _UserDetailsDisplayerState extends State<UserDetailsDisplayer>
    with TickerProviderStateMixin {
  int rawCount = 6;
  int onceLoad = 4;
  int loadIndex = 0;
  ValueNotifier<int> pages = ValueNotifier(0);
  List<WorkInfo> loadedList = [];
  void _retrieveData() {
    Future.delayed(Durations.medium1, () {
      if ((loadIndex + 1) * onceLoad * rawCount <=
          widget.userInfo.workInfos.length) {
        loadedList.addAll(widget.userInfo.workInfos.sublist(
            loadIndex * rawCount * onceLoad,
            (loadIndex + 1) * rawCount * onceLoad));
      } else {
        loadedList.addAll(widget.userInfo.workInfos.sublist(
            loadIndex * rawCount * onceLoad, widget.userInfo.workInfos.length));
      }
      loadIndex++;
      pages.value = (loadedList.length / rawCount).ceil();
    });
  }

  @override
  void initState() {
    super.initState();
    _retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    int totalloadCount =
        (widget.userInfo.workInfos.length / rawCount / onceLoad).ceil();
    //(widget.userInfo.workInfos.length / rawCount).ceil();
    return Material(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: FittedBox(
              child: //Stack(
                  //children: [
                  SizedBox(
                      width: 2560,
                      height: 1280,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 30,
                          children: [
                            //Divider(
                            //  height: 30,
                            //),
                            Row(
                              spacing: 30,
                              children: [
                                SizedBox(
                                    width: 240,
                                    height: 240,
                                    child: FutureBuilder<ImageProvider>(
                                        future: imageFileLoader(
                                          '${widget.hostPath}${widget.userInfo.profileImage}',
                                          240,
                                          240,
                                        ),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<ImageProvider>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return Image(
                                              image: snapshot.data!,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                if (error.toString() ==
                                                    'Exception: Codec failed to produce an image, possibly due to invalid image data.') {
                                                  File('${widget.hostPath}${widget.userInfo.profileImage}')
                                                      .delete();
                                                }
                                                return Center(
                                                    child: Text(
                                                  '${error.toString()} It will be deleted automatically.',
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 20),
                                                ));
                                              },
                                            )
                                                .animate()
                                                .fadeIn(duration: 500.ms);
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        })),
                                Expanded(
                                    child: Text(
                                  'UserName: ${widget.userInfo.userName}',
                                  style: TextStyle(fontSize: 24),
                                )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.userInfo.userComment,
                                      style: TextStyle(fontSize: 20),
                                    )),
                              ],
                            ),

                            ValueListenableBuilder(
                                valueListenable: pages,
                                builder: (context, value, child) => Expanded(
                                    flex: 9,
                                    child: ListView.separated(
                                      itemCount: value + 1,
                                      itemBuilder: (context, index) {
                                        if (index == value) {
                                          if (loadIndex + 1 < totalloadCount) {
                                            _retrieveData();
                                            return Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 48,
                                                height: 48,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 6),
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                height: 48,
                                                child: Text(
                                                  'No more data',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if ((index + 1) * rawCount <=
                                              loadedList.length) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                for (WorkInfo info
                                                    in loadedList.sublist(
                                                        index * rawCount,
                                                        (index + 1) * rawCount))
                                                  ImageContainer(
                                                    hostPath: widget.hostPath,
                                                    workInfo: info,
                                                  )
                                              ],
                                            );
                                          } else {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              spacing: 16,
                                              children: [
                                                for (WorkInfo info
                                                    in loadedList.sublist(
                                                        index * rawCount,
                                                        loadedList.length))
                                                  ImageContainer(
                                                    hostPath: widget.hostPath,
                                                    workInfo: info,
                                                  )
                                              ],
                                            );
                                          }
                                        }
                                      },
                                      /*
                      itemCount: pages > 1 ? onceLoad + 1 : pages,
                      itemBuilder: (context, index) {
                        if (index == onceLoad + 1) {
                          _retrieveData();
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.0),
                            ),
                          );
                        } else {
                          List<Widget> rowList = [];
                          if ((index + 1) * rawCount <=
                              widget.userInfo.workInfos.length) {
                            rowList.addAll([
                              for (WorkInfo info in widget.userInfo.workInfos
                                  .sublist(
                                      index * rawCount, (index + 1) * rawCount))
                                ImageContainer(
                                  hostPath: widget.hostPath,
                                  workInfoNotifier: WorkInfoNotifier(info),
                                )
                            ]);
                          } else {
                            rowList.addAll([
                              for (WorkInfo info in widget.userInfo.workInfos
                                  .sublist(index * rawCount,
                                      widget.userInfo.workInfos.length))
                                ImageContainer(
                                  hostPath: widget.hostPath,
                                  workInfoNotifier: WorkInfoNotifier(info),
                                )
                            ]);
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 16,
                            children: rowList,
                          );
                        }
                      },*/
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        height: 16,
                                      ),
                                    )))
                          ])),
              /*Positioned(
                      top: 10,
                      left: 10,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          //setState(() {});
                        },
                        label: Text(
                          'Back',
                          style: TextStyle(fontSize: 30, color: Colors.grey),
                        ),
                        icon: Icon(Icons.arrow_back,
                            size: 30, color: Colors.grey),
                      )),
                ],
              ),*/
            )));
  }
}
