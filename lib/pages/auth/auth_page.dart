import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:huang_box_manager_web/pages/auth/auth_block.dart';
import 'auth_state.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is MainTransitionState) {
            context.go('/main');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Firebase Auth Example',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is UnauthenticatedState) {
                return _buildUnauthenticatedView(context);
              } else if (state is AuthenticatingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AuthenticatedState) {
                return _buildAuthenticatedView(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () => context.read<AuthBloc>().signInWithGoogle(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.grey),
            ),
            elevation: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/google_logo.png', height: 24),
              const SizedBox(width: 10),
              const Text(
                'Sign in with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    AuthenticatedState state,
  ) {
    final isSeller = ValueNotifier<bool>(
      false,
    ); // Используем ValueNotifier для состояния чекбокса

    if (state.isVerifying) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${state.user.displayName ?? 'User'}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: isSeller,
            builder: (context, value, child) {
              return CheckboxListTile(
                title: const Text('Продавец'),
                value: value,
                onChanged: (newValue) {
                  isSeller.value = newValue ?? false;
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                () => context.read<AuthBloc>().editUserData(
                  !isSeller.value,
                ), // Инвертируем, так как "не продавец" = false
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Edit User Data',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
