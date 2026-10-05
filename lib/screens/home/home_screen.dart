import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../widgets/common/soft_card.dart';
import '../../widgets/sale/sale_tile.dart';
import '../sales/sale_detail_sheet.dart';
import '../sales/sale_history_screen.dart';
import '../warehouse/add_product_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _recentLimit = 5;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(salesProvider);
    ref.invalidate(salesTodayTotalProvider);
    ref.invalidate(salesMonthTotalProvider);
    ref.invalidate(transactionsTodayProvider);
    await ref.read(dashboardStatsProvider.future);
  }

  void _openHistory(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SaleHistoryScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final sales = ref.watch(salesProvider);
    final weekly = ref.watch(weeklySalesProvider);
    final user = ref.watch(userProvider).valueOrNull;
    final lowStock = ref.watch(lowStockCountProvider);
    final s = ref.watch(stringsProvider);
    final now = DateTime.now();

    final greeting = now.hour < 12
        ? s.goodMorning
        : now.hour < 17
        ? s.goodAfternoon
        : s.goodEvening;

    void goToTab(int i) => ref.read(currentTabProvider.notifier).state = i;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        edgeOffset: 80,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AnbarHomeAppBar(
              greeting: greeting,
              username: user?.username ?? s.manager,
              dateLabel: Formatters.longDate(now),
              lowStockCount: lowStock,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverToBoxAdapter(
                child: stats.when(
                  loading: () => const _DashboardSkeleton(),
                  error: (e, _) => Center(child: Text('${s.error}: $e')),
                  data: (st) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Revenue hero ───────────────────────────────────
                      _RevenueCard(
                        s: s,
                        today: st.salesToday,
                        month: st.salesThisMonth,
                        transactions: st.transactionsToday,
                        weekly: weekly,
                      ),
                      const SizedBox(height: 16),

                      // ── Quick actions ──────────────────────────────────
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            _QuickAction(
                              icon: Icons.add_shopping_cart_rounded,
                              label: s.newSale,
                              color: AppColors.primary,
                              onTap: () => goToTab(1),
                            ),
                            _QuickAction(
                              icon: Icons.add_box_rounded,
                              label: s.addProduct,
                              color: AppColors.secondary,
                              onTap: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => const AddProductSheet(),
                              ),
                            ),
                            _QuickAction(
                              icon: Icons.inventory_2_rounded,
                              label: s.warehouse,
                              color: AppColors.amber,
                              onTap: () => goToTab(2),
                            ),
                            _QuickAction(
                              icon: Icons.history_rounded,
                              label: s.saleHistory,
                              color: AppColors.accent,
                              onTap: () => _openHistory(context),
                            ),
                          ],
                        ),
                      ),

                      // ── Low stock alert ────────────────────────────────
                      if (lowStock > 0) ...[
                        const SizedBox(height: 12),
                        _LowStockBanner(
                          s: s,
                          count: lowStock,
                          onTap: () => goToTab(2),
                        ),
                      ],

                      // ── Sale history ───────────────────────────────────
                      const SizedBox(height: 24),
                      _SectionTitle(
                        title: s.saleHistory,
                        action: s.seeAll,
                        onAction: () => _openHistory(context),
                      ),
                      const SizedBox(height: 8),
                      _RecentSales(
                        s: s,
                        sales: sales,
                        limit: _recentLimit,
                        onNewSale: () => goToTab(1),
                      ),

                      // ── Inventory at a glance ──────────────────────────
                      const SizedBox(height: 24),
                      _SectionTitle(
                        title: s.warehouseOverview,
                        action: s.seeAll,
                        onAction: () => goToTab(2),
                      ),
                      const SizedBox(height: 8),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            _InventoryStat(
                              icon: Icons.inventory_2_rounded,
                              value: st.totalProducts,
                              label: s.totalProducts,
                              color: AppColors.primary,
                            ),
                            _InventoryStat(
                              icon: Icons.category_rounded,
                              value: st.categoryCount,
                              label: s.categories,
                              color: AppColors.secondary,
                            ),
                            _InventoryStat(
                              icon: Icons.business_rounded,
                              value: st.vendorCount,
                              label: s.vendors,
                              color: AppColors.amber,
                            ),
                            _InventoryStat(
                              icon: Icons.warning_amber_rounded,
                              value: st.lowStockCount,
                              label: s.lowStockItems,
                              color: st.lowStockCount > 0
                                  ? AppColors.accent
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Revenue hero card ──────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final AppStrings s;
  final double today;
  final double month;
  final int transactions;
  final List<double> weekly;

  const _RevenueCard({
    required this.s,
    required this.today,
    required this.month,
    required this.transactions,
    required this.weekly,
  });

  @override
  Widget build(BuildContext context) {
    final yesterday = weekly.length == 7 ? weekly[5] : 0.0;
    final change = yesterday > 0 ? (today - yesterday) / yesterday * 100 : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                s.todayRevenue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (change != null) _TrendPill(change: change, s: s),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Formatters.currency(today),
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            s.last7Days,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _WeekBars(values: weekly),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.calendar_month_rounded,
                  label: s.thisMonth,
                  value: Formatters.compact(month),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroStat(
                  icon: Icons.receipt_long_rounded,
                  label: s.transactionsToday,
                  value: Formatters.number(transactions),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final double change;
  final AppStrings s;
  const _TrendPill({required this.change, required this.s});

  @override
  Widget build(BuildContext context) {
    final up = change >= 0;
    return Tooltip(
      message: s.vsYesterday,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 14,
              color: up ? AppColors.primary : AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              '${Formatters.number(change.abs().round())}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: up ? AppColors.primary : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  final List<double> values;
  const _WeekBars({required this.values});

  static const _maxBarHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final peak = values.fold<double>(0, math.max);
    final today = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: peak == 0
                        ? 4
                        : math.max(4, values[i] / peak * _maxBarHeight),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: i == values.length - 1 ? 1 : 0.35,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Formatters.weekdayShort(
                        today.subtract(Duration(days: values.length - 1 - i)),
                      ),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(
                          alpha: i == values.length - 1 ? 1 : 0.7,
                        ),
                        fontWeight: i == values.length - 1
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions ──────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final AppStrings s;
  final int count;
  final VoidCallback onTap;

  const _LowStockBanner({
    required this.s,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      color: Color.alphaBlend(
        AppColors.accent.withValues(alpha: 0.07),
        theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.lowStockBanner(Formatters.number(count)),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                Text(s.tapToReview, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

// ─── Sale history ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class _RecentSales extends StatelessWidget {
  final AppStrings s;
  final AsyncValue<List<SaleModel>> sales;
  final int limit;
  final VoidCallback onNewSale;

  const _RecentSales({
    required this.s,
    required this.sales,
    required this.limit,
    required this.onNewSale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: sales.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${s.error}: $e'),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(s.noSalesYet, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(s.noSalesHint, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onNewSale,
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: Text(s.newSale),
                  ),
                ],
              ),
            );
          }

          final recent = list.take(limit).toList();
          return Column(
            children: [
              for (var i = 0; i < recent.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                SaleTile(
                  sale: recent[i],
                  s: s,
                  onTap: () => showSaleDetails(context, recent[i]),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─── Inventory ──────────────────────────────────────────────────────────────

class _InventoryStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _InventoryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.number(value),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget block(double h, double r) => Container(
      height: h,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
    return Column(children: [block(250, 28), block(110, 20), block(280, 20)]);
  }
}
