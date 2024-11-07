import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyDraggable extends StatefulWidget {
  const MyDraggable({super.key});
  @override
  State<StatefulWidget> createState() => DragTestState();
}

class DragTestState<MyDraggable> extends State with TickerProviderStateMixin {
  late AnimationController testcontroller;
  late AnimationController testcontroller2;
  @override
  void initState() {
    super.initState();
    testcontroller = AnimationController(vsync: this);
    testcontroller2 = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: Colors.white,
            child: Center(
                child: Text(
              '放置1在这里',
              style: TextStyle(fontSize: 30),
            )),
          );
        },
        onWillAcceptWithDetails: (details) {
          testcontroller2.forward();
          if (details.data == 1) {
            return true;
          } else {
            return false;
          }
        },
        onLeave: (data) {
          testcontroller2.reverse();
        },
        onAcceptWithDetails: (details) {
          testcontroller2.reverse();
          print('get ${details.data}');
        },
      )
          .animate(controller: testcontroller2, autoPlay: false)
          .color(blendMode: BlendMode.darken),
      Draggable<int>(
        data: 1, // 拖拽数据
        feedback: Container(
          color: Colors.blue,
          child: Material(child: Text('拖我1')),
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.grey,
          child: Text('拖拽我1', style: TextStyle(color: Colors.white)),
        ),
        onDragStarted: () {
          testcontroller.forward();
        },
        // 拖拽结束时的回调
        onDragEnd: (details) {
          testcontroller.reverse();
          // details是DraggableDetails对象，包含拖拽的信息
        },
        // 拖拽时的回调
        onDraggableCanceled: (velocity, offset) {
          // 当拖拽被取消时的回调
          testcontroller.reverse();
        },
      )
          .animate(controller: testcontroller, autoPlay: false)
          .scaleXY(begin: 1, end: 1.2),
      Draggable<int>(
        data: 2, // 拖拽数据
        feedback: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.blue,
          child: Text('拖我2', style: TextStyle(color: Colors.white)),
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.grey,
          child: Text('拖拽我2', style: TextStyle(color: Colors.white)),
        ),
        // 拖拽结束时的回调
        onDragEnd: (details) {
          // details是DraggableDetails对象，包含拖拽的信息
        },
        // 拖拽时的回调
        onDraggableCanceled: (velocity, offset) {
          // 当拖拽被取消时的回调
        },
      ),
    ]);
  }
}
