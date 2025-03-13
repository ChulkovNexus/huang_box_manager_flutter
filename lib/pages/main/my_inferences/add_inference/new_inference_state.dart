import 'package:equatable/equatable.dart';

abstract class NewInferenceState extends Equatable {
  const NewInferenceState();
  @override
  List<Object?> get props => [];
}

class NewInferenceInitialState extends NewInferenceState {
  const NewInferenceInitialState();
}

class NewInferenceLoadingState extends NewInferenceState {
  const NewInferenceLoadingState();
}

class InferenceSeccessfulCreated extends NewInferenceState {
  final String token;
  const InferenceSeccessfulCreated({required this.token});

  @override
  List<Object?> get props => [token];
}

class NewInferenceLoadedState extends NewInferenceState {
  final List<String> availableInferences;
  final String? selectedInference;
  final String? inputPrice;
  final String? outputPrice;
  final bool isFormValid;

  const NewInferenceLoadedState({
    required this.availableInferences,
    this.selectedInference,
    this.inputPrice,
    this.outputPrice,
    this.isFormValid = false,
  });

  @override
  List<Object?> get props => [availableInferences, selectedInference, inputPrice, outputPrice, isFormValid];
}

class NewInferenceErrorState extends NewInferenceState {
  final String message;
  const NewInferenceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
