import 'package:equatable/equatable.dart';

class Inference extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String inferenceName;
  final double inputTokenPrice;
  final double outputTokenPrice;
  final int createdAt;
  final double? loadPercentage;
  final String token;

  const Inference({
    required this.id,
    required this.userId,
    required this.userName,
    required this.inferenceName,
    required this.inputTokenPrice,
    required this.outputTokenPrice,
    required this.createdAt,
    required this.token,
    this.loadPercentage,
  });

  factory Inference.fromJson(Map<String, dynamic> json) {
    return Inference(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      inferenceName: json['inferenceName'] as String,
      inputTokenPrice: (json['inputTokenPrice'] as num).toDouble(),
      outputTokenPrice: (json['outputTokenPrice'] as num).toDouble(),
      loadPercentage: (json['loadPercentage'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as int,
      token: json['token'] as String,
    );
  }

  @override
  List<Object?> get props => [id, userId, userName, inferenceName, inputTokenPrice, outputTokenPrice, createdAt];
}
