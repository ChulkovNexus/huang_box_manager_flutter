import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/dashboard/dashboard_block.dart';
import 'package:huang_box_manager_web/pages/main/dashboard/dashboard_state.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return const Center(child: Text('Dashboard Content'));
        },
      ),
    );
  }
}
