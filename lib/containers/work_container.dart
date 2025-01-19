import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../common/customnotifier.dart';
import '../localization/localization_intl.dart';
import '../models.dart';
import '../widgets/workloader.dart';

typedef WorkBookmarkCallback = void Function(
    bool isLiked, int workId, String userName);

///  A widget to show a brief introduction about a work.
class WorkContainer extends StatefulWidget {
  const WorkContainer({
    super.key,
    required this.hostPath,
    this.width = 400,
    this.height = 480,
    required this.cacheRate,
    required this.workInfo,
    required this.onBookmarked,
    this.overBackgroundColor = const Color.fromARGB(180, 160, 160, 160),
  });
  final String hostPath;
  final int width;
  final int height;
  final double cacheRate;
  final WorkInfo workInfo;
  final WorkBookmarkCallback onBookmarked;
  final Color overBackgroundColor;
  @override
  State<StatefulWidget> createState() {
    return _WorkContainerState();
  }
}

class _WorkContainerState extends State<WorkContainer>
    with TickerProviderStateMixin {
  // late AnimationController _mouseEOAnimationController;
  late ValueNotifier<bool> _isLiked;

  @override
  void initState() {
    super.initState();
    /*// Init animation controller.
    _mouseEOAnimationController = AnimationController(
      vsync: this,
    );*/
    // Set initial value.
    _isLiked = ValueNotifier<bool>(widget.workInfo.isLiked);
  }

  @override
  void didUpdateWidget(covariant WorkContainer oldWidget) {
    if (oldWidget.workInfo != widget.workInfo) {
      _isLiked.value = widget.workInfo.isLiked;
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    // _mouseEOAnimationController.dispose();
    _isLiked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: /*MouseRegion(
        onEnter: (details) => _mouseEOAnimationController.forward(),
        onExit: (details) => _mouseEOAnimationController.reverse(),
        child:*/
          LongPressDraggable<(String, WorkInfo)>(
              data: (widget.hostPath, widget.workInfo),
              delay: Durations.medium2,
              dragAnchorStrategy: (draggable, context, position) =>
                  Offset(-12, 32),
              childWhenDragging: SizedBox(),
              feedback: Material(
                  type: MaterialType.card,
                  child: Text(
                    widget.workInfo.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
              child: SizedBox(
                  width: widget.width + 4,
                  height: widget.height + 4,
                  child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        // Show DecoratedBox on the bottom to enhance visual effect.
                        Positioned.fill(
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                          color: Theme.of(context).hoverColor,
                          borderRadius: BorderRadius.circular(6),
                        ))),
                        Positioned.fill(
                            top: 4,
                            left: 4,
                            bottom: 4,
                            right: 4,
                            child: RepaintBoundary(
                              child: widget.workInfo.type == 'novel'
                                  ? NovelLoader(
                                      coverImagePath:
                                          '${widget.hostPath}${widget.workInfo.coverImagePath!}',
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
                            )),
                        // Show the number of images or the number of character in novel.
                        Positioned(
                          top: 4,
                          right: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: widget.overBackgroundColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              widget.workInfo.type == 'novel'
                                  ? ' ${widget.workInfo.characterCount} '
                                  : ' ${widget.workInfo.imageCount} ',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.white,
                                decorationStyle: TextDecorationStyle.wavy,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .fontSize,
                              ),
                            ),
                          ),
                        ),
                        // Show inkWell on the top.
                        Positioned.fill(
                            child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  onTap: () => context
                                      .read<ShowInfoNotifier>()
                                      .updateInfo(widget.workInfo),
                                  borderRadius: BorderRadius.circular(6),
                                ))),
                        // Bookmark work.
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: ValueListenableBuilder(
                            valueListenable: _isLiked,
                            builder: (context, isLiked, child) =>
                                IconButton.filledTonal(
                              isSelected: isLiked,
                              onPressed: () {
                                // Use callback to update info.
                                _isLiked.value = !widget.workInfo.isLiked;
                                widget.workInfo.isLiked =
                                    !widget.workInfo.isLiked;
                                widget.onBookmarked(
                                    widget.workInfo.isLiked,
                                    widget.workInfo.id,
                                    widget.workInfo.userName);
                              },
                              icon: Icon(Icons.favorite_border),
                              selectedIcon: Icon(Icons.favorite),
                              tooltip: MyLocalizations.of(context)
                                  .like(widget.workInfo.isLiked ? 'y' : 'n'),
                              color: Colors.white,
                              constraints: BoxConstraints.tightFor(
                                  width:
                                      Theme.of(context).iconTheme.opticalSize!,
                                  height:
                                      Theme.of(context).iconTheme.opticalSize!),
                              padding:const EdgeInsets.all(0),
                            ),
                          ),
                        )
                      ])
                  /*.animate(
                      controller: _mouseEOAnimationController, autoPlay: false)
                  .scaleXY(begin: 1.0, end: 1.02, duration: Durations.short1),*/
                  )),
      // ),
    );
  }
}
