import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  final String? errorMessage;
  final bool isLoading;

  const AuthState({this.errorMessage, this.isLoading = false});

  @override
  List<Object?> get props => [errorMessage, isLoading];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState({super.errorMessage, super.isLoading});
}

class AuthenticatingState extends AuthState {
  const AuthenticatingState() : super(isLoading: true);
}

class MainTransitionState extends AuthState {
  const MainTransitionState();
}

class AuthenticatedState extends AuthState {
  final User user;
  final bool progress;

  const AuthenticatedState(this.user, {required this.progress, super.errorMessage, super.isLoading});

  @override
  List<Object?> get props => [user, progress, errorMessage, isLoading];
}
