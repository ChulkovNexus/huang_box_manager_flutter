import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/profile/profile_block.dart';
import 'package:huang_box_manager_web/pages/main/profile/profile_state.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return const Center(child: Text('Profile Content'));
        },
      ),
    );
  }
}
