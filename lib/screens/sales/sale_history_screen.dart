import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/soft_card.dart';
import '../../widgets/sale/sale_tile.dart';
import 'sale_detail_sheet.dart';

enum _Period { all, today, week, month }

class SaleHistoryScreen extends ConsumerStatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  ConsumerState<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends ConsumerState<SaleHistoryScreen> {
  _Period _period = _Period.all;

  bool _inPeriod(SaleModel sale) {
    final d = sale.date;
    if (d == null) return _period == _Period.all;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_period) {
      _Period.all => true,
      _Period.today => !d.isBefore(today),
      _Period.week => !d.isBefore(today.subtract(const Duration(days: 6))),
      _Period.month => d.year == now.year && d.month == now.month,
    };
  }

  String _label(_Period p, AppStrings s) => switch (p) {
    _Period.all => s.all,
    _Period.today => s.today,
    _Period.week => s.thisWeek,
    _Period.month => s.thisMonth,
  };

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final sales = ref.watch(salesProvider);

    return Scaffold(
      appBar: AnbarAppBar(title: s.saleHistory),
      body: sales.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_rounded,
              title: s.noSalesYet,
              subtitle: s.noSalesHint,
            );
          }

          final filtered = all.where(_inPeriod).toList();
          final total = filtered.fold<double>(
            0,
            (sum, x) => sum + x.totalAmount,
          );
          final groups = _groupByDay(filtered);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(salesProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _SummaryCard(
                  s: s,
                  total: total,
                  count: filtered.length,
                  periodLabel: _label(_period, s),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final p in _Period.values)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(_label(p, s)),
                            selected: _period == p,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _period = p),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.event_busy_rounded,
                    title: s.noSalesInPeriod,
                  )
                else
                  for (final group in groups) ...[
                    _DayHeader(
                      label: saleDayLabel(group.day, s),
                      total: group.total,
                      count: group.sales.length,
                      s: s,
                    ),
                    const SizedBox(height: 8),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < group.sales.length; i++) ...[
                            if (i > 0) const Divider(height: 1, indent: 56),
                            SaleTile(
                              sale: group.sales[i],
                              s: s,
                              showDay: false,
                              onTap: () =>
                                  showSaleDetails(context, group.sales[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<_DayGroup> _groupByDay(List<SaleModel> sales) {
    final groups = <DateTime, List<SaleModel>>{};
    for (final sale in sales) {
      final d = sale.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      groups.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(sale);
    }
    return groups.entries
        .map(
          (e) => _DayGroup(
            e.key,
            e.value,
            e.value.fold<double>(0, (sum, x) => sum + x.totalAmount),
          ),
        )
        .toList();
  }
}

class _DayGroup {
  final DateTime day;
  final List<SaleModel> sales;
  final double total;
  const _DayGroup(this.day, this.sales, this.total);
}

class _SummaryCard extends StatelessWidget {
  final AppStrings s;
  final double total;
  final int count;
  final String periodLabel;

  const _SummaryCard({
    required this.s,
    required this.total,
    required this.count,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.total} · $periodLabel',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    Formatters.currency(total),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  Formatters.number(count),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  s.transactions,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  final double total;
  final int count;
  final AppStrings s;

  const _DayHeader({
    required this.label,
    required this.total,
    required this.count,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            s.salesCount(Formatters.number(count)),
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            Formatters.currency(total),
            textDirection: TextDirection.ltr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
