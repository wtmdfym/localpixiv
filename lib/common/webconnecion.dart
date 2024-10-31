/*import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final wsManager = WebSocketManager();
  /*
  websManager.initWebSocket('ws://localhost:8765');

  // 设置接收消息的回调函数
  wsManager.setOnMessageCallback((message) {
    return 'Received message: $message';
  });

  // 发送消息示例
  wsManager.sendMessage('{"doingtype":"database","content":{"method":"find"}}');*/

  // 记得在适当的时候关闭WebSocket连接
  // wsManager.close();
  String res = '';
  var data;
  final TextEditingController _controller = TextEditingController();
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8765'),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wsManager.setOnMessageCallback((message) {
      res += message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            SizedBox(
              height: 24,
              child: StreamBuilder(
                stream: _channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    data = jsonDecode(snapshot.data);
                  }
                  if (data != null) {
                    res += data;
                    return Text(data);
                  } else {
                    return Text('null');
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendMessage;
          print(res);
        },
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  //{"doingtype":"database","content":{"method":"find"}}

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      wsManager.sendMessage(_controller.text);
      //_channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}

class WebSocketManager {
  WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));
  Function? onMessage; // 接收消息的回调函数

  // 初始化WebSocket连接
  void initWebSocket(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((message) {
      // 处理接收到的消息
      onMessage!.call(message);
    });
  }

  // 发送消息
  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void setOnMessageCallback(callback) {
    onMessage = callback;
  }

  // 关闭WebSocket连接
  void close() {
    _channel.sink.close(status.normalClosure);
  }
}
*/