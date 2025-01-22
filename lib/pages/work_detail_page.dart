import 'package:flutter/material.dart';

import 'package:mongo_dart/mongo_dart.dart' show Db;
import 'package:provider/provider.dart';

import '../localization/localization_intl.dart';
import '../models.dart';
import '../containers/info_container.dart';
import '../settings/settings_controller.dart';
import '../widgets/workloader.dart';
import '../widgets/should_rebuild_widget.dart';
import '../widgets/tap_hide_stack.dart';
import '../common/customnotifier.dart';
import 'user_detail_page.dart';

/// A page to show detail information about a work.
class WorkDetailPage extends StatefulWidget {
  const WorkDetailPage({
    super.key,
    required this.controller,
    required this.workInfo,
    required this.pixivDb,
    required this.onBookmarked,
  });

  final SettingsController controller;
  final WorkInfo workInfo;
  final Db pixivDb;
  final WorkBookmarkCallback onBookmarked;

  @override
  State<StatefulWidget> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  ValueNotifier<int> index = ValueNotifier<int>(0);
  late ValueNotifier<bool> _isLiked;

  @override
  void initState() {
    super.initState();

    _isLiked = ValueNotifier<bool>(widget.workInfo.isLiked);
  }

  @override
  void didUpdateWidget(covariant WorkDetailPage oldWidget) {
    if (oldWidget.workInfo != widget.workInfo) {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    super.dispose();
    index.dispose();
    _isLiked.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: TapHideStack(
      padding: const EdgeInsets.all(8),
      leftWidget: WorkInfoContainer(
        workInfo: widget.workInfo,
        onTapUser: (userName) {
          widget.controller.autoOpen
              ? context
                  .read<AddStackNotifier>()
                  .addStack<UserDetailPage>(userName, {'userName': userName})
              : {};
        },
        onTapTag: (tag) {},
      ),
      rightWidget: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
                child: RepaintBoundary(
                    child: ShouldRebuildWidget(
                        shouldRebuild: (oldWidget, newWidget) => false,
                        child: ValueListenableBuilder(
                          valueListenable: index,
                          builder: (context, index, child) => widget
                                      .workInfo.type ==
                                  'novel'
                              ? NovelDetialLoader(
                                  content: widget.workInfo.content!)
                              : InteractiveViewer(
                                  maxScale: 12,
                                  child: ImageLoader(
                                      path:
                                          '${widget.controller.hostPath}${widget.workInfo.imagePath![index]}',
                                      width: 2560,
                                      height: 1440,
                                      cacheRate:
                                          widget.controller.imageCacheRate)),
                        )))),

            Positioned(
                top: constraints.maxHeight / 2,
                left: 8,
                child: IconButton(
                  onPressed: () {
                    if (index.value > 0) {
                      index.value -= 1;
                    }
                  },
                  icon: Icon(Icons.arrow_back),
                  iconSize: Theme.of(context).iconTheme.opticalSize!,
                )),
            Positioned(
                top: constraints.maxHeight / 2,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    if (index.value < widget.workInfo.imagePath!.length - 1) {
                      index.value += 1;
                    }
                  },
                  icon: Icon(Icons.arrow_forward),
                  iconSize: Theme.of(context).iconTheme.opticalSize!,
                )),
            // Bookmark work.
            Positioned(
              bottom: 8,
              left: 8,
              child: ValueListenableBuilder(
                valueListenable: _isLiked,
                builder: (context, isLiked, child) => IconButton.filledTonal(
                  isSelected: isLiked,
                  onPressed: () {
                    // Use callback to update info.
                    _isLiked.value = !widget.workInfo.isLiked;
                    widget.workInfo.isLiked = !widget.workInfo.isLiked;
                    widget.onBookmarked(widget.workInfo.isLiked,
                        widget.workInfo.id, widget.workInfo.userName);
                  },
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  tooltip: MyLocalizations.of(context)
                      .like(widget.workInfo.isLiked ? 'y' : 'n'),
                  color: Colors.white,
                  constraints: BoxConstraints.tightFor(
                      width: Theme.of(context).iconTheme.opticalSize!,
                      height: Theme.of(context).iconTheme.opticalSize!),
                  padding: const EdgeInsets.all(0),
                ),
              ),
            ),
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
                              ' ${value + 1}/${widget.workInfo.imagePath!.length} ',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                letterSpacing: 5,
                                color: Colors.white,
                              ),
                            ))))
          ],
        );
      }),
      leftOccupied: 300,
      duration: Durations.short1,
    ));
  }
}
