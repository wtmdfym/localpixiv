import 'package:flutter/material.dart';
import 'package:localpixiv/tools/custom_notifier.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';

////////////////////////////////
//    用于显示作品信息的容器    //
/////////////////////////////////
class InfoContainer extends StatefulWidget {
  const InfoContainer({
    super.key,
    required this.workInfo,
  });
  final WorkInfoNotifier workInfo;

  @override
  State<StatefulWidget> createState() {
    return InfoContainerState();
  }
}

class InfoContainerState extends State<InfoContainer> {
  /*
  const String title = widget.workInfo.title;
  const Map<String,String> tags = ;
  const String description = ;
  const String userId = ;
  const String userName = ;*/

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 600,
        child: ValueListenableBuilder(
          valueListenable: widget.workInfo,
          builder: (context, value, child) {
            return Text.rich(
                style: TextStyle(fontSize: 18),
                TextSpan(
                  text: 'Title: ${value.title}\n',
                  children: [
                    TextSpan(
                      text:
                          'UserId: ${value.userId}\nUserName: ${value.userName}\n',
                      style: TextStyle(color: Colors.lightBlue),
                      recognizer: TapGestureRecognizer(),
                    )
                  ],
                ));
          },
        ));
  }
}

/////////////////////////////////
//      用于展示作品的容器      //
/////////////////////////////////
class ImageContainer extends StatefulWidget {
  const ImageContainer({
    super.key,
    this.width = 400,
    this.height = 440,
    required this.workInfoNotifier,
  });
  final int width;
  final int height;
  final WorkInfoNotifier workInfoNotifier;
  @override
  State<StatefulWidget> createState() {
    return _ImageContainerState();
  }
}

class _ImageContainerState extends State<ImageContainer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late AnimationController _mouseClickAnimationController;

  Future<ResizeImage> _getImageFile() async {
    List<dynamic> imagePath = widget.workInfoNotifier.value.imagePath!;
    if (imagePath.isNotEmpty) {
      var file = File('E://pixiv/${imagePath[0]}');
      var exists = await file.exists();
      if (exists) {
        ResizeImage img = ResizeImage(FileImage(file),
            width: widget.width * 2,
            height: widget.height * 2,
            policy: ResizeImagePolicy.fit);
        return img;
      } else {
        return ResizeImage(FileImage(File('images\\test.png')),
            width: widget.width * 2,
            height: widget.height * 2,
            policy: ResizeImagePolicy.fit);
      }
    } else {
      // 若图片不存在就加载默认图片
      return ResizeImage(FileImage(File('images\\test.png')),
          width: widget.width * 2,
          height: widget.height * 2,
          policy: ResizeImagePolicy.fit);
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _mouseEOAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _mouseClickAnimationController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mouseEOAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        // 进入
        onEnter: (details) => _mouseEOAnimationController.forward(),
        // 离开
        onExit: (details) => _mouseEOAnimationController.reverse(),
        // onHover: (event) => print('object'),
        child: GestureDetector(
            // 点击事件监听
            onTap: () {
              ShowInfoNotification(widget.workInfoNotifier.value)
                  .dispatch(context);
            },
            onTapDown: (details) => _mouseClickAnimationController.forward(),
            onTapUp: (details) => _mouseClickAnimationController.reverse(),
            onTapCancel: () => _mouseClickAnimationController.reverse(),
            child: //InkWell(
                //onTap: () => print('object'),
                //splashColor: Colors.blue.withAlpha(30), // 水波纹颜色
                //highlightColor: Colors.blue.withAlpha(90), // 按下时的颜色
                //child:
                Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[350]),
                        width: widget.width + 8,
                        height: widget.height + 8,
                        // 监听workinfo改变
                        child: ValueListenableBuilder(
                            valueListenable: widget.workInfoNotifier,
                            builder: (context, value, child) {
                              return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 异步加载图片
                                    FutureBuilder<ResizeImage>(
                                        future: _getImageFile(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<ResizeImage>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasData) {
                                              return Image(
                                                      key: Key('value'),
                                                      image: snapshot.data!)
                                                  .animate()
                                                  .fadeIn(duration: 500.ms);
                                            } else {
                                              return const Center(
                                                  child: Text(
                                                      'Error loading image'));
                                            }
                                          } else {
                                            return const Center(
                                                child:
                                                    //Text('Loading......')
                                                    CircularProgressIndicator());
                                          }
                                        }),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        width: 30,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[600],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Text(
                                            widget.workInfoNotifier.value
                                                .imageCount
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                //backgroundColor: Colors.grey[600],
                                                decorationStyle:
                                                    TextDecorationStyle.wavy),
                                          ),
                                        ))
                                  ]);
                            }))
                    .animate(
                        controller: _mouseEOAnimationController,
                        autoPlay: false)
                    //.color(blendMode: BlendMode.darken)
                    .scaleXY(begin: 1.0, end: 1.05)
                    .animate(
                        controller: _mouseClickAnimationController,
                        autoPlay: false)
                    .color(duration: 80.ms, blendMode: BlendMode.darken))
        //)
        );
  }
}
