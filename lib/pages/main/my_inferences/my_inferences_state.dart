import 'package:equatable/equatable.dart';
import 'package:huang_box_manager_web/api/entities/inference.dart';

abstract class MyInferencesState extends Equatable {
  const MyInferencesState();

  @override
  List<Object?> get props => [];
}

// Начальное состояние
class MyInferencesInitialState extends MyInferencesState {
  const MyInferencesInitialState();
}

// Состояние загрузки
class MyInferencesLoadingState extends MyInferencesState {
  const MyInferencesLoadingState();
}

// Состояние с данными
class MyInferencesLoadedState extends MyInferencesState {
  final List<Inference> inferences;
  final Map<String, bool> deletingInferenceIds;

  const MyInferencesLoadedState(this.inferences, {this.deletingInferenceIds = const {}});

  @override
  List<Object?> get props => [inferences, deletingInferenceIds];

  MyInferencesLoadedState copyWith({List<Inference>? inferences, Map<String, bool>? deletingInferenceIds}) {
    return MyInferencesLoadedState(
      inferences ?? this.inferences,
      deletingInferenceIds: deletingInferenceIds ?? this.deletingInferenceIds,
    );
  }
}

// Состояние ошибки
class MyInferencesErrorState extends MyInferencesState {
  final String error;

  const MyInferencesErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
