import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthenticatingState extends AuthState {
  const AuthenticatingState();
}

class MainTransitionState extends AuthState {
  const MainTransitionState();
}

class AuthenticatedState extends AuthState {
  final User user;
  final bool isVerifying = false;

  const AuthenticatedState(this.user, {progress});

  @override
  List<Object?> get props => [user, isVerifying];
}
