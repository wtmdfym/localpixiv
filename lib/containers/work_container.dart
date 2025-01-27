import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';

import '../localization/localization.dart';
import '../models.dart';
import '../widgets/workloader.dart';

///  A widget to show a brief introduction about a work.
class WorkContainer extends StatefulWidget {
  const WorkContainer({
    super.key,
    required this.hostPath,
    this.width = 400,
    this.height = 480,
    required this.cacheRate,
    required this.workInfo,
    this.onTab,
    required this.onBookmarked,
    this.overBackgroundColor = const Color.fromARGB(180, 160, 160, 160),
  });
  final String hostPath;
  final int width;
  final int height;
  final double cacheRate;
  final WorkInfo workInfo;
  final GestureTapCallback? onTab;
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
          Draggable<WorkInfo>(
              data: widget.workInfo,
              dragAnchorStrategy: (draggable, context, position) =>
                  Offset(-12, 32),
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
                            child: RepaintBoundary(
                                child: InkWell(
                          onTap: widget.onTab,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: EdgeInsets.all(6),
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
                          ),
                        ))),
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
                                  .bookmarkToolTip(
                                      widget.workInfo.isLiked ? 'y' : 'n'),
                              color: Colors.white,
                              constraints: BoxConstraints.tightFor(
                                  width:
                                      Theme.of(context).iconTheme.opticalSize!,
                                  height:
                                      Theme.of(context).iconTheme.opticalSize!),
                              padding: const EdgeInsets.all(0),
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
