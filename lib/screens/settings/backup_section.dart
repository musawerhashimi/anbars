import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/backup_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/segmented_picker.dart';
import '../../widgets/common/soft_card.dart';

String backupFrequencyLabel(BackupFrequency f, AppStrings s) => switch (f) {
  BackupFrequency.off => s.frequencyOff,
  BackupFrequency.daily => s.frequencyDaily,
  BackupFrequency.weekly => s.frequencyWeekly,
  BackupFrequency.monthly => s.frequencyMonthly,
};

class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  final _emailCtrl = TextEditingController();
  bool _emailLoaded = false;
  bool _sending = false;
  String? _emailError;

  AppStrings get _s => ref.read(stringsProvider);
  BackupNotifier get _notifier => ref.read(backupProvider.notifier);

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.primary,
      ),
    );
  }

  Future<void> _send() async {
    final s = _s;
    final email = _emailCtrl.text.trim();
    if (!BackupState.isValidEmail(email)) {
      setState(() => _emailError = s.invalidEmail);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _sending = true;
    });
    try {
      await _notifier.emailBackup(email);
    } catch (e) {
      if (mounted) _snack('${s.backupFailed}: $e', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onEmailChanged(String value) {
    final email = value.trim();
    if (_emailError != null) setState(() => _emailError = null);
    if (BackupState.isValidEmail(email)) _notifier.setEmail(email);
  }

  Future<void> _setFrequency(BackupFrequency frequency) async {
    final email = _emailCtrl.text.trim();
    if (frequency != BackupFrequency.off && !BackupState.isValidEmail(email)) {
      setState(() => _emailError = _s.invalidEmail);
    }
    await _notifier.setFrequency(frequency);
  }

  Future<void> _restore() async {
    final s = _s;
    final file = await _notifier.pickBackupFile();
    if (file == null || !mounted) return;

    final ok = await showConfirmDialog(
      context,
      title: s.restore,
      message: s.restoreConfirm,
      confirmLabel: s.restore,
      cancelLabel: s.cancel,
      confirmColor: AppColors.accent,
    );
    if (!ok || !mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(label: s.restoring),
    );
    try {
      await _notifier.restore(file);
      navigator.pop();
      _emailLoaded = false;
      if (mounted) _snack(ref.read(stringsProvider).restoreSuccess);
    } on FormatException {
      navigator.pop();
      if (mounted) _snack(s.invalidBackup, error: true);
    } catch (e) {
      navigator.pop();
      if (mounted) _snack('${s.restoreFailed}: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);
    final state = ref.watch(backupProvider).valueOrNull;

    if (state != null && !_emailLoaded) {
      _emailCtrl.text = state.email;
      _emailLoaded = true;
    }

    final lastBackup = state?.lastBackup;
    final lastLabel = lastBackup == null
        ? s.neverBackedUp
        : s.lastBackup(
            '${Formatters.longDate(lastBackup)} · ${Formatters.time(lastBackup)}',
          );

    final frequency = state?.frequency ?? BackupFrequency.off;
    final next = state?.nextBackup;
    final String? nextLabel;
    if (next == null) {
      nextLabel = null;
    } else if (!next.isAfter(DateTime.now())) {
      nextLabel = s.backupDueNow;
    } else {
      nextLabel = s.nextBackup(
        '${Formatters.longDate(next)} · ${Formatters.time(next)}',
      );
    }

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.brandGradient,
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.emailBackupTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(s.emailBackupHint, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            autocorrect: false,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            onChanged: _onEmailChanged,
            decoration: InputDecoration(
              labelText: s.backupEmail,
              hintText: 'name@gmail.com',
              hintTextDirection: TextDirection.ltr,
              errorText: _emailError,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.autorenew_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                s.autoBackup,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedPicker<BackupFrequency>(
            value: frequency,
            onChanged: _setFrequency,
            options: [
              for (final f in BackupFrequency.values)
                SegmentOption(f, backupFrequencyLabel(f, s), null),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.autoBackupHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  lastBackup == null
                      ? Icons.cloud_off_rounded
                      : Icons.cloud_done_rounded,
                  size: 18,
                  color: lastBackup == null
                      ? theme.colorScheme.onSurfaceVariant
                      : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lastLabel, style: theme.textTheme.bodySmall),
                      if (nextLabel != null)
                        Text(
                          nextLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: WideActionButton(
                  icon: Icons.send_rounded,
                  label: _sending ? s.preparingBackup : s.sendBackup,
                  busy: _sending,
                  onTap: _sending ? null : _send,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WideActionButton(
                  icon: Icons.settings_backup_restore_rounded,
                  label: s.restoreFromFile,
                  outlined: true,
                  onTap: _sending ? null : _restore,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.restoreHowTo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WideActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool outlined;

  const WideActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = outlined ? AppColors.secondary : Colors.white;
    return Opacity(
      opacity: enabled || busy ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: outlined
                ? null
                : const LinearGradient(
                    colors: AppColors.brandGradient,
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
            color: outlined
                ? AppColors.secondary.withValues(alpha: 0.08)
                : null,
            border: outlined
                ? Border.all(color: AppColors.secondary.withValues(alpha: 0.5))
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: fg,
                      ),
                    )
                  else
                    Icon(icon, color: fg, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  final String label;
  const _ProgressDialog({required this.label});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
