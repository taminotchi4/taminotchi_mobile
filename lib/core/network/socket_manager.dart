import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketManager {
  static const String _baseUrl = 'http://89.223.126.116:3003';
  static final Map<String, io.Socket> _sockets = {};

  static io.Socket connect(String namespace, String token) {
    if (_sockets.containsKey(namespace) && _sockets[namespace]!.connected) {
      return _sockets[namespace]!;
    }

    final socket = io.io(
      '$_baseUrl$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setAuth({'token': token})
          .build(),
    );

    socket.onConnect((_) => debugPrint('✅ Socket $namespace ulandi'));
    socket.onDisconnect((reason) => debugPrint('❌ Socket $namespace uzildi: $reason'));
    socket.onConnectError((err) => debugPrint('⚠️ Socket $namespace ulanishda xato: $err'));
    socket.on('error', (data) => debugPrint('🛑 Socket $namespace xato: $data'));

    _sockets[namespace] = socket;
    return socket;
  }

  static void disconnect(String namespace) {
    _sockets[namespace]?.disconnect();
    _sockets.remove(namespace);
  }

  static void disconnectAll() {
    for (final socket in _sockets.values) {
      socket.disconnect();
    }
    _sockets.clear();
  }

  static io.Socket? getSocket(String namespace) => _sockets[namespace];
}
