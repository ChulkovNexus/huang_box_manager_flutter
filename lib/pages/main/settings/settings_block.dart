// Placeholder BLoC and State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/settings/settings_state.dart';

class SettingsBloc extends Cubit<SettingsState> {
  SettingsBloc() : super(const SettingsInitialState());
}
