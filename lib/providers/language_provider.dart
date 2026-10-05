import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

class AppLanguage {
  final String code;   // 'fa' | 'en'
  final Locale locale;
  final TextDirection direction;
  final String label;
  final String nativeLabel;

  const AppLanguage({
    required this.code,
    required this.locale,
    required this.direction,
    required this.label,
    required this.nativeLabel,
  });
}

class LanguageNotifier extends AsyncNotifier<AppLanguage> {
  final _service = UserService();

  static const _dari = AppLanguage(
    code: 'fa',
    locale: Locale('fa'),
    direction: TextDirection.rtl,
    label: 'دری',
    nativeLabel: 'دری',
  );

  static const _english = AppLanguage(
    code: 'en',
    locale: Locale('en'),
    direction: TextDirection.ltr,
    label: 'انگلیسی',
    nativeLabel: 'English',
  );

  static const supported = [_dari, _english];

  @override
  Future<AppLanguage> build() async {
    final code = await _service.getSetting('language') ?? 'fa';
    return code == 'en' ? _english : _dari;
  }

  Future<void> setLanguage(AppLanguage lang) async {
    await _service.setSetting('language', lang.code);
    state = AsyncData(lang);
  }
}

final languageProvider =
    AsyncNotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);
