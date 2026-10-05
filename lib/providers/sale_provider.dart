import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/sale_service.dart';

final saleServiceProvider = Provider<SaleService>((ref) => SaleService());

// ─── Cart item ───────────────────────────────────────────────────────────────

class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

// ─── Cart state ──────────────────────────────────────────────────────────────

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addProduct(ProductModel product) {
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      final current = updated[idx];
      // Do not exceed available stock
      final newQty = (current.quantity + 1).clamp(1, product.quantity);
      updated[idx] = current.copyWith(quantity: newQty);
      state = updated;
    } else {
      if (product.quantity > 0) {
        state = [...state, CartItem(product: product, quantity: 1)];
      }
    }
  }

  void updateQuantity(int productId, int quantity) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity.clamp(1, item.product.quantity));
      }
      return item;
    }).toList();
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() => state = [];

  double get total => state.fold<double>(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => state.fold<int>(0, (sum, item) => sum + item.quantity);
}

// ─── Sales history ───────────────────────────────────────────────────────────

final salesProvider = AsyncNotifierProvider<SalesNotifier, List<SaleModel>>(SalesNotifier.new);

class SalesNotifier extends AsyncNotifier<List<SaleModel>> {
  @override
  Future<List<SaleModel>> build() => ref.read(saleServiceProvider).getAll();

  Future<bool> completeSale(List<CartItem> cartItems, {String? note}) async {
    if (cartItems.isEmpty) return false;

    final items = cartItems
        .map((c) => SaleItemModel(
              saleId: 0,
              productId: c.product.id!,
              quantity: c.quantity,
              price: c.product.price,
            ))
        .toList();

    final total = cartItems.fold<double>(0.0, (sum, c) => sum + c.subtotal);

    await ref.read(saleServiceProvider).createSale(
          SaleModel(totalAmount: total, note: note),
          items,
        );

    ref.invalidateSelf();
    // Refresh product stock counts and dashboard stats
    ref.invalidate(salesTodayTotalProvider);
    ref.invalidate(salesMonthTotalProvider);
    ref.invalidate(transactionsTodayProvider);
    return true;
  }
}

final saleItemsProvider =
    FutureProvider.family<List<SaleItemModel>, int>((ref, saleId) {
  return ref.read(saleServiceProvider).getItemsForSale(saleId);
});

/// Revenue per day for the last 7 days, oldest first (index 6 = today).
final weeklySalesProvider = Provider<List<double>>((ref) {
  final sales = ref.watch(salesProvider).valueOrNull ?? const <SaleModel>[];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final totals = List<double>.filled(7, 0);
  for (final sale in sales) {
    final d = sale.date;
    if (d == null) continue;
    final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
    if (diff >= 0 && diff < 7) totals[6 - diff] += sale.totalAmount;
  }
  return totals;
});

// ─── Dashboard sales stats ───────────────────────────────────────────────────

final salesTodayTotalProvider = FutureProvider<double>((ref) {
  return ref.read(saleServiceProvider).getTotalSalesToday();
});

final salesMonthTotalProvider = FutureProvider<double>((ref) {
  return ref.read(saleServiceProvider).getTotalSalesThisMonth();
});

final transactionsTodayProvider = FutureProvider<int>((ref) {
  return ref.read(saleServiceProvider).getTransactionCountToday();
});
