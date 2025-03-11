import 'package:equatable/equatable.dart';

class BoughtInference extends Equatable {
  final String id;
  final String userId;
  final String inferenceName;
  final double inputTokenPrice;
  final double outputTokenPrice;
  final int createdAt;
  final double? loadPercentage;
  final String owner;

  const BoughtInference({
    required String id,
    required this.userId,
    required this.inferenceName,
    required this.inputTokenPrice,
    required this.outputTokenPrice,
    required this.createdAt,
    required this.loadPercentage,
    required this.owner,
  }) : id = id;

  factory BoughtInference.fromJson(Map<String, dynamic> json) {
    return BoughtInference(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      owner: json['owner'] as String,
      inferenceName: json['inferenceName'] as String,
      inputTokenPrice: (json['inputTokenPrice'] as num).toDouble(),
      outputTokenPrice: (json['outputTokenPrice'] as num).toDouble(),
      createdAt: json['createdAt'] as int,
      loadPercentage: (json['loadPercentage'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    inferenceName,
    inputTokenPrice,
    outputTokenPrice,
    createdAt,
    loadPercentage,
    owner,
  ];
}
