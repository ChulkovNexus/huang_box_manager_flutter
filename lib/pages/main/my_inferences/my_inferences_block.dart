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

  Future<void> _loadInferences() async {
    emit(const MyInferencesLoadingState());
    try {
      final authHeader = 'Bearer ${await _auth.currentUser!.getIdToken()}';
      final response = await _restService.getUserInferences(authHeader);

      if (response.isSuccessful) {
        final List<dynamic> data = response.body as List<dynamic>;
        final inferences = data.map((json) => Inference.fromJson(json)).toList();
        emit(MyInferencesLoadedState(inferences));
      } else {
        emit(MyInferencesErrorState('Failed to load inferences: ${response.error}'));
      }
    } catch (e) {
      emit(MyInferencesErrorState('Error: $e'));
    }
  }
}
