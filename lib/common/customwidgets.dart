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
  late TabController tabController;

  List<Widget> stacks = [
    Container(
      color: Colors.amberAccent,
      width: 200,
      height: 200,
    ),
    Container(
      color: Colors.blueAccent,
      width: 200,
      height: 200,
    ),
    Container(
      color: Colors.greenAccent,
      width: 200,
      height: 200,
    ),
    Container(
      color: Colors.redAccent,
      width: 200,
      height: 200,
    ),
  ];
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    testcontroller = AnimationController(vsync: this);
    testcontroller2 = AnimationController(vsync: this);
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return TabBar(
              controller: tabController,
              onTap: (value) {
                currentIndex.value = value + 4;
              },
              tabs: [
                Text('1'),
                Text('2'),
                Text('3'),
                Text('4'),
              ]);
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
      /*ValueListenableBuilder(
          valueListenable: additionIndex,
          builder: (context, value, child) => 
      Expanded(
        child: DynamicTabBarWidget(
          isScrollable: true,
          dynamicTabs: tabs,
          onAddTabMoveTo: MoveToTab.last,
          onTabChanged: (p0) {},
          onTabControllerUpdated: (p0) {},
        ),
      ), //),*/

      Expanded(
          child: TabBarView(
              controller: tabController,
              children:
                  stacks /* [
        ColoredBox(color: Colors.amberAccent),
        ColoredBox(color: Colors.blueAccent),
        ColoredBox(color: Colors.greenAccent),
        ColoredBox(color: Colors.redAccent)
      ]*/
              )),
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
