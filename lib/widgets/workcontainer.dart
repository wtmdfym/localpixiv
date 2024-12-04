import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/workloader.dart';
import 'package:provider/provider.dart';

/// 显示作品信息的容器
class InfoContainer extends StatelessWidget {
  const InfoContainer({
    super.key,
    required this.workInfo,
    required this.onTapUser,
    required this.onTapTag,
  });
  final WorkInfo workInfo;
  final OpenTabCallback onTapUser;
  final NeedSearchCallback onTapTag;

  @override
  Widget build(BuildContext context) {
    List<Widget> tags = [];
    workInfo.tags.forEach((key, value) {
      tags.add(SelectableText.rich(
          style: TextStyle(
              fontSize: 20,
              backgroundColor: const Color.fromARGB(150, 255, 193, 7)),
          TextSpan(
              text: '$key ($value)',
              recognizer: (TapGestureRecognizer()
                ..onTap = () => onTapTag(key)))));
    });
    return Column(children: [
      SelectableText.rich(
          style: TextStyle(fontSize: 20),
          TextSpan(children: [
            TextSpan(
                text: 'Title: ${workInfo.title}\n',
                style: TextStyle(fontSize: 25)),
            TextSpan(
              text:
                  'UserId: ${workInfo.userId}\nUserName: ${workInfo.userName}\n',
              style: TextStyle(color: Colors.lightBlue, fontSize: 25),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onTapUser(workInfo.userName),
            ),
            TextSpan(text: 'Description: ${workInfo.description}\n'),
          ])),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: tags,
      )
    ]);
  }
}

/// 展示作品的容器
class WorkContainer extends StatefulWidget {
  const WorkContainer({
    super.key,
    required this.hostPath,
    this.width = 400,
    this.height = 480,
    required this.workInfo,
    this.backgroundColor = const Color.fromARGB(255, 214, 214, 214),
  });
  final String hostPath;
  final int width;
  final int height;
  final WorkInfo workInfo;
  final Color backgroundColor;
  @override
  State<StatefulWidget> createState() {
    return _WorkContainerState();
  }
}

class _WorkContainerState extends State<WorkContainer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late AnimationController _mouseClickAnimationController;
  late ValueNotifier<IconData> _icon;

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
    _mouseEOAnimationController.dispose();
    _mouseClickAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _icon = ValueNotifier<IconData>(
        widget.workInfo.isLiked ? Icons.favorite : Icons.favorite_border);
    void showWorkDetail() {
      List<dynamic>? imagePaths = widget.workInfo.imagePath;
      if (imagePaths != null) {
        context.read<StackChangeNotifier>().addStack(
            widget.workInfo.title,
            WorkDetialDisplayer(
              hostPath: widget.hostPath,
              workInfo: widget.workInfo,
            ));
      }
    }

    return MouseRegion(
        // 进入
        onEnter: (details) => _mouseEOAnimationController.forward(),
        // 离开
        onExit: (details) => _mouseEOAnimationController.reverse(),
        child: FittedBox(
                child: Stack(alignment: Alignment.center, children: [
          GestureDetector(
            // 点击事件监听
            onTap: () {
              ShowInfoNotification(widget.workInfo).dispatch(context);
            },
            //onTapDown: (details) =>
            //    _mouseClickAnimationController.forward(),
            //onTapUp: (details) =>
            //    _mouseClickAnimationController.reverse(),
            //onTapCancel: () =>
            //    _mouseClickAnimationController.reverse(),
            onDoubleTap: () => showWorkDetail(),
            //onDoubleTapDown: (details) =>
            //    _mouseClickAnimationController.forward(),
            //onDoubleTapCancel: () => _mouseClickAnimationController.reverse(),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.backgroundColor),
                //child: Column(children: [
                //  SizedBox(
                width: widget.width + 8,
                height: widget.height + 8,
                child: widget.workInfo.type == 'novel'
                    ? NovelLoader()
                    : ImageLoader(
                        path:
                            '${widget.hostPath}${widget.workInfo.imagePath![0]}',
                        width: widget.width,
                        height: widget.height,
                        cacheRate: 0)),
            /*SizedBox(
              width: widget.width - 100,
              child: Text(
                  workInfo.title,
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                ))
            ])*/
          )
              .animate(
                  controller: _mouseClickAnimationController, autoPlay: false)
              .color(duration: 50.ms, blendMode: BlendMode.darken),
          // 图片数量显示
          Positioned(
              top: 5,
              right: 5,
              width: 30,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  widget.workInfo.imageCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      decorationStyle: TextDecorationStyle.wavy),
                ),
              )),
          // 收藏作品
          Positioned(
              bottom: 5,
              left: 5,
              child: ValueListenableBuilder<IconData>(
                  valueListenable: _icon,
                  builder: (context, iconvalue, child) => IconButton(
                        onPressed: () {
                          // 通信更新信息
                          _icon.value = widget.workInfo.isLiked
                              ? Icons.favorite_border
                              : Icons.favorite;
                          widget.workInfo.isLiked = !widget.workInfo.isLiked;
                          Provider.of<WorkBookMarkModel>(context, listen: false)
                              .changebookmark(
                            widget.workInfo.isLiked,
                            widget.workInfo.id,
                            widget.workInfo.userName,
                          );
                        },
                        icon: Icon(iconvalue),
                        iconSize: 30,
                        color: Colors.white,
                        style:
                            IconButton.styleFrom(backgroundColor: Colors.grey),
                      )))
        ]))
            .animate(controller: _mouseEOAnimationController, autoPlay: false)
            .scaleXY(begin: 1.0, end: 1.02, duration: 100.ms));
  }
}

class WorkDetialDisplayer extends StatefulWidget {
  const WorkDetialDisplayer(
      {super.key, required this.hostPath, required this.workInfo});
  final String hostPath;
  final WorkInfo workInfo;

  @override
  State<StatefulWidget> createState() => _WorkDetialDisplayerState();
}

class _WorkDetialDisplayerState extends State<WorkDetialDisplayer> {
  ValueNotifier<int> index = ValueNotifier<int>(0);
  late ValueNotifier<IconData> _icon;

  @override
  void initState() {
    super.initState();
    _icon = ValueNotifier<IconData>(
        widget.workInfo.isLiked ? Icons.favorite : Icons.favorite_border);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FittedBox(
            child: Stack(
      children: [
        InteractiveViewer(
            maxScale: 12,
            child: ValueListenableBuilder(
                valueListenable: index,
                builder: (context, index, child) => SizedBox(
                    width: 2560,
                    height: 1440,
                    child: ImageLoader(
                        path:
                            '${widget.hostPath}${widget.workInfo.imagePath![index]}',
                        width: 2560,
                        height: 1440,
                        cacheRate: 0)))),

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
                  if (index.value < widget.workInfo.imagePath!.length - 1) {
                    index.value += 1;
                  }
                },
                icon: Icon(Icons.navigate_next),
                iconSize: 80,
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: Colors.grey))),
        // 收藏作品
        Positioned(
            bottom: 5,
            left: 5,
            child: ValueListenableBuilder<IconData>(
                valueListenable: _icon,
                builder: (context, iconvalue, child) => IconButton(
                      onPressed: () {
                        //通信更新信息
                        _icon.value = widget.workInfo.isLiked
                            ? Icons.favorite_border
                            : Icons.favorite;
                        widget.workInfo.isLiked = !widget.workInfo.isLiked;
                        Provider.of<WorkBookMarkModel>(context, listen: false)
                            .changebookmark(
                          widget.workInfo.isLiked,
                          widget.workInfo.id,
                          widget.workInfo.userName,
                        );
                      },
                      icon: Icon(iconvalue),
                      iconSize: 60,
                      color: Colors.white,
                      style: IconButton.styleFrom(backgroundColor: Colors.grey),
                    ))),
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
                      '${value + 1}/${widget.workInfo.imagePath!.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 5,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ))))
      ],
    )));
  }
}
