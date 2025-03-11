import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:huang_box_manager_web/api/entities/bought_inference.dart';
import 'package:huang_box_manager_web/api/entities/inference.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/add_bought_inferences/add_bought_inferences_state.dart';
import 'package:huang_box_manager_web/api/entities/add_boutht_inference.dart';

class AddBoughtInferencesBloc extends Cubit<AddBoughtInferencesState> {
  AddBoughtInferencesBloc() : super(const AddBoughtInferencesInitialState()) {
    _loadInitialData();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = GetIt.I<RestService>();

  String? _selectedInferenceName;
  SortField? _sortField;
  SortDirection? _sortDirection;
  int _currentPage = 0;
  static const int _pageSize = 10;

  // Мапа для отслеживания состояния покупки для каждого инференса
  final Map<String, bool> _buyingInferences = {};

  Future<void> _loadInitialData() async {
    emit(const AddBoughtInferencesLoadingState());
    try {
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';

      // Загружаем доступные имена инференсов
      final availableResponse = await _restService.getAvailableInferences(authHeader);
      if (!availableResponse.isSuccessful) {
        emit(AddBoughtInferencesErrorState('Failed to load available inferences: ${availableResponse.error}'));
        return;
      }

      final List<String> availableInferenceNames = (availableResponse.body as List).map((e) => e.toString()).toList();
      _selectedInferenceName = availableInferenceNames[0];
      // Загружаем инференсы для покупки
      await _loadInferencesForBuy(authHeader, availableInferenceNames);
    } catch (e) {
      emit(AddBoughtInferencesErrorState('Error: $e'));
    }
  }

  Future<void> _loadInferencesForBuy(String authHeader, List<String> availableInferenceNames) async {
    try {
      final request = GetInferencesForBuyRequest(
        inferenceName: _selectedInferenceName,
        page: _currentPage,
        pageSize: _pageSize,
        sortField: _sortField,
        sortDirection: _sortDirection,
      );

      final response = await _restService.getInferencesForBuy(authHeader, request.toJson());

      if (response.isSuccessful) {
        final List<dynamic> inferences = response.body as List<dynamic>;
        final hasMorePages = inferences.length >= _pageSize;

        // Преобразуем значения перечислений в строки, совпадающие с теми, которые используются для сравнения в виджете
        String? sortFieldString;
        if (_sortField == SortField.input_price) {
          sortFieldString = 'inputPrice';
        } else if (_sortField == SortField.output_price) {
          sortFieldString = 'outputPrice';
        }

        String? sortDirectionString;
        if (_sortDirection == SortDirection.asc) {
          sortDirectionString = 'asc';
        } else if (_sortDirection == SortDirection.desc) {
          sortDirectionString = 'desc';
        }

        emit(
          AddBoughtInferencesLoadedState(
            inferences: inferences.map((json) => Inference.fromJson(json)).toList(),
            availableInferenceNames: availableInferenceNames,
            currentPage: _currentPage,
            hasMorePages: hasMorePages,
            selectedInferenceName: _selectedInferenceName,
            sortField: sortFieldString,
            sortDirection: sortDirectionString,
          ),
        );
      } else {
        emit(AddBoughtInferencesErrorState('Failed to load inferences: ${response.error}'));
      }
    } catch (e) {
      emit(AddBoughtInferencesErrorState('Error: $e'));
    }
  }

  Future<void> setInferenceName(String? inferenceName) async {
    _selectedInferenceName = inferenceName;
    _currentPage = 0;
    if (state is AddBoughtInferencesLoadedState) {
      final currentState = state as AddBoughtInferencesLoadedState;
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      await _loadInferencesForBuy(authHeader, currentState.availableInferenceNames);
    }
  }

  Future<void> setSort(SortField field, SortDirection direction) async {
    _sortField = field;
    _sortDirection = direction;
    if (state is AddBoughtInferencesLoadedState) {
      final currentState = state as AddBoughtInferencesLoadedState;
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      await _loadInferencesForBuy(authHeader, currentState.availableInferenceNames);
    }
  }

  Future<void> setPage(int page) async {
    _currentPage = page;
    if (state is AddBoughtInferencesLoadedState) {
      final currentState = state as AddBoughtInferencesLoadedState;
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      await _loadInferencesForBuy(authHeader, currentState.availableInferenceNames);
    }
  }

  Future<void> buyInference(String inferenceId) async {
    // Сохраняем текущее состояние, чтобы вернуться к нему в случае ошибки
    final currentState = state;

    try {
      // Устанавливаем флаг покупки для этого инференса
      _buyingInferences[inferenceId] = true;

      // Обновляем состояние, чтобы показать индикатор загрузки
      if (state is AddBoughtInferencesLoadedState) {
        final loadedState = state as AddBoughtInferencesLoadedState;
        emit(loadedState.copyWith(buyingInferenceIds: {..._buyingInferences}));
      }

      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';

      // Создаем запрос
      final request = BuyInferenceRequest(inferenceId: inferenceId);

      // Отправляем запрос
      final response = await _restService.buyInference(authHeader, request.toJson());

      // Удаляем флаг покупки для этого инференса
      _buyingInferences.remove(inferenceId);

      if (response.isSuccessful) {
        // Если покупка успешна, обновляем список инференсов
        if (state is AddBoughtInferencesLoadedState) {
          final loadedState = state as AddBoughtInferencesLoadedState;

          // Находим и удаляем купленный инференс из списка
          final updatedInferences = loadedState.inferences.where((inference) => inference.id != inferenceId).toList();

          emit(loadedState.copyWith(inferences: updatedInferences, buyingInferenceIds: {..._buyingInferences}));
        }
      } else {
        // В случае ошибки эмитим состояние ошибки с текстом ответа от сервера
        final String errorMessage = response.error?.toString() ?? 'Неизвестная ошибка';
        emit(AddBoughtInferencesErrorState('Failed to buy inference: $errorMessage'));
      }
    } catch (e) {
      // Удаляем флаг покупки в случае ошибки
      _buyingInferences.remove(inferenceId);

      // Генерируем сообщение об ошибке
      emit(AddBoughtInferencesErrorState('Failed to buy inference: $e'));
    }
  }

  /// Перезагрузка данных после ошибки покупки инференса
  Future<void> reloadDataAfterError() async {
    await _loadInitialData();
  }
}
