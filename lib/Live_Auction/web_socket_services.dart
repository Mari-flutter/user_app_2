// lib/web_socket_services.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(Map<String, dynamic> data);

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  final _connectedController = StreamController<bool>.broadcast();
  Stream<bool> get connectedStream => _connectedController.stream;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  WebSocketService({required this.url});

  void connect() {
    disconnect(); // make sure previous closed
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _connectedController.add(true);
      _sub = _channel!.stream.listen((raw) {
        try {
          if (raw is String) {
            final parsed = jsonDecode(raw);
            if (parsed is Map<String, dynamic>) {
              _messageController.add(parsed);
            } else {
              // ignore non-object messages
            }
          }
        } catch (e) {
          // invalid json
        }
      }, onDone: () {
        _connectedController.add(false);
        _messageController.add({"type": "WS_CLOSED"});
      }, onError: (err) {
        _connectedController.add(false);
        _messageController.add({"type": "WS_ERROR", "error": err.toString()});
      });
    } catch (e) {
      _connectedController.add(false);
      _messageController.add({"type": "WS_ERROR", "error": e.toString()});
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel == null) return;
    try {
      final jsonStr = jsonEncode(data);
      _channel!.sink.add(jsonStr);
    } catch (e) {
      // ignore
    }
  }

  void disconnect() {
    try {
      _sub?.cancel();
      _sub = null;
      _channel?.sink.close();
      _channel = null;
      _connectedController.add(false);
    } catch (e) {}
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectedController.close();
  }
}
