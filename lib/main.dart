import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huang_box_manager_web/pages/auth/auth_page.dart';
import 'package:huang_box_manager_web/pages/home/home_page.dart';
import 'package:huang_box_manager_web/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ClientApp extends StatelessWidget {
  ClientApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      // Главная страница
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // Страница авторизации
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => AuthPage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (_, theme) {
          return MaterialApp.router(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: [const Locale('ru')],
            theme: theme,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
