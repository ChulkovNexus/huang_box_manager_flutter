import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:huang_box_manager_web/api/rest_service.dart';
import 'package:huang_box_manager_web/di/di.dart';
import 'auth_state.dart';

class AuthBloc extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestService _restService = getIt<RestService>();

  AuthBloc() : super(const UnauthenticatedState()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _handleAuthenticatedUser(user);
      } else {
        emit(const UnauthenticatedState());
      }
    });
  }

  Future<void> _handleAuthenticatedUser(User user) async {
    emit(const AuthenticatingState()); // Показываем прогресс при авторизации
    try {
      emit(AuthenticatedState(user, progress: true)); // Начинаем верификацию
      await verifyTokenOnServer(); // Автоматически выполняем верификацию
    } catch (e) {
      emit(
        AuthenticatedState(user, progress: false),
      ); // Ошибка, но остаёмся авторизованными
      print('Error during authentication: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      const clientId =
          '68673754284-ikng2jrso2eut4behfp5grlklaimjdn6.apps.googleusercontent.com';
      final googleUser = await GoogleSignIn(clientId: clientId).signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> verifyTokenOnServer() async {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      final token = await currentState.user.getIdToken();
      debugPrint('IdToken: $token');
      try {
        final response = await _restService.verifyToken('Bearer $token');
        if (response.isSuccessful) {
          debugPrint('Server response: ${response.bodyString}');
          emit(MainTransitionState());
        } else {
          final error = response.error as Map<String, dynamic>?;
          final errorMessage = error?['error'] as String?;
          if (errorMessage == 'no_such_user') {
            emit(AuthenticatedState(currentState.user, progress: false));
          } else {
            debugPrint('Other server error: ${errorMessage ?? response.error}');
          }
        }
      } catch (e) {
        debugPrint('Error verifying token: $e');
      }
    }
  }

  Future<void> editUserData(bool seller) async {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      emit(AuthenticatedState(currentState.user, progress: true));
      final token = await currentState.user.getIdToken();
      try {
        final response = await _restService.editUserData('Bearer $token', {
          'name': currentState.user.displayName,
          'email': currentState.user.email,
          'seller': seller,
        });
        if (response.isSuccessful) {
          debugPrint('User data updated: ${response.bodyString}');
          emit(MainTransitionState());
        } else {
          debugPrint('Failed to update user data: ${response.error}');
          emit(AuthenticatedState(currentState.user, progress: false));
        }
      } catch (e) {
        debugPrint('Error editing user data: $e');
        emit(AuthenticatedState(currentState.user, progress: false));
      }
    }
  }
}
