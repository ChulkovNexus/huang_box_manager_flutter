import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huang_box_manager_web/pages/main/dashboard/dashboard_widget.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:huang_box_manager_web/pages/main/main_state.dart';
import 'package:huang_box_manager_web/pages/main/profile/profile_page.dart';
import 'package:huang_box_manager_web/pages/main/settings/settings_page.dart';
import 'package:huang_box_manager_web/pages/main/sidebar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // List of content widgets corresponding to menu items (excluding Sign Out)
  final List<Widget> _contentWidgets = const [
    DashboardContent(),
    ProfileContent(),
    SettingsContent(),
  ];

  @override
  Widget build(BuildContext buildContext) {
    return BlocProvider(
      create: (_) => MainBloc(),
      child: BlocListener<MainBloc, MainState>(
        listener: (context, state) {
          debugPrint('Listener triggered with state: $state');
          if (state is UnauthenticatedState) {
            debugPrint('UnauthenticatedState detected');
            context.go('/auth');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Main Page'),
            automaticallyImplyLeading: true,
          ),
          drawer:
              ResponsiveBreakpoints.of(buildContext).smallerOrEqualTo(MOBILE)
                  ? const Drawer(child: Sidebar())
                  : null,
          body: ResponsiveRowColumn(
            layout:
                ResponsiveBreakpoints.of(buildContext).largerThan(MOBILE)
                    ? ResponsiveRowColumnType.ROW
                    : ResponsiveRowColumnType.COLUMN,
            children: [
              // Sidebar (visible only on larger screens)
              ResponsiveRowColumnItem(
                rowFlex: 1,
                columnOrder: 1,
                child: ResponsiveVisibility(
                  visible: ResponsiveBreakpoints.of(
                    buildContext,
                  ).largerThan(MOBILE),
                  child: const Sidebar(),
                ),
              ),
              // Main content area
              ResponsiveRowColumnItem(
                rowFlex: 3,
                child: BlocBuilder<MainBloc, MainState>(
                  builder: (context, state) {
                    if (state is MenuItemSelectedState) {
                      final index = state.selectedIndex;
                      if (index >= 0 && index < _contentWidgets.length) {
                        return _contentWidgets[index];
                      }
                    }
                    return const Center(
                      child: Text('Welcome to the Main Page!'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
