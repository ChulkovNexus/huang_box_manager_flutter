// Placeholder BLoC and State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/profile/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  ProfileBloc() : super(const ProfileInitialState());
}
