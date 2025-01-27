import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../localization/localization.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // localized text
  late String Function(String) _localizationMap;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Process process;
  late final StreamSubscription<String> s1;
  late final StreamSubscription<String> s2;
  int getType = 0;
  bool isstart = false;
  //bool needprint = true;
  final ValueNotifier<String> outputs = ValueNotifier('');
  final String addata = '';
  // 限制最大显示文本量
  final int maxLength = 16000;

  void _startProcessListen() async {
    Utf8Decoder utf8decoder = Utf8Decoder(allowMalformed: true);
    // 异步执行外部命令
    process = await Process.start('cmd', ['/k', 'chcp 65001']);
    // 监听命令的标准输出
    s1 = process.stdout.transform(utf8decoder).listen((data) {
      /*if (data.trim() == 'SENDSTART') {
        //print('start');
        needprint = false;
        return;
      } else if (data.trim() == 'SENDEND') {
        //print('end');
        needprint = true;
        Provider.of<DataModel>(context, listen: false).increment({'viewer':addata});
        addata = '';
        return;
      }
      if (needprint) {
        //outputs += 'OUTPUT: $data';
        outputs.value += data; //gbk.decode(data);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Durations.medium1,
              curve: Curves.linear);
        }
      } else {
        addata += data;
      }
    });*/

      updateOutputs(data);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.medium1, curve: Curves.linear);
      }
    });
    // 监听命令的标准错误
    s2 = process.stderr.transform(utf8decoder).listen((data) {
      updateOutputs('ERROR: $data [ERROR]');
      if (data.contains('httpx.ConnectError')) {
        context.mounted
            ? showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      _localizationMap('connect_error'),
                    ),
                    titleTextStyle: TextStyle(color: Colors.redAccent),
                    content: Text(
                      _localizationMap('proxy_error'),
                      textAlign: TextAlign.center,
                    ),
                  );
                })
            : {};
        setState(() {
          isstart = false;
        });
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.medium1, curve: Curves.linear);
      }
    });
    // 监听命令的返回代码
    int exitCode = await process.exitCode;
    updateOutputs('Process exited with code: $exitCode\n');
    // 自动滚动至底部
    if (_scrollController.hasClients) {
      //_scrollController.animateTo(_scrollController.position.maxScrollExtent,
      //    duration: Durations.medium1, curve: Curves.linear);
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendCommand(String command) {
    //TODO different getType
    process.stdin.write('$command\n');
    process.stdin.flush();
  }

  void updateOutputs(String newoutputs, [bool clear = false]) {
    if (clear) {
      updateOutputs('', true);
    } else {
      if ((outputs.value.length + newoutputs.length) > maxLength) {
        outputs.value = outputs.value.substring(newoutputs.length) + newoutputs;
      } else {
        outputs.value += newoutputs;
      }
    }
  }

  @override
  void initState() {
    _startProcessListen();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _localizationMap = MyLocalizations.of(context).homePage;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    process.kill();
    s1.cancel();
    s2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> hittexts = [
      _localizationMap('ef'),
      _localizationMap('er'),
      _localizationMap('ew'),
      _localizationMap('eu'),
      _localizationMap('ek'),
    ];
    // 0->followings
    // 1->rank
    // 2->id
    // 3->uid
    // 4->tag
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: <Widget>[
        Row(
          spacing: 30,
          children: <Widget>[
            Expanded(
              child: TextField(
                enabled: (getType != 0) && (getType != 1),
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
                        /*// TODO python location
                        String location =
                            'c:/Users/Administrator/Desktop/pixiv-crawler';
                        _sendCommand(
                            '$location/.venv/Scripts/python.exe -u lib/pythonapp/cmd_app.py  --configfile jsons/config.json'
                            //'cd asset/lib/pythonapp/build/exe.win-amd64-3.12/'
                            //'"lib/pythonapp/build/exe.win-amd64-3.12/cmd_app.exe" --configfile jsons/config.json'
                            );*/
                        _sendCommand(
                            'cmd_app.exe --configfile jsons/webCrawler_config.json');
                      }
                      setState(() => isstart = true);
                    },
              child: Text(_localizationMap('start')),
            ),
            ElevatedButton(
              onPressed: isstart
                  ? () {
                      _sendCommand('STOP');
                      setState(() => isstart = false);
                    }
                  : () {},
              child: Text(_localizationMap('stop')),
            ),
            ElevatedButton(
              onPressed: () => outputs.value = '',
              child: Text(_localizationMap('clear')),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: RadioListTile<int>(
              title: Text(_localizationMap('cf')),
              value: 0,
              groupValue: getType,
              onChanged: (value) => setState(() => getType = value!),
            )),
            Expanded(
                child: RadioListTile<int>(
              title: Text(_localizationMap('cr')),
              value: 1,
              groupValue: getType,
              onChanged: (value) => setState(() => getType = value!),
            )),
            Expanded(
                child: RadioListTile<int>(
              title: Text(_localizationMap('ci')),
              value: 2,
              groupValue: getType,
              onChanged: (value) => setState(() => getType = value!),
            )),
            Expanded(
                child: RadioListTile<int>(
              title: Text(_localizationMap('cu')),
              value: 3,
              groupValue: getType,
              onChanged: (value) => setState(() => getType = value!),
            )),
            Expanded(
                child: RadioListTile<int>(
              title: Text(_localizationMap('ct')),
              value: 4,
              groupValue: getType,
              onChanged: (value) => setState(() => getType = value!),
            )),
          ],
        ),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.only(right: 12),
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
