import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/user_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/department_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/unit_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/soft_card.dart';
import '../auth/login_screen.dart';
import '../sales/sale_history_screen.dart';
import 'master_data_screen.dart';
import 'profile_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openProfile(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ProfileSheet(),
  );

  void _openMasterData(BuildContext context, MasterDataType type) =>
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => MasterDataScreen(type: type)));

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
  ) async {
    final ok = await showConfirmDialog(
      context,
      title: s.logout,
      message: s.logoutConfirm,
      confirmLabel: s.logout,
      cancelLabel: s.cancel,
      confirmColor: AppColors.accent,
    );
    if (!ok || !context.mounted) return;
    ref.read(currentTabProvider.notifier).state = 0;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(userProvider).valueOrNull;
    final themeMode = ref.watch(themeProvider).valueOrNull ?? ThemeMode.light;
    final language = ref.watch(languageProvider).valueOrNull;

    String count(AsyncValue<List<Object>> list) =>
        s.recordsCount(Formatters.number(list.valueOrNull?.length ?? 0));

    return Scaffold(
      appBar: AnbarAppBar(title: s.settings, showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
        children: [
          // ── Profile ────────────────────────────────────────────────────
          _ProfileCard(
            s: s,
            user: user,
            products: ref.watch(totalProductsProvider),
            sales: ref.watch(salesProvider).valueOrNull?.length ?? 0,
            categories: ref.watch(categoriesProvider).valueOrNull?.length ?? 0,
            onEdit: () => _openProfile(context),
          ),

          // ── Appearance ─────────────────────────────────────────────────
          _SectionLabel(s.appearance),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InlineLabel(
                  icon: Icons.palette_rounded,
                  color: AppColors.secondary,
                  title: s.theme,
                ),
                const SizedBox(height: 12),
                _SegmentedPicker<ThemeMode>(
                  value: themeMode,
                  onChanged: (m) => ref.read(themeProvider.notifier).setMode(m),
                  options: [
                    _Option(
                      ThemeMode.light,
                      s.themeLight,
                      Icons.light_mode_rounded,
                    ),
                    _Option(
                      ThemeMode.dark,
                      s.themeDark,
                      Icons.dark_mode_rounded,
                    ),
                    _Option(
                      ThemeMode.system,
                      s.themeSystem,
                      Icons.brightness_auto_rounded,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                _InlineLabel(
                  icon: Icons.translate_rounded,
                  color: AppColors.primary,
                  title: s.language,
                ),
                const SizedBox(height: 12),
                _SegmentedPicker<String>(
                  value: language?.code ?? 'fa',
                  onChanged: (code) => ref
                      .read(languageProvider.notifier)
                      .setLanguage(
                        LanguageNotifier.supported.firstWhere(
                          (l) => l.code == code,
                        ),
                      ),
                  options: [
                    for (final lang in LanguageNotifier.supported)
                      _Option(lang.code, lang.nativeLabel, null),
                  ],
                ),
              ],
            ),
          ),

          // ── Account ────────────────────────────────────────────────────
          _SectionLabel(s.account),
          _Group(
            children: [
              _GroupTile(
                icon: Icons.person_rounded,
                color: AppColors.secondary,
                title: s.editProfile,
                subtitle: s.usernameAndPassword,
                onTap: () => _openProfile(context),
              ),
              _GroupTile(
                icon: Icons.lock_rounded,
                color: AppColors.amber,
                title: s.changePassword,
                onTap: () => _openProfile(context),
              ),
            ],
          ),

          // ── Master data ────────────────────────────────────────────────
          _SectionLabel(s.masterData),
          _Group(
            children: [
              _GroupTile(
                icon: Icons.warehouse_rounded,
                color: AppColors.primary,
                title: s.departments,
                subtitle: count(ref.watch(departmentsProvider)),
                onTap: () =>
                    _openMasterData(context, MasterDataType.departments),
              ),
              _GroupTile(
                icon: Icons.category_rounded,
                color: AppColors.secondary,
                title: s.categories,
                subtitle: count(ref.watch(categoriesProvider)),
                onTap: () =>
                    _openMasterData(context, MasterDataType.categories),
              ),
              _GroupTile(
                icon: Icons.straighten_rounded,
                color: AppColors.amber,
                title: s.units,
                subtitle: count(ref.watch(unitsProvider)),
                onTap: () => _openMasterData(context, MasterDataType.units),
              ),
              _GroupTile(
                icon: Icons.storefront_rounded,
                color: AppColors.accent,
                title: s.vendors,
                subtitle: count(ref.watch(vendorsProvider)),
                onTap: () => _openMasterData(context, MasterDataType.vendors),
              ),
            ],
          ),

          // ── Reports ────────────────────────────────────────────────────
          _SectionLabel(s.reports),
          _Group(
            children: [
              _GroupTile(
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
                title: s.saleHistory,
                subtitle: s.saleHistoryHint,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SaleHistoryScreen()),
                ),
              ),
            ],
          ),

          // ── About ──────────────────────────────────────────────────────
          _SectionLabel(s.about),
          _AboutCard(s: s),

          const SizedBox(height: 20),
          _LogoutButton(label: s.logout, onTap: () => _logout(context, ref, s)),
        ],
      ),
    );
  }
}

// ─── Profile ────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final AppStrings s;
  final UserModel? user;
  final int products;
  final int sales;
  final int categories;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.s,
    required this.user,
    required this.products,
    required this.sales,
    required this.categories,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.username ?? s.admin;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                s.admin,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              user!.email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _ProfileStat(value: products, label: s.productsShort),
                _StatDivider(),
                _ProfileStat(value: sales, label: s.salesShort),
                _StatDivider(),
                _ProfileStat(value: categories, label: s.categories),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final int value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            Formatters.number(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    color: Colors.white.withValues(alpha: 0.25),
  );
}

// ─── Building blocks ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 24, 6, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}

class _InlineLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  const _InlineLabel({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBadge(icon: icon, color: color),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 66, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _GroupTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _IconBadge(icon: icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            Icon(
              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _Option<T> {
  final T value;
  final String label;
  final IconData? icon;
  const _Option(this.value, this.label, this.icon);
}

class _SegmentedPicker<T> extends StatelessWidget {
  final T value;
  final List<_Option<T>> options;
  final ValueChanged<T> onChanged;

  const _SegmentedPicker({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: o.value == value
                        ? (isDark ? AppColors.darkBorder : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: o.value == value && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (o.icon != null) ...[
                        Icon(
                          o.icon,
                          size: 18,
                          color: o.value == value
                              ? AppColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: o.value == value
                                ? AppColors.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: o.value == value
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final AppStrings s;
  const _AboutCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.appTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(s.inventoryManagement, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'v${Formatters.number(1)}.${Formatters.number(0)}.${Formatters.number(0)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LogoutButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: Color.alphaBlend(
        AppColors.accent.withValues(alpha: 0.08),
        Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
