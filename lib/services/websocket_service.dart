import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:huang_box_manager_web/api/models/websocket_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Класс для работы с веб-сокетами
class WebSocketService {
  static const String _wsBaseUrl = 'ws://'; // Базовый URL для сокетов (дополняется в runtime)
  static const String _wsPath = '/auth-proxy';

  WebSocketChannel? _channel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Контроллеры для трансляции сообщений по типам
  final StreamController<WebSocketMessage> _messageController = StreamController<WebSocketMessage>.broadcast();
  final StreamController<OwnersStatusesMessage> _ownersStatusesController =
      StreamController<OwnersStatusesMessage>.broadcast();

  bool _isConnected = false;
  late String _baseUrl;
  Timer? _reconnectTimer;
  // Timer? _pingTimer;

  /// Установить базовый URL для веб-сокета
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl.replaceAll('http://', '').replaceAll('https://', '');
    if (_isConnected) {
      disconnect();
      connect();
    }
  }

  /// Получить стрим для всех сообщений
  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Получить стрим для сообщений о статусах владельцев
  Stream<OwnersStatusesMessage> get ownersStatuses => _ownersStatusesController.stream;

  /// Есть ли соединение
  bool get isConnected => _isConnected;

  /// Подключиться к веб-сокету
  Future<void> connect() async {
    if (_isConnected || _channel != null) {
      return;
    }

    try {
      final token = await _auth.currentUser?.getIdToken();
      if (token == null) {
        debugPrint('WebSocketService: Не удалось получить токен для веб-сокета');
        return;
      }

      final uri = Uri.parse('$_wsBaseUrl$_baseUrl$_wsPath?token=$token');
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      // Настройка периодического пинга для поддержания соединения
      // _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      //   _sendPing();
      // });

      // Слушаем входящие сообщения
      _channel!.stream.listen(
        (dynamic message) {
          _handleMessage(message);
        },
        onDone: _handleDisconnection,
        onError: (error) {
          debugPrint('WebSocketService: Ошибка соединения: $error');
          _handleDisconnection();
        },
      );

      debugPrint('WebSocketService: Успешное подключение к веб-сокету');
    } catch (e) {
      debugPrint('WebSocketService: Ошибка при подключении к веб-сокету: $e');
      _handleDisconnection();
    }
  }

  /// Отключиться от веб-сокета
  void disconnect() {
    // _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    debugPrint('WebSocketService: Отключено от веб-сокета');
  }

  // /// Периодический пинг для поддержания соединения
  // void _sendPing() {
  //   if (_isConnected && _channel != null) {
  //     try {
  //       _channel!.sink.add(jsonEncode({'type': 'ping'}));
  //     } catch (e) {
  //       debugPrint('WebSocketService: Ошибка при отправке пинга: $e');
  //     }
  //   }
  // }

  /// Обработка отключения
  void _handleDisconnection() {
    _isConnected = false;
    // _pingTimer?.cancel();
    _channel = null;

    // Пытаемся переподключиться через 5 секунд
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });

    debugPrint('WebSocketService: Соединение разорвано, попытка переподключения через 5 секунд');
  }

  /// Обработка входящего сообщения
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(message as String);
      final WebSocketMessage wsMessage = WebSocketMessage.fromJson(jsonData);

      // Публикуем общее сообщение
      _messageController.add(wsMessage);

      // Обрабатываем сообщение в зависимости от типа
      switch (wsMessage.type) {
        case 'owner_status_update':
        case 'owners_statuses':
          final contentMap = wsMessage.content as Map<String, dynamic>;
          final ownersStatusesMsg = OwnersStatusesMessage.fromJson(contentMap);
          _ownersStatusesController.add(ownersStatusesMsg);
          break;
        default:
          // Неизвестный тип сообщения, пока игнорируем
          break;
      }
    } catch (e) {
      debugPrint('WebSocketService: Ошибка при обработке сообщения: $e');
    }
  }

  /// Освобождаем ресурсы
  void dispose() {
    disconnect();
    _messageController.close();
    _ownersStatusesController.close();
  }
}
