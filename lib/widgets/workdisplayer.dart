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
    return ValueListenableBuilder(
      valueListenable: widget.workInfo,
      builder: (context, value, child) {
        List<Widget> tags = [];
        value.tags.forEach((key, value) {
          tags.add(Text.rich(
              style: TextStyle(fontSize: 20),
              TextSpan(
                  text: '$key ($value) ',
                  style: TextStyle(backgroundColor: Colors.amber),
                  recognizer: TapGestureRecognizer())));
        });
        return //SizedBox(
            //height: 800,
            //child:
            Column(children: [
          Text.rich(
              style: TextStyle(fontSize: 20),
              TextSpan(text: 'Title: ', children: [
                TextSpan(
                    text: '${value.title}\n',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      'UserId: ${value.userId}\nUserName: ${value.userName}\n',
                  style: TextStyle(color: Colors.lightBlue),
                  //TODO跳转
                  recognizer: TapGestureRecognizer(),
                ),
                TextSpan(text: 'Description: ${value.description}\n'),
              ])),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: tags,
          )
        ] //)
                );
      },
    );
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
  late ValueNotifier<IconData> _icon;

  void showWorkDetail() {
    List<dynamic>? imagePaths = widget.workInfoNotifier.value.imagePath;
    if (imagePaths != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              maintainState: false,
              builder: (context) =>
                  WorkDetialDisplayer(imagePath: imagePaths)));
    }
  }

  @override
  void initState() {
    super.initState();
    _icon = ValueNotifier<IconData>(widget.workInfoNotifier.value.isLiked
        ? Icons.favorite
        : Icons.favorite_border);
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
        child: FittedBox(
            //InkWell(
            //onTap: () => print('object'),
            //splashColor: Colors.blue.withAlpha(30), // 水波纹颜色
            //highlightColor: Colors.blue.withAlpha(90), // 按下时的颜色
            //child:

            // 监听workinfo改变
            child: ValueListenableBuilder(
                    valueListenable: widget.workInfoNotifier,
                    builder: (context, value, child) {
                      _icon.value = widget.workInfoNotifier.value.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border;
                      return Stack(alignment: Alignment.center, children: [
                        GestureDetector(
                            // 点击事件监听
                            onTap: () {
                              ShowInfoNotification(
                                      widget.workInfoNotifier.value)
                                  .dispatch(context);
                            },
                            onTapDown: (details) =>
                                _mouseClickAnimationController.forward(),
                            onTapUp: (details) =>
                                _mouseClickAnimationController.reverse(),
                            onTapCancel: () =>
                                _mouseClickAnimationController.reverse(),
                            onDoubleTap: () => showWorkDetail(),
                            /*
                      onDoubleTapDown: (details) =>
                          _mouseClickAnimationController.forward(),
                      onDoubleTapCancel: () => _mouseClickAnimationController.reverse(),
                      */
                            child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[350]),
                                    width: widget.width + 8,
                                    height: widget.height + 8,
                                    child:
                                        // 异步加载图片
                                        FutureBuilder<dynamic>(
                                            future: _imageFile(
                                              widget.workInfoNotifier.value
                                                  .imagePath![0],
                                              widget.width,
                                              widget.height,
                                            ),
                                            builder:
                                                (BuildContext context,
                                                    AsyncSnapshot<dynamic>
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
                                            }))
                                .animate(
                                    controller: _mouseClickAnimationController,
                                    autoPlay: false)
                                .color(
                                    duration: 50.ms,
                                    blendMode: BlendMode.darken)),
                        Positioned(
                            top: 5,
                            right: 5,
                            width: 30,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                widget.workInfoNotifier.value.imageCount
                                    .toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    //backgroundColor: Colors.grey[600],
                                    decorationStyle: TextDecorationStyle.wavy),
                              ),
                            )),
                        Positioned(
                            bottom: 5,
                            left: 5,
                            child: ValueListenableBuilder<IconData>(
                                valueListenable: _icon,
                                builder: (context, iconvalue, child) =>
                                    IconButton(
                                      onPressed: () {
                                        //TODO 通信更新信息
                                        if (widget
                                            .workInfoNotifier.value.isLiked) {
                                          _icon.value = Icons.favorite_border;
                                          widget.workInfoNotifier
                                              .bookmark(false);
                                        } else {
                                          _icon.value = Icons.favorite;
                                          widget.workInfoNotifier
                                              .bookmark(true);
                                        }
                                      },
                                      icon: Icon(iconvalue),
                                      iconSize: 30,
                                      color: Colors.white,
                                      style: IconButton.styleFrom(
                                          backgroundColor: Colors.grey),
                                    )))
                      ]);
                    })
                .animate(
                    controller: _mouseEOAnimationController, autoPlay: false)
                //.color(blendMode: BlendMode.darken)
                .scaleXY(begin: 1.0, end: 1.02, duration: 100.ms)));
  }
}

class WorkDetialDisplayer extends StatefulWidget {
  const WorkDetialDisplayer({super.key, required this.imagePath});
  final List<dynamic> imagePath;

  @override
  State<StatefulWidget> createState() => _WorkDetialDisplayerState();
}

class _WorkDetialDisplayerState extends State<WorkDetialDisplayer> {
  //TODO 小说 键盘翻页
  ValueNotifier<int> index = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: Stack(
      fit: StackFit.passthrough,
      children: [
        InteractiveViewer(
            maxScale: 12,
            child: ValueListenableBuilder(
                valueListenable: index,
                builder: (context, index, child) => SizedBox(
                    width: 2560,
                    height: 1440,
                    child:
                        // 异步加载图片
                        FutureBuilder<dynamic>(
                            initialData: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            future: _imageFile(widget.imagePath[index]),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  String error = snapshot.error.toString();
                                  return Center(
                                      child:
                                          Text('Error loading image:$error'));
                                }
                                if (snapshot.hasData) {
                                  return Image(
                                    key: Key('value'),
                                    image: snapshot.data,
                                    width: 2560,
                                    height: 1440,
                                  ).animate().fade(duration: 700.ms);
                                } else {
                                  return const Center(
                                      child: Text('Error loading image'));
                                }
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                ));
                              }
                            })))),
        Positioned(
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
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.grey),
            )),
        Positioned(
            top: 670,
            left: 10,
            child: IconButton(
                onPressed: () {
                  if (index.value > 0) {
                    index.value -= 1;
                  }
                },
                icon: Icon(Icons.navigate_before),
                iconSize: 80,
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: Colors.grey))),
        Positioned(
            top: 670,
            right: 10,
            child: IconButton(
                onPressed: () {
                  if (index.value < widget.imagePath.length - 1) {
                    index.value += 1;
                  }
                },
                icon: Icon(Icons.navigate_next),
                iconSize: 80,
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: Colors.grey))),
        ValueListenableBuilder(
            valueListenable: index,
            builder: (context, value, child) => Positioned(
                bottom: 20,
                right: 1225,
                width: 150,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${value + 1}/${widget.imagePath.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 5,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ))))
      ],
    ));
  }
}

// 异步加载图片
Future<dynamic> _imageFile(String? imagePath, [int? width, int? height]) async {
  ImageProvider image;
  //try {
  if (imagePath != null) {
    //TODO文件路径
    var file = File('E://pixiv/$imagePath');
    var exists = await file.exists();
    if (exists) {
      image = FileImage(file);
    } else {
      image = AssetImage('assets/images/test.png');
    }
  } else {
    // 若图片不存在就加载默认图片
    image = AssetImage('assets/images/test.png');
  }
  if (width != null && height != null) {
    return ResizeImage(image,
        width: width * 2, height: height * 2, policy: ResizeImagePolicy.fit);
  } else {
    return image;
  }
  //} catch (e) {
  //  return ResizeImage(AssetImage('assets/images/test.png'),
  //      policy: ResizeImagePolicy.fit);
  //}
}