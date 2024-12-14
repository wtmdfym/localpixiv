import 'package:flutter/material.dart';
import 'package:localpixiv/models.dart';

class Tabbutton extends StatefulWidget implements PreferredSizeWidget {
  const Tabbutton({
    super.key,
    required this.onTap,
    required this.index,
    required this.indexNotifier,
    required this.text,
    this.style,
  });
  final ChangeIndexCallback onTap;
  final int index;
  final ValueNotifier<int> indexNotifier;
  final double width = 200;
  //final double height = 30;
  final String text;
  final TextStyle? style;

  @override
  State<StatefulWidget> createState() => TabbuttonState();

  @override
  Size get preferredSize => Size.fromWidth(width);
}

class TabbuttonState extends State<Tabbutton> {
  final WidgetStatesController _controller = WidgetStatesController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: InkWell(
            borderRadius: BorderRadius.circular(5),
            hoverColor: Colors.cyanAccent,
            splashColor: Colors.cyan,
            statesController: _controller,
            onTap: () => widget.onTap(widget.index),
            child: ValueListenableBuilder(
              valueListenable: widget.indexNotifier,
              builder: (context, index, child) => CustomPaint(
                willChange: true,
                painter: LinePainter(
                    length: (widget.style?.fontSize ?? 21.7) * 1.38,
                    startOffset: Offset(
                        (widget.style?.fontSize ?? 14.4) * 0.345,
                        (widget.style?.fontSize ?? 14.5) * 0.138),
                    needpaint: index == widget.index),
                child: Text(
                  '   ${widget.text} ',
                  textAlign: TextAlign.start,
                  style: widget.style ?? TextStyle(fontSize: 20),
                ),
              ),
            )));
  }
}

class LinePainter extends CustomPainter {
  const LinePainter({
    this.color = Colors.blue,
    this.strokeWidth = 4,
    required this.length,
    required this.startOffset,
    required this.needpaint,
  });
  final Color color;
  final double strokeWidth;
  final double length;
  final Offset startOffset;
  final bool needpaint;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color // 线条颜色
      ..strokeWidth = strokeWidth; // 线条宽度

    // 绘制线条
    if (needpaint) {
      canvas.drawLine(startOffset, startOffset.translate(0, length), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
