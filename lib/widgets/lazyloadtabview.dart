import 'package:flutter_animate/flutter_animate.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db;

import '../pages/work_detail_page.dart';
import '../common/customnotifier.dart';
import '../models.dart';
import '../settings/settings_controller.dart';

/// 使用多个tabbar控制同一个indexedstage
class MutiTabbar extends StatefulWidget {
  const MutiTabbar(
      {super.key,
      required this.mainTabs,
      required this.initialIndex,
      required this.controller,
      required this.pixivDb});
  final List<Tab> mainTabs;
  final int initialIndex;
  final SettingsController controller;
  // TODO 修改
  final Db pixivDb;

  @override
  State<StatefulWidget> createState() {
    return MutiTabbarState();
  }
}

class MutiTabbarState extends State<MutiTabbar> with TickerProviderStateMixin {
  late final AnimationController _dargEOController;
  late TabController _maintabController;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _dargEOController = AnimationController(vsync: this);
    _maintabController = TabController(
        length: widget.mainTabs.length,
        vsync: this,
        initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _dargEOController.dispose();
    _maintabController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<(String, WorkInfo)>(
      onWillAcceptWithDetails: (details) {
        _dargEOController.forward();
        return true;
      },
      onLeave: (data) {
        _dargEOController.reverse();
      },
      onAcceptWithDetails: (details) {
        _dargEOController.reverse();
        context.read<StackChangeNotifier>().addStack(
            details.data.$2.title,
            WorkDetailPage(
              controller: widget.controller,
              workInfo: details.data.$2,
              pixivDb: widget.pixivDb,
            ));
      },
      builder: (context, candidateData, rejectedData) {
        return RepaintBoundary(child:
            Consumer<StackChangeNotifier>(builder: (context, value, child) {
          final List<String> titles = value.titles;
          bool offstage = true;
          int index = 0;
          if (value.index >= value.mainTabCount) {
            index = value.index - value.mainTabCount;
          }
          if (value.titles.isNotEmpty) {
            offstage = false;
          }
          _tabController = TabController(
            vsync: this,
            length: titles.length,
            initialIndex: index,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                  controller: _maintabController,
                  onTap: (value) => context
                      .read<StackChangeNotifier>()
                      .changeIndex(value, true),
                  tabs: widget.mainTabs),
              Offstage(
                offstage: offstage,
                child: Row(
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
                            controller: _tabController,
                            onTap: (value) => context
                                .read<StackChangeNotifier>()
                                .changeIndex(value, false),
                            tabs: [
                          for (int index = 0; index < titles.length; index++)
                            SizedBox(
                                width: 300,
                                child: ListTile(
                                  title: Text(titles[index],
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  trailing: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      context
                                          .read<StackChangeNotifier>()
                                          .removeAt(
                                            index,
                                          );
                                    },
                                  ),
                                ))
                        ])),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                      onPressed: _moveToNextTab,
                    ),
                  ],
                ),
              ),
            ],
          )
              .animate(controller: _dargEOController, autoPlay: false)
              .color(blendMode: BlendMode.darken);
        }));
      },
    );
  }

  _moveToNextTab() {
    if (_tabController.index + 1 < _tabController.length) {
      _tabController.animateTo(_tabController.index + 1);
      context
          .read<StackChangeNotifier>()
          .changeIndex(_tabController.index, false);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't move forward"),
      // ));
    }
  }

  _moveToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
      context
          .read<StackChangeNotifier>()
          .changeIndex(_tabController.index, false);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't go back"),
      // ));
    }
  }
}
// 可以确定，是由于list中元素索引的变化导致更新。即如果其在列表中索引不变，那么状态会一直保持。当索引改变时，会出现部分保持的现象。
// 测试发现，当index对应的原widget被替换时，widget本身被替换了，但是如InteractiveViewer的状态是保留的，也就是说，在RawIndexedStack内部，
// 其缓存的RenderObject没有完全与widget关联。
// 基于此，一种可行的解决方法是在移除某个widget后，并不在list中移除它，而是用不占用资源的widget替换，并在后续操作中忽略其所在的index (当前方法)
// 另一种更好的解决方法是自己覆写MultiChildRenderObjectElement类，实现_IndexedStackElement的效果
// 2024.12.15 -> 使用key即可解决
// 猜测是indexedstack在列表长度不变时只改变了child但是没有改变key

class LazyLoadIndexedStack extends StatefulWidget {
  late final Widget unloadWidget;
  final List<StackData> datas;

  LazyLoadIndexedStack({
    super.key,
    Widget? unloadWidget,
    required this.datas,
    required this.preloadIndex,
  }) {
    this.unloadWidget = unloadWidget ?? Container();
  }

  final List<int> preloadIndex;
  @override
  State<StatefulWidget> createState() => LazyLoadIndexedStackState();
}

class LazyLoadIndexedStackState extends State<LazyLoadIndexedStack> {
  final List<int> loadedIndex = [];
  final List<UniqueKey> keys = [];
  final List<Widget> children = [];

  @override
  void initState() {
    loadedIndex.addAll(widget.preloadIndex);
    for (StackData data in widget.datas) {
      keys.add(UniqueKey());
      children.add(data.child);
    }
    for (StackData data in context
        .read<StackChangeNotifier>()
        .stackDatas
        .sublist(widget.datas.length)) {
      keys.add(UniqueKey());
      children.add(data.child);
      super.initState();
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Consumer<StackChangeNotifier>(builder: (context, notifier, child) {
      if (!loadedIndex.contains(notifier.index)) {
        loadedIndex.add(notifier.index);
      }
      if (notifier.operation == StackOperation.changeIndex) {
      } else if (notifier.operation == StackOperation.add) {
        assert(notifier.stackDatas.length - children.length == 1);
        _addChild(notifier.stackDatas[children.length]);
      } else if (notifier.operation == StackOperation.remove) {
        loadedIndex.removeWhere((i) => i == children.length - 1);
        _removeChild(notifier.removeIndex);
      } else {
        //throw 'fuck';
      }
      return Stack(
        children: [
          for (int i = 0; i < children.length; i++)
            loadedIndex.contains(i)
                ? Offstage(
                    key: keys[i],
                    offstage: notifier.index != i,
                    child: children[i])
                : widget.unloadWidget
        ],
      );
    });
  }

  void _addChild(StackData data) {
    children.add(data.child);
    keys.add(UniqueKey());
  }

  void _removeChild(int index) {
    children.removeAt(index);
    keys.removeAt(index);
  }
}
