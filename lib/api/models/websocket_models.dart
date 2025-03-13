import 'dart:convert';

/// Базовая модель сообщения веб-сокета
class WebSocketMessage {
  final String type;
  final String inferenceId;
  final dynamic content;

  WebSocketMessage({required this.type, this.inferenceId = '', required this.content});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      inferenceId: json['inferenceId'] as String? ?? '',
      content: json['content'],
    );
  }
}

/// Модель для статуса инференса от владельца
class OwnerStatusItem {
  final String inferenceId;
  final String boughtInferenceId;
  final String inferenceName;
  final bool isOnline;

  OwnerStatusItem({
    required this.inferenceId,
    required this.boughtInferenceId,
    required this.inferenceName,
    required this.isOnline,
  });

  factory OwnerStatusItem.fromJson(Map<String, dynamic> json) {
    return OwnerStatusItem(
      inferenceId: json['inferenceId'] as String,
      boughtInferenceId: json['boughtInferenceId'] as String,
      inferenceName: json['inferenceName'] as String,
      isOnline: json['isOnline'] as bool,
    );
  }
}

/// Модель для сообщения со статусами всех инференсов
class OwnersStatusesMessage {
  final List<OwnerStatusItem> ownersStatuses;

  OwnersStatusesMessage({required this.ownersStatuses});

  factory OwnersStatusesMessage.fromJson(Map<String, dynamic> json) {
    final contentMap = json['ownersStatuses'] as List;
    final statuses = contentMap.map((item) => OwnerStatusItem.fromJson(item as Map<String, dynamic>)).toList();

    return OwnersStatusesMessage(ownersStatuses: statuses);
  }
}
