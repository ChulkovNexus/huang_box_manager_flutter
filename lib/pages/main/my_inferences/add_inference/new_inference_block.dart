// Placeholder BLoC and State
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/add_inference/new_inference_state.dart';

class NewInferencesBloc extends Cubit<NewInferenceState> {
  NewInferencesBloc() : super(const NewInferenceInitialState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = GetIt.I<RestService>();

  void loadInferences() async {
    emit(const NewInferenceLoadingState());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const NewInferenceErrorState('User not authenticated'));
        return;
      }

      final token = await user.getIdToken();
      final response = await _restService.getAvailableInferences('Bearer $token');
      if (response.isSuccessful) {
        final List<String> inferences = (response.body as List).map((e) => e.toString()).toList();
        emit(NewInferenceLoadedState(availableInferences: inferences));
      } else {
        emit(const NewInferenceErrorState('Failed to load inferences'));
      }
    } catch (e) {
      emit(NewInferenceErrorState('Error: $e'));
    }
  }

  void updateForm({String? inference, String? inputPrice, String? outputPrice}) {
    if (state is NewInferenceLoadedState) {
      final currentState = state as NewInferenceLoadedState;
      final newInference = inference ?? currentState.selectedInference;
      final newInputPrice = inputPrice ?? currentState.inputPrice;
      final newOutputPrice = outputPrice ?? currentState.outputPrice;

      // Проверяем, заполнены ли все поля
      final isFormValid =
          newInference != null &&
          newInference.isNotEmpty &&
          newInputPrice != null &&
          newInputPrice.isNotEmpty &&
          newOutputPrice != null &&
          newOutputPrice.isNotEmpty;

      emit(
        NewInferenceLoadedState(
          availableInferences: currentState.availableInferences,
          selectedInference: newInference,
          inputPrice: newInputPrice,
          outputPrice: newOutputPrice,
          isFormValid: isFormValid,
        ),
      );
    }
  }

  void createInference() async {
    if (state is NewInferenceLoadedState) {
      final currentState = state as NewInferenceLoadedState;
      final user = _auth.currentUser;

      if (user == null) {
        emit(const NewInferenceErrorState('User not authenticated'));
        return;
      }

      emit(const NewInferenceLoadingState());

      try {
        final token = await user.getIdToken();
        final response = await _restService.createInference('Bearer $token', {
          'inference': currentState.selectedInference,
          'inputPrice': currentState.inputPrice,
          'outputPrice': currentState.outputPrice,
        });

        if (response.isSuccessful) {
          final token = response.body['token'] as String;
          emit(InferenceSeccessfulCreated(token: token));
        } else {
          emit(NewInferenceErrorState('Failed to create inference: ${response.statusCode}'));
        }
      } catch (e) {
        emit(NewInferenceErrorState('Error creating inference: ${e.toString()}'));
      }
    }
  }
}
