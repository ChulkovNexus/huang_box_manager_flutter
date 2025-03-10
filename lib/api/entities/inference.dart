import 'package:equatable/equatable.dart';

class Inference extends Equatable {
  final String id;
  final String userId;
  final String inferenceName;
  final double inputTokenPrice;
  final double outputTokenPrice;
  final int createdAt;

  const Inference({
    required this.id,
    required this.userId,
    required this.inferenceName,
    required this.inputTokenPrice,
    required this.outputTokenPrice,
    required this.createdAt,
  });

  factory Inference.fromJson(Map<String, dynamic> json) {
    return Inference(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      inferenceName: json['inferenceName'] as String,
      inputTokenPrice: (json['inputTokenPrice'] as num).toDouble(),
      outputTokenPrice: (json['outputTokenPrice'] as num).toDouble(),
      createdAt: json['createdAt'] as int,
    );
  }

  @override
  List<Object?> get props => [id, userId, inferenceName, inputTokenPrice, outputTokenPrice, createdAt];
}
