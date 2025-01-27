import 'package:flutter/material.dart';

class DividedStack extends StatefulWidget {
  DividedStack(
      {super.key,
      this.leftWidget,
      this.rightWidget,
      this.additionalWidgets,
      this.padding,
      this.dividedDirection = Axis.horizontal,
      this.dividerWidth = 4,
      this.dividerSpacing = 8,
      this.minLeftOccupied = 0.2,
      this.maxLeftOccupied = 0.4,
      double defaultLeftOccupied = 0.2,
      this.isFoldable = true}) {
    assert((0 <= minLeftOccupied) || (minLeftOccupied < maxLeftOccupied),
        'The value of minLeftOccupied must be positive and smaller than maxLeftOccupied');
    assert((0 < maxLeftOccupied) || (maxLeftOccupied <= 1),
        'The value of maxLeftOccupied must be in (0, 1]');
    // Make sure the default value is between min and max value.
    if (defaultLeftOccupied < minLeftOccupied) {
      _defaultLeftOccupied = minLeftOccupied;
    } else if (defaultLeftOccupied > maxLeftOccupied) {
      _defaultLeftOccupied = maxLeftOccupied;
    } else {
      _defaultLeftOccupied = defaultLeftOccupied;
    }
  }
  final EdgeInsetsGeometry? padding;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final List<Positioned>? additionalWidgets;
  final Axis dividedDirection;
  final double dividerWidth;
  final int dividerSpacing;
  final double minLeftOccupied;
  final double maxLeftOccupied;
  late final double _defaultLeftOccupied;

  /// Fold the widget if drag to the edge of stack.
  final bool isFoldable;
  @override
  State<StatefulWidget> createState() {
    return _DividedStackState();
  }
}

class _DividedStackState extends State<DividedStack> {
  late double _dividerPosition; // The initial position of divider.
  late double _movingdividerPosition; // The position of divider when moving.
  late bool
      isLeftRight; // Use LeftRight layout if true, otherwise use UpDown layout.
  bool isDraging = false;
  bool changeMouseCursor = false;
  _FoldLeftRight foldLeftRigth = _FoldLeftRight.neither;

  @override
  void initState() {
    super.initState();
    _dividerPosition = widget._defaultLeftOccupied;
    _movingdividerPosition = _dividerPosition;
    isLeftRight = widget.dividedDirection == Axis.horizontal ? true : false;
  }

  // 构造界面
  @override
  Widget build(BuildContext context) {
    Widget current = LayoutBuilder(builder: (context, constraints) {
      final double maxSpacing =
          isLeftRight ? constraints.maxWidth : constraints.maxHeight;
      final double leftSpacing =
          maxSpacing * _dividerPosition - widget.dividerSpacing;
      final double rightSpacing =
          maxSpacing * (1 - _dividerPosition) - widget.dividerSpacing;
      return MouseRegion(
          cursor: isDraging || changeMouseCursor
              ? isLeftRight
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.resizeUpDown
              : MouseCursor.defer,
          child: Stack(children: [
            Positioned(
                left: 0,
                top: 0,
                width: foldLeftRigth == _FoldLeftRight.left
                    ? 0
                    : isLeftRight
                        ? leftSpacing
                        : constraints.maxWidth,
                height: foldLeftRigth == _FoldLeftRight.left
                    ? 0
                    : isLeftRight
                        ? constraints.maxHeight
                        : leftSpacing,
                child: Offstage(
                    offstage: foldLeftRigth == _FoldLeftRight.left,
                    child: widget.leftWidget ?? SizedBox())),
            Positioned(
                right: 0,
                bottom: 0,
                width: foldLeftRigth == _FoldLeftRight.right
                    ? 0
                    : isLeftRight
                        ? rightSpacing
                        : constraints.maxWidth,
                height: foldLeftRigth == _FoldLeftRight.right
                    ? 0
                    : isLeftRight
                        ? constraints.maxHeight
                        : rightSpacing,
                child: Offstage(
                    offstage: foldLeftRigth == _FoldLeftRight.right,
                    child: widget.rightWidget ?? SizedBox())),
            Positioned(
                left: isLeftRight
                    ? constraints.maxWidth * _dividerPosition -
                        (widget.dividerWidth / 2)
                    : 0,
                top: isLeftRight
                    ? 0
                    : constraints.maxHeight * _dividerPosition -
                        (widget.dividerWidth / 2),
                width: isLeftRight ? widget.dividerWidth : constraints.maxWidth,
                height:
                    isLeftRight ? constraints.maxHeight : widget.dividerWidth,
                child: MouseRegion(
                  onEnter: (event) => setState(() => changeMouseCursor = true),
                  onExit: (event) => setState(() => changeMouseCursor = false),
                  child: Draggable(
                      axis: widget.dividedDirection,
                      feedback: ColoredBox(
                        color: Theme.of(context).primaryColor,
                      ),
                      childWhenDragging: ColoredBox(
                        color: Theme.of(context).primaryColor,
                      ),
                      onDragStarted: () => setState(() {
                            isDraging = true;
                          }),
                      onDragUpdate: (details) {
                        setState(() {
                          _movingdividerPosition += (isLeftRight
                                  ? details.delta.dx
                                  : details.delta.dy) /
                              (isLeftRight
                                  ? constraints.maxWidth
                                  : constraints.maxHeight);
                          if (foldLeftRigth == _FoldLeftRight.neither) {
                            if (_movingdividerPosition >
                                widget.maxLeftOccupied) {
                              _dividerPosition = widget.maxLeftOccupied;
                            } else if (_movingdividerPosition <
                                widget.minLeftOccupied) {
                              _dividerPosition = widget.minLeftOccupied;
                            } else {
                              _dividerPosition = _movingdividerPosition;
                            }
                            if (_movingdividerPosition <
                                widget.minLeftOccupied / 2) {
                              foldLeftRigth = _FoldLeftRight.left;
                            } else if (_movingdividerPosition >
                                (1 + widget.maxLeftOccupied) / 2) {
                              foldLeftRigth = _FoldLeftRight.right;
                            }
                          } else if (foldLeftRigth == _FoldLeftRight.left) {
                            if (_movingdividerPosition >=
                                widget.minLeftOccupied / 2) {
                              foldLeftRigth = _FoldLeftRight.neither;
                            }
                            _dividerPosition = widget.dividerWidth /
                                (isLeftRight
                                    ? constraints.maxWidth
                                    : constraints.maxHeight);
                          } else if (foldLeftRigth == _FoldLeftRight.right) {
                            if (_movingdividerPosition <=
                                (1 + widget.maxLeftOccupied) / 2) {
                              foldLeftRigth = _FoldLeftRight.neither;
                            }
                            _dividerPosition = (isLeftRight
                                    ? constraints.maxWidth - widget.dividerWidth
                                    : constraints.maxHeight -
                                        widget.dividerWidth) /
                                (isLeftRight
                                    ? constraints.maxWidth
                                    : constraints.maxHeight);
                          }
                        });
                      },
                      onDragEnd: (details) {
                        setState(() {
                          isDraging = false;
                          _movingdividerPosition = _dividerPosition;
                        });
                      },
                      child:
                          ColoredBox(color: Theme.of(context).highlightColor)),
                )),
            for (Positioned positioned in widget.additionalWidgets ?? [])
              positioned
          ]));
    });
    if (widget.padding != null) {
      current = Padding(
        padding: widget.padding!,
        child: current,
      );
    }
    return current;
  }
}

enum _FoldLeftRight { left, right, neither }
