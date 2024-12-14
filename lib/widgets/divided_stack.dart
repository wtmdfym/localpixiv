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
      this.defaultLeftOccupied = 0.2}) {
    assert((0 <= minLeftOccupied) || (minLeftOccupied < maxLeftOccupied),
        'The value of minLeftOccupied must be positive and smaller than maxLeftOccupied');
    assert((0 < maxLeftOccupied) || (maxLeftOccupied <= 1),
        'The value of maxLeftOccupied must be in (0, 1]');
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
  final double defaultLeftOccupied;
  @override
  State<StatefulWidget> createState() {
    return _DividedStackState();
  }
}

class _DividedStackState extends State<DividedStack> {
  late double _dividerPosition; // 分隔条初始位置
  late double _movingdividerPosition; // 分隔条移动时的位置
  late bool isLeftRight; // 是否为左右布局（否则为上下布局）
  bool changeMouseCursor = false;

  @override
  void initState() {
    super.initState();
    _dividerPosition = widget.defaultLeftOccupied;
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
          cursor: changeMouseCursor
              ? isLeftRight
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.resizeUpDown
              : MouseCursor.defer,
          child: Stack(children: [
            Positioned(
                left: 0,
                top: 0,
                width: isLeftRight ? leftSpacing : constraints.maxWidth,
                height: isLeftRight ? constraints.maxHeight : leftSpacing,
                child: widget.leftWidget ?? SizedBox()),
            Positioned(
                right: 0,
                bottom: 0,
                width: isLeftRight ? rightSpacing : constraints.maxWidth,
                height: isLeftRight ? constraints.maxHeight : rightSpacing,
                child: widget.rightWidget ?? SizedBox()),
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
              height: isLeftRight ? constraints.maxHeight : widget.dividerWidth,
              child: Draggable(
                  axis: widget.dividedDirection,
                  feedback: ColoredBox(
                    color: Colors.cyanAccent,
                  ),
                  childWhenDragging: ColoredBox(
                    color: Colors.cyanAccent,
                  ),
                  onDragStarted: () => setState(() {
                        changeMouseCursor = true;
                      }),
                  onDragUpdate: (details) {
                    setState(() {
                      _movingdividerPosition +=
                          (isLeftRight ? details.delta.dx : details.delta.dy) /
                              constraints.maxWidth;
                      if (_movingdividerPosition > widget.maxLeftOccupied) {
                        _dividerPosition = widget.maxLeftOccupied;
                      } else if (_movingdividerPosition <
                          widget.minLeftOccupied) {
                        _dividerPosition = widget.minLeftOccupied;
                      } else {
                        _dividerPosition = _movingdividerPosition;
                      }
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      changeMouseCursor = false;
                      _movingdividerPosition = _dividerPosition;
                    });
                  },
                  child: ColoredBox(color: Colors.grey)),
            ),
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
