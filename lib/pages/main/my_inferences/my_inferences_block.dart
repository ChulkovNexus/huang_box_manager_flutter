// Placeholder BLoC and State
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:huang_box_manager_web/api/entities/inference.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_state.dart';

class MyInferencesBloc extends Cubit<MyInferencesState> {
  MyInferencesBloc() : super(const MyInferencesInitialState()) {
    _loadInferences(); // Загружаем данные при создании
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = GetIt.I<RestService>();

  // Мапа для отслеживания состояния удаления для каждого инференса
  final Map<String, bool> _deletingInferences = {};

  Future<void> _loadInferences() async {
    emit(const MyInferencesLoadingState());
    try {
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      final response = await _restService.getUserInferences(authHeader);

      if (response.isSuccessful) {
        final List<dynamic> data = response.body as List<dynamic>;
        final inferences = data.map((json) => Inference.fromJson(json)).toList();
        emit(MyInferencesLoadedState(inferences, deletingInferenceIds: _deletingInferences));
      } else {
        emit(MyInferencesErrorState('Failed to load inferences: ${response.error}'));
      }
    } catch (e) {
      emit(MyInferencesErrorState('Error: $e'));
    }
  }

  Future<void> deleteInference(String inferenceId) async {
    // Сохраняем текущее состояние, чтобы вернуться к нему в случае ошибки
    final currentState = state;

    try {
      // Устанавливаем флаг удаления для этого инференса
      _deletingInferences[inferenceId] = true;

      // Обновляем состояние, чтобы показать индикатор загрузки
      if (state is MyInferencesLoadedState) {
        final loadedState = state as MyInferencesLoadedState;
        emit(loadedState.copyWith(deletingInferenceIds: {..._deletingInferences}));
      }

      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';

      // Создаем запрос
      final request = {'inferenceId': inferenceId};

      // Отправляем запрос
      final response = await _restService.deleteInference(authHeader, request);

      // Удаляем флаг удаления для этого инференса
      _deletingInferences.remove(inferenceId);

      if (response.isSuccessful) {
        // Если удаление успешно, обновляем список инференсов
        if (state is MyInferencesLoadedState) {
          final loadedState = state as MyInferencesLoadedState;

          // Находим и удаляем инференс из списка
          final updatedInferences = loadedState.inferences.where((inference) => inference.id != inferenceId).toList();

          emit(loadedState.copyWith(inferences: updatedInferences, deletingInferenceIds: {..._deletingInferences}));
        }
      } else {
        // В случае ошибки эмитим состояние ошибки
        final String errorMessage = response.error?.toString() ?? 'Неизвестная ошибка';
        emit(MyInferencesErrorState('Failed to delete inference: $errorMessage'));
      }
    } catch (e) {
      // Удаляем флаг удаления в случае ошибки
      _deletingInferences.remove(inferenceId);

      // Генерируем сообщение об ошибке
      emit(MyInferencesErrorState('Failed to delete inference: $e'));
    }
  }

  // Перезагрузка данных после ошибки удаления инференса
  Future<void> reloadDataAfterError() async {
    await _loadInferences();
  }
}
