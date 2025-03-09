import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:huang_box_manager_web/pages/main/main_state.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  static final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Profile', 'icon': Icons.person},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Sign Out', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Menu items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder:
                  (context, index) => BlocBuilder<MainBloc, MainState>(
                    builder: (context, state) {
                      final isSelected =
                          state is MenuItemSelectedState &&
                          state.selectedIndex == index;
                      return ListTile(
                        leading: Icon(_menuItems[index]['icon']),
                        title: Text(_menuItems[index]['title']),
                        selected: isSelected,
                        onTap: () {
                          if (index == _menuItems.length - 1) {
                            context.read<MainBloc>().signOut();
                          } else {
                            context.read<MainBloc>().selectMenuItem(index);
                          }
                          // Close the drawer if this is inside a Drawer (mobile)
                          if (context.findAncestorWidgetOfExactType<Drawer>() !=
                              null) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
