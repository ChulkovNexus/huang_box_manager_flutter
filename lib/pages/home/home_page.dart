import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Переход на страницу авторизации
            context.go('/auth');
          },
          child: const Text('Авторизоваться'),
        ),
      ),
    );
  }
}
