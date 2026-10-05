import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/formatters.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fa');
  await initializeDateFormatting('en');
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ProviderScope(child: AnbarApp()));
}

class AnbarApp extends ConsumerWidget {
  const AnbarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).valueOrNull ?? ThemeMode.light;
    final language = ref.watch(languageProvider).valueOrNull;
    final isDari = language?.code != 'en';
    Formatters.locale = isDari ? 'fa' : 'en';

    return MaterialApp(
      title: isDari ? 'انبار' : 'Anbar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(isDari: isDari),
      darkTheme: AppTheme.dark(isDari: isDari),
      themeMode: themeMode,

      // ── Locale & Direction ───────────────────────────────────────────────
      locale: language?.locale ?? const Locale('fa'),
      supportedLocales: LanguageNotifier.supported.map((l) => l.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: language?.direction ?? TextDirection.rtl,
        child: child!,
      ),

      home: const LoginScreen(),
    );
  }
}
