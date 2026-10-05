import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/app_strings.dart';
import '../core/utils/formatters.dart';
import '../services/backup_service.dart';
import '../services/user_service.dart';
import 'category_provider.dart';
import 'dashboard_provider.dart';
import 'department_provider.dart';
import 'language_provider.dart';
import 'product_provider.dart';
import 'sale_provider.dart';
import 'theme_provider.dart';
import 'unit_provider.dart';
import 'user_provider.dart';
import 'vendor_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

enum BackupFrequency { off, daily, weekly, monthly }

class BackupState {
  final String email;
  final DateTime? lastBackup;
  final BackupFrequency frequency;
  final DateTime? snoozedUntil;

  const BackupState({
    this.email = '',
    this.lastBackup,
    this.frequency = BackupFrequency.off,
    this.snoozedUntil,
  });

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static bool isValidEmail(String email) => _emailPattern.hasMatch(email);

  bool get hasValidEmail => isValidEmail(email);

  /// When the next automatic backup should happen, or null when it's off.
  DateTime? get nextBackup {
    final last = lastBackup;
    if (frequency == BackupFrequency.off) return null;
    if (last == null) return DateTime.now();
    return switch (frequency) {
      BackupFrequency.daily => last.add(const Duration(days: 1)),
      BackupFrequency.weekly => last.add(const Duration(days: 7)),
      BackupFrequency.monthly => DateTime(
        last.year,
        last.month + 1,
        last.day,
        last.hour,
        last.minute,
      ),
      BackupFrequency.off => null,
    };
  }

  bool get isDue {
    final next = nextBackup;
    if (next == null) return false;
    final now = DateTime.now();
    if (snoozedUntil != null && now.isBefore(snoozedUntil!)) return false;
    return !now.isBefore(next);
  }

  BackupState copyWith({
    String? email,
    DateTime? lastBackup,
    BackupFrequency? frequency,
    DateTime? snoozedUntil,
    bool clearSnooze = false,
  }) => BackupState(
    email: email ?? this.email,
    lastBackup: lastBackup ?? this.lastBackup,
    frequency: frequency ?? this.frequency,
    snoozedUntil: clearSnooze ? null : snoozedUntil ?? this.snoozedUntil,
  );
}

final backupProvider = AsyncNotifierProvider<BackupNotifier, BackupState>(
  BackupNotifier.new,
);

class BackupNotifier extends AsyncNotifier<BackupState> {
  static const _lastBackupKey = 'last_backup';
  static const _emailKey = 'backup_email';
  static const _frequencyKey = 'backup_frequency';
  static const _snoozeKey = 'backup_snoozed_until';
  final _settings = UserService();

  BackupService get _service => ref.read(backupServiceProvider);

  /// True while the email app or file picker is open, so returning to the
  /// app doesn't trigger the automatic backup reminder mid-operation.
  bool get busy => _busyCount > 0;
  int _busyCount = 0;

  Future<T> _track<T>(Future<T> Function() action) async {
    _busyCount++;
    try {
      return await action();
    } finally {
      _busyCount--;
    }
  }

  Future<BackupState> _current() async => state.valueOrNull ?? await future;

  @override
  Future<BackupState> build() async {
    DateTime? date(String? v) => v == null ? null : DateTime.tryParse(v);
    final frequency = await _settings.getSetting(_frequencyKey);
    return BackupState(
      email:
          await _settings.getSetting(_emailKey) ??
          (await _settings.getUser())?.email ??
          '',
      lastBackup: date(await _settings.getSetting(_lastBackupKey)),
      frequency: BackupFrequency.values.firstWhere(
        (f) => f.name == frequency,
        orElse: () => BackupFrequency.off,
      ),
      snoozedUntil: date(await _settings.getSetting(_snoozeKey)),
    );
  }

  Future<void> setFrequency(BackupFrequency frequency) async {
    final current = await _current();
    await _settings.setSetting(_frequencyKey, frequency.name);
    await _settings.setSetting(_snoozeKey, '');
    state = AsyncData(
      current.copyWith(frequency: frequency, clearSnooze: true),
    );
  }

  Future<void> setEmail(String email) async {
    final current = await _current();
    if (email == current.email) return;
    await _settings.setSetting(_emailKey, email);
    state = AsyncData(current.copyWith(email: email));
  }

  /// Postpones the automatic backup reminder until tomorrow.
  Future<void> snooze() async {
    final current = await _current();
    final until = DateTime.now().add(const Duration(days: 1));
    await _settings.setSetting(_snoozeKey, until.toIso8601String());
    state = AsyncData(current.copyWith(snoozedUntil: until));
  }

  /// Saves [email] as the backup recipient and opens the email app with the
  /// backup file attached.
  Future<void> emailBackup(String email) => _track(() => _emailBackup(email));

  Future<void> _emailBackup(String email) async {
    final s = ref.read(stringsProvider);
    final current = await _current();
    await _settings.setSetting(_emailKey, email);
    await _service.emailBackup(
      email: email,
      subject: s.backupEmailSubject(Formatters.longDate(DateTime.now())),
      body: s.backupEmailBody,
    );
    final now = DateTime.now();
    await _settings.setSetting(_lastBackupKey, now.toIso8601String());
    await _settings.setSetting(_snoozeKey, '');
    state = AsyncData(
      current.copyWith(email: email, lastBackup: now, clearSnooze: true),
    );
  }

  Future<File?> pickBackupFile() => _track(_service.pickBackupFile);

  /// Restores [file] and reloads every data provider from the new database.
  Future<void> restore(File file) async {
    await _service.restore(file);
    ref
      ..invalidate(productsProvider)
      ..invalidate(salesProvider)
      ..invalidate(salesTodayTotalProvider)
      ..invalidate(salesMonthTotalProvider)
      ..invalidate(transactionsTodayProvider)
      ..invalidate(dashboardStatsProvider)
      ..invalidate(categoriesProvider)
      ..invalidate(departmentsProvider)
      ..invalidate(unitsProvider)
      ..invalidate(vendorsProvider)
      ..invalidate(userProvider)
      ..invalidate(themeProvider)
      ..invalidate(languageProvider);
    ref.invalidateSelf();
  }
}
