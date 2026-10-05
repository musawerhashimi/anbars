import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../widgets/common/stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final user = ref.watch(userProvider).valueOrNull;
    final s = ref.watch(stringsProvider);
    final now = DateTime.now();

    final greeting = now.hour < 12
        ? s.goodMorning
        : now.hour < 17
            ? s.goodAfternoon
            : s.goodEvening;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          AnbarHomeAppBar(
            greeting: greeting,
            username: user?.username ?? s.manager,
            dateLabel: Formatters.longDate(now),
            lowStockCount: ref.watch(lowStockCountProvider),
          ),

          // ── Body ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                stats.when(
                  loading: () => const _DashboardSkeleton(),
                  error: (e, _) => Center(child: Text('${s.error}: $e')),
                  data: (st) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Warehouse Overview ─────────────────────────────
                      _SectionHeader(
                        title: s.warehouseOverview,
                        icon: Icons.warehouse_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          StatCard(
                            label: s.totalProducts,
                            value: '${st.totalProducts}',
                            icon: Icons.inventory_2_rounded,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            label: s.lowStockItems,
                            value: '${st.lowStockCount}',
                            icon: Icons.warning_amber_rounded,
                            color: st.lowStockCount > 0
                                ? AppColors.warning
                                : AppColors.success,
                            subtitle: st.lowStockCount > 0 ? s.alert : s.good,
                          ),
                          StatCard(
                            label: s.categories,
                            value: '${st.categoryCount}',
                            icon: Icons.category_rounded,
                            color: AppColors.blue,
                          ),
                          StatCard(
                            label: s.vendors,
                            value: '${st.vendorCount}',
                            icon: Icons.business_rounded,
                            color: AppColors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Sales Overview ─────────────────────────────────
                      _SectionHeader(
                        title: s.salesOverview,
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.amber,
                      ),
                      const SizedBox(height: 12),
                      _SalesSummaryCard(
                        s: s,
                        todayTotal: st.salesToday,
                        monthTotal: st.salesThisMonth,
                        transactions: st.transactionsToday,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: s.salesThisMonth,
                              value: Formatters.compact(st.salesThisMonth),
                              icon: Icons.calendar_month_rounded,
                              color: AppColors.green,
                              subtitle: Formatters.month(now),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: s.transactionsToday,
                              value: '${st.transactionsToday}',
                              icon: Icons.receipt_long_rounded,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

class _SalesSummaryCard extends StatelessWidget {
  final AppStrings s;
  final double todayTotal;
  final double monthTotal;
  final int transactions;

  const _SalesSummaryCard({
    required this.s,
    required this.todayTotal,
    required this.monthTotal,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(s.todayRevenue,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(todayTotal),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                  label: s.thisMonth,
                  value: Formatters.compact(monthTotal),
                  icon: Icons.trending_up_rounded),
              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _MiniStat(
                  label: s.transactions,
                  value: '$transactions',
                  icon: Icons.receipt_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (_) => Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
