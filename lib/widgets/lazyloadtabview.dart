import 'package:flutter_animate/flutter_animate.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';
import 'package:localpixiv/widgets/workcontainer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// 使用多个tabbar控制同一个indexedstage
class MutiTabbar extends StatefulWidget {
  const MutiTabbar({super.key, required this.mainTabs});
  final List<Tab> mainTabs;

  @override
  State<StatefulWidget> createState() {
    return MutiTabbarState();
  }
}

// TODO 关闭后切换图片出错, 现在似乎又好了？？？
class MutiTabbarState extends State<MutiTabbar> with TickerProviderStateMixin {
  late final AnimationController _dargEOController;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _dargEOController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _dargEOController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<StackChangeNotifier, List<String>>(
        selector: (context, stackData) {
      return List.unmodifiable(stackData.titles);
    }, builder: (context, titles, child) {
      _tabController = TabController(
        vsync: this,
        length: titles.length,
        initialIndex: titles.isEmpty ? titles.length : titles.length - 1,
      );
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
              WorkDetialDisplayer(
                hostPath: details.data.$1,
                cacheRate: context
                    .read<UIConfigUpdateNotifier>()
                    .uiConfigs
                    .imageCacheRate,
                workInfo: details.data.$2,
                onBookmarked: (isLiked, workId, userName) =>
                    Provider.of<WorkBookmarkModel>(context, listen: false)
                        .changebookmark(
                  isLiked,
                  workId,
                  userName,
                ),
              ));
        },
        builder: (context, candidateData, rejectedData) {
          return RepaintBoundary(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                  onTap: (value) => context
                      .read<StackChangeNotifier>()
                      .changeIndex(value, true),
                  tabs: widget.mainTabs),
              Offstage(
                offstage: titles.isEmpty,
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
              )
            ],
          )
                  .animate(controller: _dargEOController, autoPlay: false)
                  .color(blendMode: BlendMode.darken));
        },
      );
    });
  }

  _moveToNextTab() {
    if (_tabController.index + 1 < _tabController.length) {
      _tabController.animateTo(_tabController.index + 1);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't move forward"),
      // ));
    }
  }

  _moveToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Can't go back"),
      ));
    }
  }
}

/// An extended IndexedStack that builds the required widget only when it is needed, and returns the pre-built widget when it is needed again.
class LazyLoadIndexedStack extends StatelessWidget {
  /// Widget to be built when not loaded. Default widget is [Container].
  late final Widget unloadWidget;

  /// The widgets below this widget in the tree.
  ///
  /// A child widget will not be built until the index associated with it is specified.
  /// When the index associated with the widget is specified again, the built widget is returned.
  final List<StackData> children;

  /// Creates LazyLoadIndexedStack that wraps IndexedStack.
  LazyLoadIndexedStack({
    super.key,
    this.alignment = AlignmentDirectional.center,
    this.textDirection,
    this.clipBehavior = Clip.hardEdge,
    this.sizing = StackFit.loose,
    Widget? unloadWidget,
    required this.children,
  }) {
    this.unloadWidget = unloadWidget ?? SizedBox();
  }

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final Clip clipBehavior;
  final StackFit sizing;
  final List<Widget> _children = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<StackChangeNotifier>(builder: (context, stackDatas, child) {
      _updateChildren(stackDatas);
      return IndexedStack(
        alignment: alignment,
        index: stackDatas.index,
        children: _children,
      );
    });
  }

  void _updateChildren(StackChangeNotifier stackDatas) {
    int index = 0;
    for (StackData stackData in stackDatas.stackDatas) {
      Widget newChild = stackData.child;
      if (index < _children.length) {
        Widget oldChild = _children[index];
        if ((oldChild.hashCode == newChild.hashCode) &
            (oldChild.runtimeType == newChild.runtimeType)) {
        } else {
          _children[index] = newChild;
        }
      } else {
        _children.add(newChild);
      }
      index++;
    }
  }
}

/// An extended IndexedStack that builds the required widget only when it is needed, and returns the pre-built widget when it is needed again.
class LazyLoadIndexedStackStateful extends StatefulWidget {
  /// Widget to be built when not loaded. Default widget is [Container].
  late final Widget unloadWidget;

  /// The widgets below this widget in the tree.
  ///
  /// A child widget will not be built until the index associated with it is specified.
  /// When the index associated with the widget is specified again, the built widget is returned.
  final List<StackData> children;

  /// Creates LazyLoadIndexedStack that wraps IndexedStack.
  LazyLoadIndexedStackStateful({
    super.key,
    this.alignment = AlignmentDirectional.center,
    this.textDirection,
    this.clipBehavior = Clip.hardEdge,
    this.sizing = StackFit.loose,
    Widget? unloadWidget,
    required this.children,
  }) {
    this.unloadWidget = unloadWidget ?? Container();
  }

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final Clip clipBehavior;
  final StackFit sizing;

  @override
  LazyLoadIndexedStackState createState() => LazyLoadIndexedStackState();
}

class LazyLoadIndexedStackState extends State<LazyLoadIndexedStackStateful> {
  final List<Widget> _children = [];
  //final Map<int, Widget> childrenMap = {};
  //final List<Visibility> wrappedChildren = [];
  final List<bool> needUpdate = [false];

  @override
  void initState() {
    //int index = 0;
    for (StackData data in widget.children) {
      /*wrappedChildren.add(Visibility.maintain(
        visible: index == 0,
        child: data.child,
      ));*/
      //childrenMap.addAll({index: data.child});
      //index++;

      _children.add(data.child);
    }
    super.initState();
  }

  /// The index of the child to show.
  @override
  void didUpdateWidget(final LazyLoadIndexedStackStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*if (widget.children.length > _children.length) {
      //_children = _initialChildren();
      for (int index = _children.length;
          index < widget.children.length;
          index++) {
        _children.add(widget.children[index]);
      }
    }
    else if (widget.children.length < _children.length) {
      //_children = _initialChildren();
      for (int index =0;
          index < widget.children.length;
          index++) {
        _children.add(widget.children[index]);
      }
    }
    _children[widget.index] = widget.children[widget.index];*/
  }

  // 可以确定，是由于list中元素索引的变化导致更新。即如果其在列表中索引不变，那么状态会一直保持。当索引改变时，会出现部分保持的现象。
  // 测试发现，当index对应的原widget被替换时，widget本身被替换了，但是如InteractiveViewer的状态是保留的，也就是说，在RawIndexedStack内部，
  // 其缓存的RenderObject没有完全与widget关联。
  // 基于此，一种可行的解决方法是在移除某个widget后，并不在list中移除它，而是用不占用资源的widget替换，并在后续操作中忽略其所在的index (当前方法)
  // TODO 另一种更好的解决方法是自己覆写MultiChildRenderObjectElement类，实现_IndexedStackElement的效果

  @override
  Widget build(final BuildContext context) {
    return Consumer<StackChangeNotifier>(builder: (context, stackDatas, child) {
      _updateChildren(stackDatas);
      return IndexedStack(
        alignment: widget.alignment,
        index: stackDatas.index,
        children: _children,
      );
      /*
      final List<Widget> wrappedChildren =
          List<Widget>.generate(_children.length, (int i) {
        return Visibility.maintain(
          visible: i == stackDatas.index,
          child: _children[i],
        );
      });
      return _MyRawIndexedStack(
        alignment: widget.alignment,
        textDirection: widget.textDirection,
        clipBehavior: widget.clipBehavior,
        sizing: widget.sizing,
        index: stackDatas.index,
        needUpdate: needUpdate,
        children: wrappedChildren,
      );*/
    });
  }

  void _updateChildren(StackChangeNotifier stackDatas) {
    //final List<Widget> newchildren = [];
    //int index = stackDatas.index;
    int index = 0;
    for (StackData stackData in stackDatas.stackDatas) {
      Widget newChild = stackData.child;
      if (index < _children.length) {
        Widget oldChild = _children[index];
        if ((oldChild.hashCode == newChild.hashCode) &
            (oldChild.runtimeType == newChild.runtimeType)) {
          //print('yes $index');
        } else {
          //print('no $index');
          _children[index] = newChild;
        }
      } else {
        //print('Add $index');
        _children.add(newChild);
        /*childrenMap.update(
          index,
          (_) => newChild,
          ifAbsent: () => newChild,
        );*/
      }
      index++;
    }
    /*
    return stackData.stacks.asMap().entries.map((entry) {
      final index = entry.key;
      final childWidget = entry.value;

      if (stackData.loadedIndex.contains(index)) {
        return childWidget;
      } else if (index == stackData.index) {
        stackData.updateLoadedIndex(index);
        return childWidget;
      } else {
        return widget.unloadWidget;
      }
    }).toList();*/
  }
}
