import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic>);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  OnMessageCallback? onMessage;

  Future<void> connect() async {
    if (_isConnected) return;
    try {
      print("🌐 Connecting to WebSocket...");
      _channel = IOWebSocketChannel.connect('wss://foxlchits.com/ws');
      _isConnected = true;
      print("✅ WebSocket Connected");

      _channel!.stream.listen(
            (message) {
          final data = jsonDecode(message);
          print("📩 WS Message: $data");
          onMessage?.call(data);
        },
        onDone: () {
          print("🔌 WS Closed");
          _isConnected = false;
        },
        onError: (error) {
          print("⚠️ WS Error: $error");
          _isConnected = false;
        },
      );
    } catch (e) {
      print("❌ WS Connection Failed: $e");
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      final msg = jsonEncode(data);
      print("📤 Sending: $msg");
      _channel!.sink.add(msg);
    } else {
      print("⚠️ Cannot send — WS not connected");
    }
  }

  void close() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
