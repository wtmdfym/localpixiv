import 'dart:async' show Timer;

import 'package:contextmenu/contextmenu.dart' show ContextMenuArea;
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, where;
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../containers/info_container.dart';
import '../containers/work_container.dart';
import '../settings/settings_controller.dart';
import '../common/tools.dart';
import '../common/customnotifier.dart';
import '../models.dart';
import '../widgets/dialogs.dart' show resultDialog;
import '../widgets/divided_stack.dart';
import '../widgets/should_rebuild_widget.dart';
import '../localization/localization.dart';

/// A page to show detail information about a user.
class UserDetailPage extends StatefulWidget {
  UserDetailPage({
    super.key,
    required this.controller,
    this.userInfo,
    this.userName,
    this.pixivDb,
    required this.onWorkBookmarked,
  }) {
    assert((userInfo != null) || ((pixivDb != null) && (userName != null)));
  }

  final SettingsController controller;
  final UserInfo? userInfo;
  final String? userName;
  final Db? pixivDb;
  final WorkBookmarkCallback onWorkBookmarked;

  @override
  State<StatefulWidget> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // localized text
  late String Function(String) _localizationMap;
  late final ScrollController _scrollController = ScrollController();
  late final UserInfo _userInfo;
  late final int totalWorkCount;
  bool userInfoNotLoaded = true;
  int rowCount = 0;
  final int buffer = 16;
  bool needsLoad = false;
  bool allLoaded = false;
  int loadIndex = 0;
  final ListNotifier<WorkInfo> loadedWorkInfosNotifier =
      ListNotifier<WorkInfo>([]);
  final int workWidth = 400;

  void dataPreLoader() async {
    if (widget.userInfo != null) {
      _userInfo = widget.userInfo!;
    } else {
      Map<String, dynamic>? info = await widget.pixivDb!
          .collection('All Followings')
          .findOne(
              where.eq('userName', widget.userName).excludeFields(['_id']));
      _userInfo = await fetchUserInfo(info!, widget.pixivDb!);
    }
    totalWorkCount = _userInfo.workInfos.length;
    if (buffer > totalWorkCount) {
      loadedWorkInfosNotifier.addAll(_userInfo.workInfos);
      allLoaded = true;
    } else {
      loadIndex++;
      loadedWorkInfosNotifier
          .addAll(_userInfo.workInfos.sublist(0, loadIndex * buffer));
    }
    setState(() {
      userInfoNotLoaded = false;
    });
    dataLoader();
  }

  void dataLoader() {
    if (allLoaded) return;
    Timer.periodic(Durations.medium1, (timer) async {
      if (!needsLoad) return;
      if ((loadIndex + 1) * buffer >= totalWorkCount) {
        loadedWorkInfosNotifier
            .addAll(_userInfo.workInfos.sublist(loadIndex * buffer));
        timer.cancel();
        allLoaded = true;
        needsLoad = false;
      } else {
        loadedWorkInfosNotifier.addAll(_userInfo.workInfos
            .sublist(loadIndex * buffer, (loadIndex + 1) * buffer));
        loadIndex++;
        needsLoad = false;
      }
    });
  }

  void scrollListener() {
    if (allLoaded) {
      _scrollController.removeListener(scrollListener);
      return;
    }
    if (_scrollController.position.extentAfter < rowCount) {
      needsLoad = true;
    }
  }

  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    dataPreLoader();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).userDetialPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (userInfoNotLoaded) {
      return SizedBox();
    }
    return DividedStack(
      padding: const EdgeInsets.all(8),
      dividedDirection: Axis.vertical,
      leftWidget: ContextMenuArea(
          builder: (context) => [
                ListTile(
                  title: Text('Open in file explorer'),
                  onTap: () {
                    openFileExplorerAndSelectFile(
                        '${widget.controller.hostPath}picture/${_userInfo.userId}',
                        isFile: false);
                  },
                ),
                ListTile(
                  title: Text('Open in browser'),
                  onTap: () {
                    launchUrl(Uri.parse(
                            "https://www.pixiv.net/users/${_userInfo.userId}"))
                        .then((success) => success
                            ? {}
                            : {
                                resultDialog(
                                    _userInfo.userName.toLowerCase(), success)
                              });
                  },
                )
              ],
          child: UserInfoContainer(
              userInfo: _userInfo,
              hostPath: widget.controller.hostPath,
              imageCacheRate: widget.controller.imageCacheRate)),
      rightWidget: LayoutBuilder(builder: (context, constraints) {
        final int newRowCount = (constraints.maxWidth / workWidth).round();
        if (rowCount == 0) {
          rowCount = newRowCount;
        }
        return ShouldRebuildWidget(
            shouldRebuild: (oldWidget, newWidget) {
              if (rowCount == newRowCount) return false;
              if (newRowCount == 0) return false;
              // To keep the position when change rowCount
              final double newPosition =
                  (_scrollController.position.extentBefore +
                          _scrollController.position.extentInside / rowCount) *
                      rowCount /
                      newRowCount;
              _scrollController.position.jumpTo(newPosition);
              rowCount = newRowCount;
              // Change buffer will cause some data not be loaded.
              // buffer = onceLoad * rowCount;
              return true;
            },
            child: ValueListenableBuilder(
              valueListenable: loadedWorkInfosNotifier,
              builder: (context, loadedWorkInfos, child) {
                final int maxpage = (loadedWorkInfos.length / rowCount).ceil();
                return ListView.builder(
                    padding: const EdgeInsets.only(right: 4),
                    controller: _scrollController,
                    itemCount: maxpage + 1,
                    itemBuilder: (context, index) {
                      if (index == maxpage) {
                        if (allLoaded) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 48,
                              child: Text(
                                _localizationMap('no_more_data'),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(strokeWidth: 6),
                            ),
                          );
                        }
                      } else {
                        final List<WorkInfo> rowInfos;
                        if ((index + 1) * rowCount <= loadedWorkInfos.length) {
                          rowInfos = loadedWorkInfos.sublist(
                              index * rowCount, (index + 1) * rowCount);
                        } else {
                          rowInfos = loadedWorkInfos.sublist(index * rowCount);
                        }
                        final int lake = rowCount - rowInfos.length;
                        return Padding(
                            padding:
                                const EdgeInsets.only(right: 12, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 16,
                              children: [
                                for (WorkInfo info in rowInfos)
                                  Expanded(
                                      child: WorkContainer(
                                    hostPath: widget.controller.hostPath,
                                    width: workWidth,
                                    workInfo: info,
                                    cacheRate: widget.controller.imageCacheRate,
                                    onTap: () => {},
                                    onBookmarked: (isLiked, workId, userName) =>
                                        widget.onWorkBookmarked(
                                      isLiked,
                                      workId,
                                      userName,
                                    ),
                                  )),
                                for (int i = 0; i < lake; i++)
                                  Expanded(
                                    child: SizedBox(),
                                  )
                              ],
                            ));
                      }
                    });
              },
            ));
      }),
      additionalWidgets: [
        Positioned(
            right: 5,
            bottom: 5,
            child: IconButton.filledTonal(
              icon: Icon(Icons.arrow_upward),
              onPressed: () => _scrollController.animateTo(0,
                  duration: Durations.long2, curve: Curves.easeInOut),
            ))
      ],
    );
  }
}
