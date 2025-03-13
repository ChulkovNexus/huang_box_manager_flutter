import 'package:equatable/equatable.dart';
import 'package:huang_box_manager_web/api/entities/bought_inference.dart';

abstract class BoughtInferencesState extends Equatable {
  const BoughtInferencesState();

  @override
  List<Object?> get props => [];
}

// Начальное состояние
class BoughtInferencesInitialState extends BoughtInferencesState {
  const BoughtInferencesInitialState();
}

// Состояние загрузки
class BoughtInferencesLoadingState extends BoughtInferencesState {
  const BoughtInferencesLoadingState();
}

// Состояние с данными
class BoughtInferencesLoadedState extends BoughtInferencesState {
  final List<BoughtInference> boughtInferences;
  final Map<String, bool> deletingInferenceIds;
  final bool isWebSocketConnected;

  const BoughtInferencesLoadedState(
    this.boughtInferences, {
    this.deletingInferenceIds = const {},
    this.isWebSocketConnected = false,
  });

  @override
  List<Object?> get props => [boughtInferences, deletingInferenceIds, isWebSocketConnected];

  BoughtInferencesLoadedState copyWith({
    List<BoughtInference>? boughtInferences,
    Map<String, bool>? deletingInferenceIds,
    bool? isWebSocketConnected,
  }) {
    return BoughtInferencesLoadedState(
      boughtInferences ?? this.boughtInferences,
      deletingInferenceIds: deletingInferenceIds ?? this.deletingInferenceIds,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
    );
  }
}

// Состояние ошибки
class BoughtInferencesErrorState extends BoughtInferencesState {
  final String error;

  const BoughtInferencesErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
