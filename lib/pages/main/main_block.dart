import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/di/di.dart';
import 'package:huang_box_manager_web/pages/main/main_state.dart';

class MainBloc extends Cubit<MainState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = getIt<RestService>();

  MainBloc() : super(const InitialMainState()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() {
    if (_auth.currentUser == null) {
      emit(const UnauthenticatedState());
    } else {
      // Если пользователь залогинен, можно сразу выбрать начальный пункт меню
      emit(const MenuItemSelectedState(0)); // Например, 0 - это Dashboard
    }
  }

  void selectMenuItem(int index) {
    if (_auth.currentUser != null) {
      emit(MenuItemSelectedState(index));
    } else {
      emit(const UnauthenticatedState());
    }
  }

  void signOut() {
    _auth.signOut();
    emit(
      const UnauthenticatedState(),
    ); // После выхода перенаправляем на авторизацию
  }
}
