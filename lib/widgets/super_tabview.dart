import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../common/customnotifier.dart';
import '../models.dart';
import '../pages/work_detail_page.dart';

typedef OnChangeTabCallback = void Function(int index, bool isMaintainTabBar);

/// Use two TabBar to support both maintain and dynamic tabView together.
class _MutiTabBar extends StatefulWidget {
  _MutiTabBar({
    required this.maintainChildren,
    this.dynamicChildren = const [],
    required this.maintainTabController,
    this.dynamicTabController,
    required this.onChangeTab,
  }) {
    if (dynamicChildren.isNotEmpty) {
      assert(dynamicTabController != null);
      assert(dynamicChildren.length == dynamicTabController!.length);
    }
  }
  final List<Widget> maintainChildren;
  final List<Widget> dynamicChildren;
  final TabController maintainTabController;
  final TabController? dynamicTabController;
  final OnChangeTabCallback onChangeTab;
  @override
  State<StatefulWidget> createState() {
    return _MutiTabBarState();
  }
}

class _MutiTabBarState extends State<_MutiTabBar> {
  void _changeMaintainTab(int index) {
    widget.maintainTabController.animateTo(index);
    widget.onChangeTab(index, true);
  }

  void _changeDynamicTab(int index) {
    widget.dynamicTabController!.animateTo(index);
    widget.onChangeTab(index, false);
  }

  void _moveToPreviousTab() {
    if (widget.dynamicTabController!.index > 0) {
      widget.dynamicTabController!
          .animateTo(widget.dynamicTabController!.index - 1);
      widget.onChangeTab(widget.dynamicTabController!.index, false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Can't go back"),
      ));
    }
  }

  void _moveToNextTab() {
    if (widget.dynamicTabController!.index + 1 <
        widget.dynamicTabController!.length) {
      widget.dynamicTabController!
          .animateTo(widget.dynamicTabController!.index + 1);
      widget.onChangeTab(widget.dynamicTabController!.index, false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Can't move forward"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A fixed TabBar to display Tabs which won't be changed by user.
        TabBar(
            controller: widget.maintainTabController,
            onTap: _changeMaintainTab,
            tabs: widget.maintainChildren),
        // A fixed TabBar to display Tabs which maybe be changed by user.
        if (widget.dynamicChildren.isNotEmpty)
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: _moveToPreviousTab,
              ),
              Expanded(
                  child: TabBar(
                      isScrollable: true,
                      controller: widget.dynamicTabController,
                      onTap: _changeDynamicTab,
                      tabs: widget.dynamicChildren)),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                ),
                onPressed: _moveToNextTab,
              ),
            ],
          ),
      ],
    );
  }
}

/// A widget enable dynamically add or remove tab and maintain some tab unchangable.
/// And the different type of tabs well be controlled dividedly.
class SuperTabView extends StatefulWidget {
  SuperTabView({
    super.key,
    Widget? unloadWidget,
    this.initialIndex,
    required this.maintainTabDatas,
    required this.preloadIndex,
  }) {
    this.unloadWidget = unloadWidget ?? Container();
  }
  late final Widget unloadWidget;

  /// Must be maintainTabIndex.
  final int? initialIndex;
  final List<TabData> maintainTabDatas;
  final List<int> preloadIndex;
  @override
  State<StatefulWidget> createState() => SuperTabViewState();
}

class SuperTabViewState extends State<SuperTabView>
    with TickerProviderStateMixin {
  late final AnimationController _dargEOController;
  int maintainTabIndex = 0;
  int dynamicTabIndex = 0;
  bool isMaintainTab = true;
  final List<int> loadedIndex = [];
  final List<UniqueKey> maintainTabKeys = [];
  final List<UniqueKey> dynamicTabKeys = [];
  final List<Widget> maintainChildren = [];
  final List<Widget> dynamicChildren = [];
  final List<Widget> maintainTab = [];
  final List<Widget> dynamicTab = [];
  late final TabController maintainTabController;
  late TabController dynamicTabController;

  void addTab(TabData data) {
    // Update tab and child
    dynamicTab.add(SizedBox(
        width: 300,
        child: ListTile(
          title: Text(data.title,
              maxLines: 1, style: Theme.of(context).textTheme.titleSmall),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => _closeTab(data),
          ),
        )));
    dynamicChildren.add(data.child);
    // Update index
    dynamicTabIndex = dynamicChildren.length - 1;
    // Update keys
    dynamicTabKeys.add(UniqueKey());
    // Update tab
    isMaintainTab = false;
    // Update TabController
    dynamicTabController = TabController(
        initialIndex: dynamicTabIndex,
        length: dynamicChildren.length,
        vsync: this);
    // setState(() {});
  }

  void _closeTab(TabData data) {
    // Update tab and child
    final int index = dynamicChildren.indexOf(data.child);
    dynamicChildren.removeAt(index);
    dynamicTab.removeAt(index);
    // Update index
    if (dynamicTabIndex > index) {
      dynamicTabIndex -= 1;
    }
    if (dynamicTabIndex == dynamicChildren.length) {
      dynamicTabIndex -= 1;
    }
    // Update keys
    dynamicTabKeys.removeAt(index);
    // Update tab
    if (dynamicChildren.isEmpty) {
      isMaintainTab = true;
    } else {
      // Update TabController
      dynamicTabController = TabController(
          initialIndex: dynamicTabIndex,
          length: dynamicChildren.length,
          vsync: this);
    }
    setState(() {});
  }

  @override
  void initState() {
    // index
    loadedIndex.addAll(widget.preloadIndex);
    maintainTabIndex = widget.initialIndex ?? 0;
    // key tab children
    for (TabData data in widget.maintainTabDatas) {
      if (data.canBeClosed) {
        dynamicTabKeys.add(UniqueKey());
        dynamicChildren.add(data.child);
        dynamicTab.add(SizedBox(
            width: 300,
            child: ListTile(
              title: Text(data.title,
                  maxLines: 1, style: Theme.of(context).textTheme.titleSmall),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => _closeTab(data),
              ),
            )));
      } else {
        maintainTabKeys.add(UniqueKey());
        maintainChildren.add(data.child);
        maintainTab.add(Tab(
          text: data.title,
          icon: data.icon,
        ));
      }
    }
    // controller
    _dargEOController = AnimationController(vsync: this);
    maintainTabController = TabController(
        initialIndex: widget.initialIndex ?? 0,
        length: maintainChildren.length,
        vsync: this);
    dynamicTabController =
        TabController(length: dynamicChildren.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _dargEOController.dispose();
    maintainTabController.dispose();
    dynamicTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Consumer<AddStackNotifier>(builder: (context, notifier, child) {
      TabData? data = notifier.newData;
      if (data != null) {
        addTab(data);
      }
      return Column(
        children: [
          // Add work detail page
          RepaintBoundary(
                  child: DragTarget<WorkInfo>(
            onWillAcceptWithDetails: (details) {
              _dargEOController.forward();
              // Always accept add new tab.
              return true;
            },
            onLeave: (data) {
              _dargEOController.reverse();
            },
            onAcceptWithDetails: (details) => {
              context.read<AddStackNotifier>().addStack<WorkDetailPage>(
                  details.data.title, {'workInfo': details.data}),
              _dargEOController.reverse()
            },
            builder: (context, candidateData, rejectedData) {
              return _MutiTabBar(
                maintainChildren: maintainTab,
                dynamicChildren: dynamicTab,
                maintainTabController: maintainTabController,
                dynamicTabController:
                    dynamicTab.isNotEmpty ? dynamicTabController : null,
                onChangeTab: (index, isMaintainTabBar) {
                  // Update tab
                  isMaintainTab = isMaintainTabBar;
                  // Update index
                  if (isMaintainTabBar) {
                    maintainTabIndex = index;
                    loadedIndex.add(index);
                  } else {
                    dynamicTabIndex = index;
                  }
                  setState(() {});
                },
              );
            },
          ))
              .animate(controller: _dargEOController, autoPlay: false)
              .color(blendMode: BlendMode.darken),

          Expanded(
            child: Stack(
              children: [
                Offstage(
                  offstage: !isMaintainTab,
                  child:
                      TabBarView(controller: maintainTabController, children: [
                    // Maintain Tabs
                    for (int i = 0; i < maintainChildren.length; i++)
                      KeyedSubtree(
                          key: maintainTabKeys[i],
                          child: loadedIndex.contains(i)
                              ? KeepAliveWrapper(child: maintainChildren[i])
                              : widget.unloadWidget),
                  ]),
                ),
                if (dynamicChildren.isNotEmpty)
                  Offstage(
                    offstage: isMaintainTab,
                    child:
                        TabBarView(controller: dynamicTabController, children: [
                      // Dynamic Tabs
                      for (int i = 0; i < dynamicChildren.length; i++)
                        KeyedSubtree(
                            key: dynamicTabKeys[i],
                            child: KeepAliveWrapper(child: dynamicChildren[i]))
                    ]),
                  )
              ],
            ),
          )
        ],
      );
    });
  }
}

class TabData {
  final String title;
  final Widget? icon;
  final bool canBeClosed;
  final Widget child;

  const TabData({
    required this.title,
    this.icon,
    required this.canBeClosed,
    required this.child,
  });
}

class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });

  final bool keepAlive;
  final Widget child;

  @override
  State createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }
}
