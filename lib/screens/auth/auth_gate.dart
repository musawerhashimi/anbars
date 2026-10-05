import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/user_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'register_screen.dart';

enum _Start { loading, intro, register, login }

final startupProvider = FutureProvider<_Start>((ref) async {
  final settings = UserService();
  final seen = await settings.getSetting('onboarding_done');
  if (seen != '1') return _Start.intro;
  if (await settings.needsRegistration()) return _Start.register;
  return _Start.login;
});

/// First open shows the intro, then account creation. Later opens go to login.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(startupProvider);
    return start.when(
      loading: () => const _BootSplash(),
      error: (_, _) => const LoginScreen(),
      data: (step) => switch (step) {
        _Start.intro => OnboardingScreen(
          onDone: () async {
            await UserService().setSetting('onboarding_done', '1');
            ref.invalidate(startupProvider);
          },
        ),
        _Start.register => const RegisterScreen(),
        _Start.login || _Start.loading => const LoginScreen(),
      },
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
    );
  }
}
