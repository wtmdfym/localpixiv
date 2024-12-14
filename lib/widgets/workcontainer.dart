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
    final List<Widget> tags = [];
    workInfo.tags.forEach((key, value) {
      tags.add(SelectableText.rich(
          style: TextStyle(backgroundColor: Colors.amberAccent),
          TextSpan(
              text: '$key ($value)',
              recognizer: (TapGestureRecognizer()
                ..onTap = () => onTapTag(key)))));
    });
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SelectableText.rich(TextSpan(children: [
        TextSpan(
          text: 'Title: ${workInfo.title}\n',
        ),
        TextSpan(
          text: 'UserId: ${workInfo.userId}\nUserName: ${workInfo.userName}\n',
          style: TextStyle(color: Colors.lightBlue),
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

/// 展示作品的容器(使用fittedbox或expanded包裹避免'size.isFinite': is not true错误)
class WorkContainer extends StatefulWidget {
  const WorkContainer({
    super.key,
    required this.hostPath,
    this.width = 400,
    this.height = 480,
    required this.cacheRate,
    required this.workInfo,
    required this.onBookmarked,
    this.backgroundColor = const Color.fromARGB(255, 214, 214, 214),
  });
  final String hostPath;
  final int width;
  final int height;
  final double cacheRate;
  final WorkInfo workInfo;
  final WorkBookmarkCallback onBookmarked;
  final Color backgroundColor;
  @override
  State<StatefulWidget> createState() {
    return _WorkContainerState();
  }
}

class _WorkContainerState extends State<WorkContainer>
    with TickerProviderStateMixin {
  late AnimationController _mouseEOAnimationController;
  late ValueNotifier<IconData> _icon;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _mouseEOAnimationController = AnimationController(
      vsync: this,
    );
    _icon = ValueNotifier<IconData>(
        widget.workInfo.isLiked ? Icons.favorite : Icons.favorite_border);
  }

  @override
  void dispose() {
    _mouseEOAnimationController.dispose();
    _icon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _icon.value =
        widget.workInfo.isLiked ? Icons.favorite : Icons.favorite_border;

    return MouseRegion(
        // 进入
        onEnter: (details) => _mouseEOAnimationController.forward(),
        // 离开
        onExit: (details) => _mouseEOAnimationController.reverse(),
        child: Animate(
            autoPlay: false,
            controller: _mouseEOAnimationController,
            effects: [
              ScaleEffect(
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.02, 1.02),
                  duration: 100.ms)
            ],
            child: RepaintBoundary(
                child: LongPressDraggable<(String, WorkInfo)>(
                    data: (widget.hostPath, widget.workInfo),
                    delay: Durations.medium2,
                    dragAnchorStrategy: (draggable, context, position) =>
                        Offset(-12, 32),
                    childWhenDragging: SizedBox(),
                    feedback: Material(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromARGB(0, 0, 0, 0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    const Color.fromARGB(150, 158, 158, 158)),
                            child: Text(
                              widget.workInfo.title,
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.fontSize),
                            ))),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: widget.backgroundColor),
                        width: widget.width + 8,
                        height: widget.height + 8,
                        child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                top: 8,
                                left: 8,
                                bottom: 8,
                                right: 8,
                                child: widget.workInfo.type == 'novel'
                                    ? NovelLoader(
                                        coverImagePath:
                                            widget.workInfo.coverImagePath!,
                                        title: widget.workInfo.title,
                                        width: widget.width,
                                        height: widget.height,
                                        cacheRate: widget.cacheRate,
                                      )
                                    : ImageLoader(
                                        path:
                                            '${widget.hostPath}${widget.workInfo.imagePath![0]}',
                                        width: widget.width,
                                        height: widget.height,
                                        cacheRate: widget.cacheRate,
                                      ),
                              ),
                              // 在最顶层显示墨水效果
                              Positioned.fill(
                                  child: Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        onTap: () => context
                                            .read<ShowInfoNotifier>()
                                            .updateInfo(widget.workInfo),
                                        hoverColor: const Color.fromARGB(
                                            80, 24, 255, 255),
                                        splashColor: const Color.fromARGB(
                                            80, 0, 187, 212),
                                        borderRadius: BorderRadius.circular(12),
                                      ))),

                              // 图片数量/小说字数显示
                              Positioned(
                                  top: 5,
                                  right: 5,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      widget.workInfo.type == 'novel'
                                          ? ' ${widget.workInfo.characterCount} '
                                          : ' ${widget.workInfo.imageCount} ',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.white,
                                          decorationStyle:
                                              TextDecorationStyle.wavy),
                                    ),
                                  )),
                              // 收藏作品
                              Positioned(
                                  bottom: 5,
                                  left: 5,
                                  child: ValueListenableBuilder<IconData>(
                                      valueListenable: _icon,
                                      builder: (context, iconvalue, child) =>
                                          RepaintBoundary(
                                              child: IconButton(
                                            onPressed: () {
                                              // 通信更新信息
                                              _icon.value =
                                                  widget.workInfo.isLiked
                                                      ? Icons.favorite_border
                                                      : Icons.favorite;
                                              widget.workInfo.isLiked =
                                                  !widget.workInfo.isLiked;
                                              widget.onBookmarked(
                                                  widget.workInfo.isLiked,
                                                  widget.workInfo.id,
                                                  widget.workInfo.userName);
                                            },
                                            icon: Icon(iconvalue),
                                            color: Colors.white,
                                            style: IconButton.styleFrom(
                                                backgroundColor: Colors.grey),
                                          ))))
                            ]))))));
  }
}

/// 展示作品详情的容器
class WorkDetialDisplayer extends StatefulWidget {
  const WorkDetialDisplayer({
    super.key,
    required this.hostPath,
    required this.cacheRate,
    required this.onBookmarked,
    required this.workInfo,
    this.backgroundColor = const Color.fromARGB(255, 214, 214, 214),
  });

  final String hostPath;
  final double cacheRate;
  final WorkInfo workInfo;
  final WorkBookmarkCallback onBookmarked;
  final Color backgroundColor;

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
  void didUpdateWidget(covariant WorkDetialDisplayer oldWidget) {
    if (oldWidget.workInfo != widget.workInfo) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    super.dispose();
    index.dispose();
    _icon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
                top: 8,
                left: 60,
                width: constraints.maxWidth - 120,
                height: constraints.maxHeight - 16,
                child: ValueListenableBuilder(
                    valueListenable: index,
                    builder: (context, index, child) => widget.workInfo.type ==
                            'novel'
                        ? NovelDetialLoader(content: widget.workInfo.content!)
                        : InteractiveViewer(
                            maxScale: 12,
                            child: ImageLoader(
                                path:
                                    '${widget.hostPath}${widget.workInfo.imagePath![index]}',
                                width: 2560,
                                height: 1440,
                                cacheRate: widget.cacheRate)))),

            Positioned(
                top: constraints.maxHeight / 2,
                left: 20,
                child: IconButton(
                    onPressed: () {
                      if (index.value > 0) {
                        index.value -= 1;
                      }
                    },
                    icon: Icon(Icons.navigate_before),
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: Colors.grey))),
            Positioned(
                top: constraints.maxHeight / 2,
                right: 20,
                child: IconButton(
                    onPressed: () {
                      if (index.value < widget.workInfo.imagePath!.length - 1) {
                        index.value += 1;
                      }
                    },
                    icon: Icon(Icons.navigate_next),
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: Colors.grey))),
            // 收藏作品
            Positioned(
                bottom: 5,
                left: 5,
                child: ValueListenableBuilder<IconData>(
                    valueListenable: _icon,
                    builder: (context, iconvalue, child) => RepaintBoundary(
                            child: IconButton(
                          onPressed: () {
                            // 通信更新信息
                            _icon.value = widget.workInfo.isLiked
                                ? Icons.favorite_border
                                : Icons.favorite;
                            widget.workInfo.isLiked = !widget.workInfo.isLiked;
                            widget.onBookmarked(
                              widget.workInfo.isLiked,
                              widget.workInfo.id,
                              widget.workInfo.userName,
                            );
                          },
                          icon: Icon(iconvalue),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.grey),
                        )))),
            widget.workInfo.type == 'novel'
                ? SizedBox()
                : ValueListenableBuilder(
                    valueListenable: index,
                    builder: (context, value, child) => Positioned(
                        bottom: 20,
                        left: constraints.maxWidth / 2,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ' ${value + 1}/${widget.workInfo.imagePath!.length}  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 5,
                                color: Colors.white,
                              ),
                            ))))
          ],
        );
      },
    ));
  }
}
