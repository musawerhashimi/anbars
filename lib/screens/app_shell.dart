import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/app_strings.dart';
import '../providers/backup_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/common/anbar_bottom_nav.dart';
import 'home/home_screen.dart';
import 'sales/sales_screen.dart';
import 'settings/backup_due_sheet.dart';
import 'warehouse/warehouse_screen.dart';
import 'settings/settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  static const _screens = [
    HomeScreen(),
    SalesScreen(),
    WarehouseScreen(),
    SettingsScreen(),
  ];

  bool _promptingBackup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBackupDue());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkBackupDue();
  }

  Future<void> _checkBackupDue() async {
    final notifier = ref.read(backupProvider.notifier);
    if (_promptingBackup || notifier.busy) return;
    final backup = await ref.read(backupProvider.future);
    if (!backup.isDue || !mounted || _promptingBackup) return;

    _promptingBackup = true;
    await showBackupDueSheet(context);
    _promptingBackup = false;
    if (ref.read(backupProvider).valueOrNull?.isDue ?? false) {
      await notifier.snooze();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final lowStock = ref.watch(lowStockCountProvider);
    final s = ref.watch(stringsProvider);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(currentTab),
          child: _screens[currentTab],
        ),
      ),
      bottomNavigationBar: AnbarBottomNav(
        index: currentTab,
        lowStock: lowStock,
        onChanged: (i) => ref.read(currentTabProvider.notifier).state = i,
        items: [
          AnbarNavItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: s.navHome,
          ),
          AnbarNavItem(
            icon: Icons.north_east_rounded,
            selectedIcon: Icons.north_east_rounded,
            label: s.navSales,
          ),
          AnbarNavItem(
            icon: Icons.south_rounded,
            selectedIcon: Icons.south_rounded,
            label: s.navWarehouse,
          ),
          AnbarNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: s.navSettings,
          ),
        ],
      ),
    );
  }
}
