import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';

import '../localization/localization_intl.dart';
import '../settings/settings_controller.dart';
import '../models.dart';
import '../widgets/workloader.dart';
import 'work_container.dart';

/// A widget to show a brief introduction about a user.
class UserContainer extends StatefulWidget {
  const UserContainer({
    super.key,
    required this.controller,
    this.height = 240,
    this.rowCount = 4,
    required this.userInfo,
    required this.onTab,
    required this.onWorkBookmarked,
  });
  final SettingsController controller;
  final int height;
  final int rowCount;
  final UserInfo userInfo;
  final OpenTabCallback onTab;
  final WorkBookmarkCallback onWorkBookmarked;
  @override
  State<StatefulWidget> createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer>
    with TickerProviderStateMixin {
  // late AnimationController _mouseEOAnimationController;
  final List<WorkInfo> workInfos = [];

  @override
  void initState() {
    workInfos.addAll(widget.userInfo.workInfos.sublist(0, 4));
    /* // Init animation controller.
    _mouseEOAnimationController = AnimationController(
      vsync: this,
    );*/
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserContainer oldWidget) {
    if (oldWidget.userInfo != widget.userInfo) {
      workInfos.clear();
      workInfos.addAll(widget.userInfo.workInfos.sublist(0, 4));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // _mouseEOAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainStack = Stack(children: [
      // Show DecoratedBox on the bottom to enhance visual effect.
      Positioned.fill(
          child: DecoratedBox(
              decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(6),
      ))),
      Positioned.fill(
        child: InkWell(
          onTap: () => widget.onTab(widget.userInfo.userName),
          borderRadius: BorderRadius.circular(6),
          child: Row(mainAxisSize: MainAxisSize.min, spacing: 20, children: [
            // User profile image.
            Expanded(
                flex: 3,
                child: ImageLoader(
                  path:
                      '${widget.controller.hostPath}${widget.userInfo.profileImage}',
                  width: widget.height,
                  height: widget.height,
                  cacheRate: widget.controller.imageCacheRate,
                )),
            // User's name and description.
            Expanded(
                flex: 6,
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userInfo.userName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(widget.userInfo.userComment),
                      )),
                    ),
                  ],
                )),
            // The latest works from the user.
            for (int i = 0; i < widget.rowCount; i++)
              Expanded(
                  flex: 4,
                  child: WorkContainer(
                    hostPath: widget.controller.hostPath,
                    workInfo: workInfos[i],
                    width: widget.height + 20,
                    height: widget.height,
                    cacheRate: widget.controller.imageCacheRate,
                    onBookmarked: (isLiked, workId, userName) =>
                        widget.onWorkBookmarked(
                      isLiked,
                      workId,
                      userName,
                    ),
                  ))
          ]),
        ),
      ),
    ]);

    if (widget.userInfo.notFollowingNow) {
      mainStack = Tooltip(
        message: MyLocalizations.of(context).notFollowingWarn,
        child: ColoredBox(
          color: Color.fromARGB(160, 255, 0, 0),
          child: mainStack,
        ),
      );
    }

    return /*MouseRegion(
      onEnter: (details) => _mouseEOAnimationController.forward(),
      onExit: (details) => _mouseEOAnimationController.reverse(),
      child:*/
        Container(
            height: widget.height.toDouble(),
            padding: const EdgeInsets.all(8),
            child: mainStack)
        /*.animate(controller: _mouseEOAnimationController, autoPlay: false)
          .scaleX(begin: 1.0, end: 1.01, duration: 100.ms)
          .scaleY(begin: 1.0, end: 1.02, duration: 100.ms),
    )*/
        ;
  }
}
