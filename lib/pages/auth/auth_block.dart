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
    emit(const AuthenticatingState());
    try {
      emit(AuthenticatedState(user, progress: true));
      await verifyTokenOnServer();
    } catch (e) {
      emit(AuthenticatedState(user, progress: false, errorMessage: 'Ошибка при аутентификации: $e'));
      debugPrint('Error during authentication: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const UnauthenticatedState(isLoading: true));
    try {
      const clientId = '68673754284-ikng2jrso2eut4behfp5grlklaimjdn6.apps.googleusercontent.com';
      final googleUser = await GoogleSignIn(clientId: clientId).signIn();

      if (googleUser == null) {
        emit(const UnauthenticatedState(errorMessage: 'Вход был отменен пользователем'));
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      emit(UnauthenticatedState(errorMessage: 'Ошибка входа через Google: ${e.toString()}'));
    }
  }

  Future<void> verifyTokenOnServer() async {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      emit(AuthenticatedState(currentState.user, progress: true, isLoading: true));

      try {
        final token = await currentState.user.getIdToken();
        debugPrint('IdToken: $token');

        final response = await _restService.verifyToken('Bearer $token');
        if (response.isSuccessful) {
          debugPrint('Server response: ${response.bodyString}');
          emit(MainTransitionState());
        } else {
          final error = response.error as Map<String, dynamic>?;
          final errorMessage = error?['error'] as String?;
          if (errorMessage == 'no_such_user') {
            emit(
              AuthenticatedState(currentState.user, progress: false, errorMessage: 'Пользователь не найден на сервере'),
            );
          } else {
            emit(
              AuthenticatedState(
                currentState.user,
                progress: false,
                errorMessage: 'Ошибка сервера: ${errorMessage ?? response.error}',
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error verifying token: $e');
        emit(AuthenticatedState(currentState.user, progress: false, errorMessage: 'Ошибка при верификации токена: $e'));
      }
    }
  }

  Future<void> editUserData(bool seller) async {
    if (state is AuthenticatedState) {
      final currentState = state as AuthenticatedState;
      emit(AuthenticatedState(currentState.user, progress: true, isLoading: true));

      try {
        final token = await currentState.user.getIdToken();
        final response = await _restService.editUserData('Bearer $token', {
          'name': currentState.user.displayName,
          'email': currentState.user.email,
          'seller': seller,
        });

        if (response.isSuccessful) {
          debugPrint('User data updated: ${response.bodyString}');
          emit(MainTransitionState());
        } else {
          emit(
            AuthenticatedState(
              currentState.user,
              progress: false,
              errorMessage: 'Ошибка обновления данных: ${response.error}',
            ),
          );
        }
      } catch (e) {
        debugPrint('Error editing user data: $e');
        emit(AuthenticatedState(currentState.user, progress: false, errorMessage: 'Ошибка при обновлении данных: $e'));
      }
    }
  }
}
