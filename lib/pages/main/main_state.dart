import 'package:equatable/equatable.dart';

abstract class MainState extends Equatable {
  const MainState();

  @override
  List<Object?> get props => [];
}

class InitialMainState extends MainState {
  const InitialMainState();
}

class MenuItemSelectedState extends MainState {
  final int selectedIndex;

  const MenuItemSelectedState(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}

class UnauthenticatedState extends MainState {
  const UnauthenticatedState();
}
