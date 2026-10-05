import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_provider.dart';
import 'vendor_provider.dart';
import 'product_provider.dart';
import 'sale_provider.dart';

class DashboardStats {
  final int totalProducts;
  final int lowStockCount;
  final int categoryCount;
  final int vendorCount;
  final double salesToday;
  final double salesThisMonth;
  final int transactionsToday;

  const DashboardStats({
    required this.totalProducts,
    required this.lowStockCount,
    required this.categoryCount,
    required this.vendorCount,
    required this.salesToday,
    required this.salesThisMonth,
    required this.transactionsToday,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // totalProducts & lowStockCount are sync Providers derived from productsProvider
  // — they update the moment any product is added, edited, deleted, or sold
  final totalProducts = ref.watch(totalProductsProvider);
  final lowStockCount = ref.watch(lowStockCountProvider);

  // The rest are async — wait in parallel
  final results = await Future.wait([
    ref.watch(categoriesProvider.future).then((list) => list.length),
    ref.watch(vendorsProvider.future).then((list) => list.length),
    ref.watch(salesTodayTotalProvider.future),
    ref.watch(salesMonthTotalProvider.future),
    ref.watch(transactionsTodayProvider.future),
  ]);

  return DashboardStats(
    totalProducts: totalProducts,
    lowStockCount: lowStockCount,
    categoryCount: results[0] as int,
    vendorCount: results[1] as int,
    salesToday: results[2] as double,
    salesThisMonth: results[3] as double,
    transactionsToday: results[4] as int,
  );
});
