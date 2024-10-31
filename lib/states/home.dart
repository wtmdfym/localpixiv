import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.process,
  });

  final Process process;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double maxScroll = 1;
  int getType = 0;
  bool isstart = false;
  List<String> hittexts = [
    '( ･ω･)☞   (:3 」∠)',
    'Enter work Id',
    'Enter user Id',
    'Enter keywords'
  ];
  // 0->followings
  // 1->id
  // 2->uid
  // 3->tag
  ValueNotifier<String> outputs = ValueNotifier('');

  void _startProcessListen() async {
    Utf8Decoder utf8decoder = Utf8Decoder(allowMalformed: true);
    // 监听命令的标准输出
    widget.process.stdout.transform(utf8decoder).listen((data) {
      //outputs += 'OUTPUT: $data';
      outputs.value += data; //gbk.decode(data);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.medium1, curve: Curves.bounceOut);
      }
    });

    // 监听命令的标准错误
    widget.process.stderr.transform(utf8decoder).listen((data) {
      outputs.value += 'ERROR: $data [ERROR]';
      if (data.contains('httpx.ConnectError')) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('ConnectError:\nProxy inaccessible'),
                  titleTextStyle: TextStyle(color: Colors.redAccent,fontSize: 25),
                  content: Text('请检查代理设置是否正确',textAlign: TextAlign.center,),
                );
              });
        }
        setState(() {
          isstart = false;
        });
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.medium1, curve: Curves.bounceOut);
      }
    });
    // 监听命令的返回代码
    int exitCode = await widget.process.exitCode;
    outputs.value += 'Process exited with code: $exitCode\n';
    // 自动滚动至底部
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Durations.medium1, curve: Curves.bounceOut);
    }
  }

  void _sendCommand(String command) async {
    //TODO different getType
    widget.process.stdin.write('$command\n');
  }

  @override
  void initState() {
    super.initState();
    _startProcessListen();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(children: <Widget>[
        Row(
          spacing: 30,
          children: <Widget>[
            Expanded(
              child: TextField(
                enabled: getType != 0,
                controller: _controller,
                onSubmitted: (text) {
                  _sendCommand(text);
                  _controller.clear();
                },
                decoration: InputDecoration(
                  hintText: hittexts[getType],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isstart
                  ? () {}
                  : () {
                      if (_controller.text.isNotEmpty) {
                        _sendCommand(_controller.text);
                        _controller.clear();
                      } else {
                        // TODO python location
                        String location =
                            'c:/Users/Administrator/Desktop/pixiv-crawler';
                        _sendCommand(
                            '$location/.venv/Scripts/python.exe $location/cmdapp/cmd_app.py');
                      }
                      setState(() => isstart = true);
                    },
              child: Text('Start'),
            ),
            ElevatedButton(
              onPressed: isstart
                  ? () {
                      _sendCommand('STOP');
                      setState(() => isstart = false);
                    }
                  : () {},
              child: Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () => outputs.value = '',
              child: Text('Clear'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: CheckboxListTile(
                    title: Text('Followings'),
                    value: getType == 0 ? true : false,
                    onChanged: (value) =>
                        setState(() => value! ? getType = 0 : {}))),
            Expanded(
                child: CheckboxListTile(
                    title: Text('Id'),
                    value: getType == 1 ? true : false,
                    onChanged: (value) =>
                        setState(() => value! ? getType = 1 : {}))),
            Expanded(
                child: CheckboxListTile(
                    title: Text('userId'),
                    value: getType == 2 ? true : false,
                    onChanged: (value) =>
                        setState(() => value! ? getType = 2 : {}))),
            Expanded(
                child: CheckboxListTile(
                    title: Text('Tag'),
                    value: getType == 3 ? true : false,
                    onChanged: (value) =>
                        setState(() => value! ? getType = 3 : {}))),
          ],
        ),
        Expanded(
            child: ListView(
          controller: _scrollController,
          children: [
            ValueListenableBuilder(
                valueListenable: outputs,
                builder: (context, value, child) {
                  return SelectableText(value);
                })
          ],
        ))
      ]),
    );
  }
}

//c:/Users/Administrator/Desktop/pixiv-crawler/.venv/Scripts/python.exe C:/Users/Administrator/Desktop/pixiv-crawler/cmdapp/cmd_app.py
