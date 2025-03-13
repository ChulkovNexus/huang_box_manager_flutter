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
  final bool isOnline;

  const BoughtInference({
    required String id,
    required this.userId,
    required this.inferenceName,
    required this.inputTokenPrice,
    required this.outputTokenPrice,
    required this.createdAt,
    required this.loadPercentage,
    required this.owner,
    this.isOnline = false,
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
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  BoughtInference copyWith({
    String? id,
    String? userId,
    String? inferenceName,
    double? inputTokenPrice,
    double? outputTokenPrice,
    int? createdAt,
    double? loadPercentage,
    String? owner,
    bool? isOnline,
  }) {
    return BoughtInference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inferenceName: inferenceName ?? this.inferenceName,
      inputTokenPrice: inputTokenPrice ?? this.inputTokenPrice,
      outputTokenPrice: outputTokenPrice ?? this.outputTokenPrice,
      createdAt: createdAt ?? this.createdAt,
      loadPercentage: loadPercentage ?? this.loadPercentage,
      owner: owner ?? this.owner,
      isOnline: isOnline ?? this.isOnline,
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
    isOnline,
  ];
}
