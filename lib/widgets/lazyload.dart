import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:localpixiv/common/customnotifier.dart';
import 'package:localpixiv/models.dart';
import 'package:provider/provider.dart';

const String defaultdata = '''
{
  "type": "illust",
  "id": 114514,
  "title": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌",
  "description": "꒰ঌ(🎀 ᗜ`˰´ᗜ 🌸)໒꒱💈❌+و(◠ڼ◠)٩ =꒰ঌ(🎀ᗜ v ᗜ 🌸)໒꒱✅",
  "tags": {
    "水着": "泳装",
    "女の子": "女孩子",
    "オリジナル": "原创",
    "太もも": "大腿",
    "海": "sea",
    "浮き輪": "游泳圈",
    "イラスト": "插画"
  },
  "userId": "114514",
  "username": "Man",
  "uploadDate": "2042",
  "likeData": true,
  "isOriginal": true,
  "imageCount": 1,
  "relative_path": [
    "what can I say"
  ]
}
''';

/// An extended IndexedStack that builds the required widget only when it is needed, and returns the pre-built widget when it is needed again.
class LazyLoadIndexedStack extends StatefulWidget {
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
    this.alignment = AlignmentDirectional.topStart,
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

class LazyLoadIndexedStackState extends State<LazyLoadIndexedStack> {
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
  void didUpdateWidget(final LazyLoadIndexedStack oldWidget) {
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
  // 其缓存的state没有与widget关联。
  // 基于此，一种可行的解决方法是在移除某个widget后，并不在list中移除它，而是用不占用资源的widget替换，并在后续操作中忽略其所在的index (当前方法)
  // TODO另一种更好的解决方法是自己覆写MultiChildRenderObjectElement类，实现_IndexedStackElement的效果

  @override
  Widget build(final BuildContext context) {
    return Consumer<StackChangeNotifier>(builder: (context, stackDatas, child) {
      _updateChildren(stackDatas);
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
      );
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

/// The render object widget that backs [LazyLoadIndexedStackState].
class _MyRawIndexedStack extends Stack {
  /// Creates a [Stack] widget that paints a single child.
  const _MyRawIndexedStack({
    super.alignment,
    super.textDirection,
    super.clipBehavior,
    StackFit sizing = StackFit.loose,
    this.index = 0,
    required this.needUpdate,
    super.children,
  }) : super(fit: sizing);

  /// The index of the child to show.
  final int? index;
  final List<bool> needUpdate;

  @override
  RenderIndexedStack createRenderObject(BuildContext context) {
    return MyRenderIndexedStack(
      index: index,
      needUpdate: needUpdate[0],
      fit: fit,
      clipBehavior: clipBehavior,
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, MyRenderIndexedStack renderObject) {
    renderObject
      ..index = index
      ..needUpdate = needUpdate[0]
      ..fit = fit
      ..clipBehavior = clipBehavior
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _IndexedStackElement(this);
  }
}

class _IndexedStackElement extends MultiChildRenderObjectElement {
  _IndexedStackElement(_MyRawIndexedStack super.widget);

  @override
  _MyRawIndexedStack get widget => super.widget as _MyRawIndexedStack;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final int? index = widget.index;
    // If the index is null, no child is onstage. Otherwise, only the child at
    // the selected index is.
    if (index != null && children.isNotEmpty) {
      visitor(children.elementAt(index));
    }
  }

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @override
  @protected
  @visibleForTesting
  Iterable<Element> get children =>
      _children.where((Element child) => !_forgottenChildren.contains(child));

  late List<Element> _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child, after: slot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element?> oldSlot,
      IndexedSlot<Element?> newSlot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'The children of `MultiChildRenderObjectElement` must each has an associated render object.'),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                  'The following element does not have an associated render object'),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    final MultiChildRenderObjectWidget multiChildRenderObjectWidget =
        widget as MultiChildRenderObjectWidget;
    final List<Element> children = List<Element>.filled(
        multiChildRenderObjectWidget.children.length, _NullElement.instance);
    Element? previousChild;
    for (int i = 0; i < children.length; i += 1) {
      final Element newChild = inflateWidget(
          multiChildRenderObjectWidget.children[i],
          IndexedSlot<Element?>(i, previousChild));
      children[i] = newChild;
      previousChild = newChild;
    }
    _children = children;
  }

  @override
  void update(MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    final MultiChildRenderObjectWidget multiChildRenderObjectWidget =
        widget as MultiChildRenderObjectWidget;
    assert(widget == newWidget);
    assert(!debugChildrenHaveDuplicateKeys(
        widget, multiChildRenderObjectWidget.children));
    _children = updateChildren(_children, multiChildRenderObjectWidget.children,
        forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }
}

class MyRenderIndexedStack extends RenderIndexedStack {
  MyRenderIndexedStack({
    super.children,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
    int? index = 0,
    required this.needUpdate,
  });
  bool needUpdate;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final RenderBox? displayedChild = _childAtIndex();
    if (displayedChild != null) {
      visitor(displayedChild);
    }
  }

  RenderBox? _childAtIndex() {
    final int? index = this.index;
    if (index == null) {
      return null;
    }
    RenderBox? child = firstChild;
    for (int i = 0; i < index && child != null; i += 1) {
      child = childAfter(child);
    }
    assert(firstChild == null || child != null);
    return child;
  }
}

class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
