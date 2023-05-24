import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;

  List<String> messages = [];

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Socket.IO 클라이언트 생성
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('chat message', (message) {
      setState(() {
        messages.add(message);
      });
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void sendMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      // 서버로 메시지 전송
      socket.emit('chat message', message);
      messageController.clear();
    }
  }

  @override
  void dispose() {
    socket.disconnect(); // 앱 종료 시 소켓 연결 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
