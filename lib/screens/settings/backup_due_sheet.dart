import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../providers/backup_provider.dart';
import '../../providers/navigation_provider.dart';
import 'backup_section.dart';

Future<void> showBackupDueSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => const BackupDueSheet(),
);

/// Reminder shown when an automatic (daily / weekly / monthly) backup is due.
class BackupDueSheet extends ConsumerStatefulWidget {
  const BackupDueSheet({super.key});

  @override
  ConsumerState<BackupDueSheet> createState() => _BackupDueSheetState();
}

class _BackupDueSheetState extends ConsumerState<BackupDueSheet> {
  bool _sending = false;

  Future<void> _send(String email) async {
    setState(() => _sending = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final s = ref.read(stringsProvider);
    try {
      await ref.read(backupProvider.notifier).emailBackup(email);
      navigator.pop();
    } catch (e) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${s.backupFailed}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openSettings() {
    ref.read(currentTabProvider.notifier).state = 3;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);
    final state = ref.watch(backupProvider).valueOrNull ?? const BackupState();
    final freq = backupFrequencyLabel(state.frequency, s);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.backupDueTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.hasValidEmail
                  ? s.backupDueMessage(freq)
                  : s.backupDueNoEmail(freq),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (state.hasValidEmail) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.alternate_email_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        state.email,
                        textDirection: TextDirection.ltr,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: WideActionButton(
                    icon: Icons.schedule_rounded,
                    label: s.later,
                    outlined: true,
                    onTap: _sending ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: state.hasValidEmail
                      ? WideActionButton(
                          icon: Icons.send_rounded,
                          label: _sending ? s.preparingBackup : s.sendNow,
                          busy: _sending,
                          onTap: _sending ? null : () => _send(state.email),
                        )
                      : WideActionButton(
                          icon: Icons.settings_rounded,
                          label: s.openSettings,
                          onTap: _openSettings,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
