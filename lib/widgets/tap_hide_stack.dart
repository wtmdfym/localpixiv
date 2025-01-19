import 'package:flutter/material.dart';

/// A page to show detial information about a work.
class TapHideStack extends StatefulWidget {
  const TapHideStack({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
    required this.leftOccupied,
    required this.duration,
    this.isInitialShow = true,
    this.additionalWidgets,
    this.padding,
    this.dividedDirection = Axis.horizontal,
  });
  final EdgeInsetsGeometry? padding;
  final Widget leftWidget;
  final Widget rightWidget;
  final double leftOccupied;
  final Duration duration;
  final bool isInitialShow;
  final List<Positioned>? additionalWidgets;
  final Axis dividedDirection;

  @override
  State<StatefulWidget> createState() => _TapHideStackState();
}

class _TapHideStackState extends State<TapHideStack> {
  final double controlButtonPadding = 4;
  late double _offset; // Initial offset.

  void _showWidget() {
    setState(() {
      _offset = 0; // Reserve to initial.
    });
  }

  void _hideWidget() {
    setState(() {
      _offset = -widget.leftOccupied; // Hide offset.
    });
  }

  @override
  void initState() {
    _offset = widget.isInitialShow ? 0 : -widget.leftOccupied;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    if (widget.dividedDirection == Axis.horizontal) {
      current = Stack(
        children: [
          AnimatedPositioned(
              duration: widget.duration,
              top: 0,
              bottom: 0,
              left: _offset,
              width: widget.leftOccupied,
              child: widget.leftWidget),
          AnimatedPositioned(
              duration: widget.duration,
              top: 0,
              bottom: 0,
              left: _offset + widget.leftOccupied + controlButtonPadding,
              right: 0,
              child: widget.rightWidget),
          AnimatedPositioned(
            top: 0,
            left: _offset == 0
                ? widget.leftOccupied -
                    controlButtonPadding -
                    Theme.of(context).iconTheme.opticalSize!
                : controlButtonPadding,
            duration: widget.duration,
            child: IconButton(
              onPressed: () {
                _offset == 0 ? _hideWidget() : _showWidget();
              },
              icon: Icon(_offset == 0
                  ? Icons.keyboard_arrow_left
                  : Icons.keyboard_arrow_right),
              iconSize: Theme.of(context).iconTheme.opticalSize!,
              padding: EdgeInsets.all(0),
            ),
          ),
        ],
      );
    } else if (widget.dividedDirection == Axis.vertical) {
      current = Stack(
        children: [
          AnimatedPositioned(
            top: _offset == 0
                ? widget.leftOccupied - controlButtonPadding
                : controlButtonPadding,
            left: controlButtonPadding,
            duration: widget.duration,
            child: IconButton(
              onPressed: () {
                _offset == 0 ? _hideWidget() : _showWidget();
              },
              icon: Icon(_offset == 0
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              iconSize: Theme.of(context).iconTheme.opticalSize!,
            ),
          ),
          AnimatedPositioned(
              duration: widget.duration,
              top: _offset,
              left: 0,
              right: 0,
              height: widget.leftOccupied,
              child: widget.leftWidget),
          AnimatedPositioned(
              duration: widget.duration,
              top: _offset + widget.leftOccupied,
              bottom: 0,
              left: 0,
              right: 0,
              child: widget.rightWidget),
        ],
      );
    } else {
      return ErrorWidget('Invalid Direction');
    }
    if (widget.padding != null) {
      current = Padding(
        padding: widget.padding!,
        child: current,
      );
    }
    return current;
  }
}
