import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:huang_box_manager_web/api/entities/bought_inference.dart';
import 'package:huang_box_manager_web/api/models/websocket_models.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/bought_inferences_state.dart';
import 'package:huang_box_manager_web/services/websocket_service.dart';

class BoughtInferencesBloc extends Cubit<BoughtInferencesState> {
  BoughtInferencesBloc() : super(const BoughtInferencesInitialState()) {
    _loadBoughtInferences(); // Загружаем данные при создании
    _setupWebSocketListeners(); // Настраиваем слушатели веб-сокетов
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = GetIt.I<RestService>();
  final WebSocketService _webSocketService = GetIt.I<WebSocketService>();

  // Мапа для отслеживания состояния удаления для каждого инференса
  final Map<String, bool> _deletingInferences = {};

  // Подписки на веб-сокеты
  StreamSubscription<OwnersStatusesMessage>? _ownersStatusesSubscription;

  // Настраиваем слушатели WebSocket
  void _setupWebSocketListeners() {
    // Подключаемся к веб-сокету
    _webSocketService.connect();

    // Подписываемся на обновления статусов инференсов
    _ownersStatusesSubscription = _webSocketService.ownersStatuses.listen((statusesMessage) {
      _updateInferencesStatuses(statusesMessage);
    });
  }

  // Обновляем статусы инференсов на основе сообщения от веб-сокета
  void _updateInferencesStatuses(OwnersStatusesMessage message) {
    if (state is BoughtInferencesLoadedState) {
      final currentState = state as BoughtInferencesLoadedState;
      final updatedInferences = List<BoughtInference>.from(currentState.boughtInferences);

      // Проходим по всем статусам в сообщении
      for (final status in message.ownersStatuses) {
        // Ищем соответствующий инференс в списке
        final inferenceIndex = updatedInferences.indexWhere((inference) => inference.id == status.boughtInferenceId);

        if (inferenceIndex != -1) {
          // Обновляем статус инференса
          updatedInferences[inferenceIndex] = updatedInferences[inferenceIndex].copyWith(isOnline: status.isOnline);
        }
      }

      // Обновляем состояние с новыми статусами
      emit(
        currentState.copyWith(boughtInferences: updatedInferences, isWebSocketConnected: _webSocketService.isConnected),
      );
    }
  }

  Future<void> _loadBoughtInferences() async {
    emit(const BoughtInferencesLoadingState());
    try {
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      final response = await _restService.getUserBoughtInferences(authHeader);

      if (response.isSuccessful) {
        final List<dynamic> data = response.body as List<dynamic>;
        final boughtInferences = data.map((json) => BoughtInference.fromJson(json)).toList();
        emit(
          BoughtInferencesLoadedState(
            boughtInferences,
            deletingInferenceIds: _deletingInferences,
            isWebSocketConnected: _webSocketService.isConnected,
          ),
        );
      } else {
        emit(BoughtInferencesErrorState('Failed to load bought inferences: ${response.error}'));
      }
    } catch (e) {
      emit(BoughtInferencesErrorState('Error: $e'));
    }
  }

  Future<void> deleteBoughtInference(String inferenceId) async {
    // Сохраняем текущее состояние, чтобы вернуться к нему в случае ошибки
    final currentState = state;

    try {
      // Устанавливаем флаг удаления для этого инференса
      _deletingInferences[inferenceId] = true;

      // Обновляем состояние, чтобы показать индикатор загрузки
      if (state is BoughtInferencesLoadedState) {
        final loadedState = state as BoughtInferencesLoadedState;
        emit(loadedState.copyWith(deletingInferenceIds: {..._deletingInferences}));
      }

      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';

      // Создаем запрос
      final request = {'inferenceId': inferenceId};

      // Отправляем запрос
      final response = await _restService.deleteBoughtInference(authHeader, request);

      // Удаляем флаг удаления для этого инференса
      _deletingInferences.remove(inferenceId);

      if (response.isSuccessful) {
        // Если удаление успешно, обновляем список инференсов
        if (state is BoughtInferencesLoadedState) {
          final loadedState = state as BoughtInferencesLoadedState;

          // Находим и удаляем инференс из списка
          final updatedInferences =
              loadedState.boughtInferences.where((inference) => inference.id != inferenceId).toList();

          emit(
            loadedState.copyWith(boughtInferences: updatedInferences, deletingInferenceIds: {..._deletingInferences}),
          );
        }
      } else {
        // В случае ошибки эмитим состояние ошибки
        final String errorMessage = response.error?.toString() ?? 'Неизвестная ошибка';
        emit(BoughtInferencesErrorState('Failed to delete inference: $errorMessage'));
      }
    } catch (e) {
      // Удаляем флаг удаления в случае ошибки
      _deletingInferences.remove(inferenceId);

      // Генерируем сообщение об ошибке
      emit(BoughtInferencesErrorState('Failed to delete inference: $e'));
    }
  }

  // Перезагрузка данных после ошибки удаления инференса
  Future<void> reloadDataAfterError() async {
    await _loadBoughtInferences();
  }

  @override
  Future<void> close() {
    // Отписываемся от веб-сокета при закрытии блока
    _ownersStatusesSubscription?.cancel();
    return super.close();
  }
}
