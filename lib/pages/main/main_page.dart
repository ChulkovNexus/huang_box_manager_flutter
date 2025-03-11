import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/add_bought_inferences/add_bought_inferences_widget.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/bought_inferences_widget.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/add_inference/new_inference_widget.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_widget.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:huang_box_manager_web/pages/main/main_state.dart';
import 'package:huang_box_manager_web/pages/main/profile/profile_page.dart';
import 'package:huang_box_manager_web/pages/main/settings/settings_page.dart';
import 'package:huang_box_manager_web/pages/main/sidebar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  final List<Widget> _contentWidgets = const [
    MyInferencesContent(),
    BoughtInferencesContent(),
    ProfileContent(),
    SettingsContent(),
    AddInferenceContent(),
    AddBoughtInferencesContent(),
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
          appBar: AppBar(title: const Text('Main Page'), automaticallyImplyLeading: true),
          drawer:
              ResponsiveBreakpoints.of(buildContext).smallerOrEqualTo(MOBILE) ? const Drawer(child: Sidebar()) : null,
          body: Row(
            // Заменяем ResponsiveRowColumn на Row для простоты
            crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем по вертикали
            children: [
              // Sidebar (только на больших экранах)
              if (ResponsiveBreakpoints.of(buildContext).largerThan(MOBILE))
                Container(
                  width: 250, // Фиксированная ширина боковой панели
                  color: Colors.grey[200], // Для визуальной отладки
                  child: const Sidebar(),
                ),
              // Основной контент
              Expanded(
                child: BlocBuilder<MainBloc, MainState>(
                  builder: (context, state) {
                    Widget content;
                    if (state is MenuItemSelectedState) {
                      final index = state.selectedIndex;
                      if (index >= 0 && index < _contentWidgets.length) {
                        content = _contentWidgets[index];
                      } else {
                        content = const Center(child: Text('Invalid selection'));
                      }
                    } else {
                      content = const Center(child: Text('Welcome to the Main Page!'));
                    }
                    return content;
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
