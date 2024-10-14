/*import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
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
  var data;
  final TextEditingController _controller = TextEditingController();
  WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8765'),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wsManager.setOnMessageCallback((message) {
      return 'Received message: $message';
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
            const SizedBox(height: 24),
            
            /*
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData){
                  data = jsonDecode(snapshot.data);
                }
                print(data);
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            ),*/
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
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



typedef WebSocketMessageCallback = String Function(String message);

class WebSocketManager {
  late WebSocketChannel _channel;
  Stream<dynamic>? _stream;
  Timer? _reconnectTimer;
  final int _reconnectInterval = 5000; // 重连间隔时间，单位为毫秒
  final int _maxReconnectAttempts = 5; // 最大重连次数
  int _reconnectAttempts = 0; // 当前重连次数
  WebSocketMessageCallback? onMessage; // 接收消息的回调函数

  // 初始化WebSocket连接
  void initWebSocket(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _stream = _channel.stream.asBroadcastStream();

    _channel.stream.listen((message) {
      // 处理接收到的消息
      onMessage!.call(message);
    }, onError: (error) {
      // 处理连接错误
      print('WebSocket error: $error');
      _reconnect(url);
    }, onDone: () {
      // 处理连接关闭
      print('WebSocket connection closed');
      _reconnect(url);
    });
  }

  // 重连逻辑
  void _reconnect(String url) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      print('Attempting to reconnect... (Attempt $_reconnectAttempts)');

      _reconnectTimer = Timer(Duration(milliseconds: _reconnectInterval), () {
        // 尝试重新连接
        _channel.sink.close(status.goingAway); // 关闭当前连接
        initWebSocket(url); // 重新初始化连接
      });
    } else {
      print('Maximum reconnect attempts reached');
    }
  }

  // 发送消息
  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void setOnMessageCallback(WebSocketMessageCallback callback) {
    onMessage = callback;
  }


  // 关闭WebSocket连接
  void close() {
    _channel.sink.close(status.normalClosure);
    _reconnectTimer?.cancel();
  }
}
*/