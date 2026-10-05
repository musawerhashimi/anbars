import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_service.dart';

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  final _service = UserService();

  @override
  Future<ThemeMode> build() async {
    final value = await _service.getSetting('theme_mode');
    return switch (value) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    final next = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _service.setSetting(
      'theme_mode',
      next == ThemeMode.dark ? 'dark' : 'light',
    );
    state = AsyncData(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    await _service.setSetting('theme_mode', mode.name);
    state = AsyncData(mode);
  }
}
