import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import 'master_data_screen.dart';
import 'profile_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider).valueOrNull;
    final user = ref.watch(userProvider).valueOrNull;
    final language = ref.watch(languageProvider).valueOrNull;
    final s = ref.watch(stringsProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AnbarAppBar(
        title: s.settings,
        icon: Icons.settings_rounded,
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          // ── Profile Card ─────────────────────────────────────────────────
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ProfileSheet(),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      (user?.username ?? s.admin)[0],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? s.admin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user?.email ?? s.tapToEditProfile,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Appearance ───────────────────────────────────────────────────
          _SectionLabel(s.appearance),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? AppColors.primaryLight : AppColors.amber,
            title: s.darkMode,
            trailing: Switch(
              value: isDark,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
            ),
          ),

          const SizedBox(height: 24),

          // ── Language ─────────────────────────────────────────────────────
          _SectionLabel(s.language),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.green,
            title: s.language,
            subtitle: language != null
                ? '${language.nativeLabel}  •  ${language.label}'
                : 'دری',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLanguagePicker(context, ref, language, s),
          ),

          const SizedBox(height: 24),

          // ── Master Data ──────────────────────────────────────────────────
          _SectionLabel(s.masterData),
          const SizedBox(height: 8),
          _masterDataTile(context, Icons.straighten_rounded, AppColors.blue, s.units, MasterDataType.units),
          _masterDataTile(context, Icons.category_rounded, AppColors.green, s.categories, MasterDataType.categories),
          _masterDataTile(context, Icons.warehouse_rounded, AppColors.primary, s.departments, MasterDataType.departments),
          _masterDataTile(context, Icons.business_rounded, AppColors.amber, s.vendors, MasterDataType.vendors),

          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────
          _SectionLabel(s.about),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.blue,
            title: s.appVersion,
            subtitle: '1.0.0',
          ),

          const SizedBox(height: 32),

          // ── Logout ───────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              ),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                s.logout,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppLanguage? current, AppStrings s) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  s.selectLanguage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const Divider(height: 1),
            ...LanguageNotifier.supported.map((lang) {
              final isSelected = current?.code == lang.code;
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.language_rounded, size: 18,
                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                title: Text(lang.nativeLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        )),
                subtitle: Text(lang.label),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(languageProvider.notifier).setLanguage(lang);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _masterDataTile(BuildContext context, IconData icon, Color color, String label, MasterDataType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _SettingsTile(
        icon: icon,
        iconColor: color,
        title: label,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MasterDataScreen(type: type)),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: theme.colorScheme.surface,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: subtitle != null ? Text(subtitle!, style: theme.textTheme.bodySmall) : null,
      trailing: trailing,
    );
  }
}
