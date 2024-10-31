import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:localpixiv/common/custom_notifier.dart';
import 'package:localpixiv/models.dart';

UserInfoNotifier abuserInfo = UserInfoNotifier(UserInfo(
    userId: '1',
    userName: '11',
    description: ' description',
    imagePath: ['picture/17596327/119867734_p0.jpg']));

class FollowingsDisplayer extends StatefulWidget {
  const FollowingsDisplayer({super.key});

  @override
  State<StatefulWidget> createState() => _FollowingsDisplayerState();
}

class _FollowingsDisplayerState extends State<FollowingsDisplayer> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: Padding(
            padding: EdgeInsetsDirectional.all(30),
            child: Flex(
              direction: Axis.vertical,
              spacing: 15,
              children: [
                FollowingInfoDisplayer(userInfo: abuserInfo),
                FollowingInfoDisplayer(userInfo: abuserInfo),
                FollowingInfoDisplayer(userInfo: abuserInfo),
                FollowingInfoDisplayer(userInfo: abuserInfo),
                ElevatedButton(onPressed: () {}, child: Text('test'))
              ],
            )));
  }
}

class FollowingInfoDisplayer extends StatefulWidget {
  const FollowingInfoDisplayer(
      {super.key, this.width = 200, this.height = 200, required this.userInfo});
  final double width;
  final double height;
  final UserInfoNotifier userInfo;

  @override
  State<StatefulWidget> createState() => _FollowingInfoDisplayerState();
}

class _FollowingInfoDisplayerState extends State<FollowingInfoDisplayer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late AnimationController _mouseClickAnimationController;
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
  Widget build(BuildContext context) {
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
                onTap: () {},
                child: ValueListenableBuilder(
                        valueListenable: widget.userInfo,
                        builder: (context, value, child) => Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[350]),
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 20,
                              children: [
                                //TODO作者头像？
                                Text(
                                  'data',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  widget.userInfo.value.description,
                                  style: TextStyle(fontSize: 20),
                                ),
                                Image.file(
                                  File(
                                      'E://pixiv/${widget.userInfo.value.imagePath[0]}'),
                                  height: widget.height,
                                  width: widget.width,
                                  fit: BoxFit.cover,
                                ),
                                Image.file(
                                  File(
                                      'E://pixiv/${widget.userInfo.value.imagePath[0]}'),
                                  height: widget.height,
                                  width: widget.width,
                                  fit: BoxFit.cover,
                                ),
                                Image.file(
                                  File(
                                      'E://pixiv/${widget.userInfo.value.imagePath[0]}'),
                                  height: widget.height,
                                  width: widget.width,
                                  fit: BoxFit.cover,
                                ),
                                Image.file(
                                  File(
                                      'E://pixiv/${widget.userInfo.value.imagePath[0]}'),
                                  height: widget.height,
                                  width: widget.width,
                                  fit: BoxFit.cover,
                                )
                              ],
                            )))
                    .animate(
                        controller: _mouseEOAnimationController,
                        autoPlay: false)
                    //.color(blendMode: BlendMode.darken)
                    //.scaleX(begin: 1.0, end: 1.02)
                    .scaleXY(begin: 1.0, end: 1.02, duration: 100.ms))));
  }
}

class UserDetailsDisplayer extends StatefulWidget {
  const UserDetailsDisplayer({super.key});

  @override
  State<StatefulWidget> createState() => _UserDetailsDisplayerState();
}

class _UserDetailsDisplayerState extends State<UserDetailsDisplayer> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
