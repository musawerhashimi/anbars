import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/anbar_app_bar.dart';
import '../../widgets/common/app_search_bar.dart';
import '../../widgets/common/empty_state.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  bool _showCart = false;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final itemCount = cartNotifier.itemCount;
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AnbarAppBar(
        title: s.sales,
        icon: Icons.point_of_sale_rounded,
        showBack: false,
        actions: [
          if (cart.isNotEmpty)
            AppBarAction(
              icon: Icons.shopping_cart_rounded,
              onTap: () => setState(() => _showCart = !_showCart),
              tooltip: s.cart,
              badge: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
                child: Center(
                  child: Text('$itemCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppSearchBar(
              hint: s.searchProducts,
              onChanged: (q) =>
                  ref.read(productFilterProvider.notifier).setSearch(q),
            ),
          ),
          Expanded(
            child: _showCart
                ? _CartPanel(
                    cart: cart,
                    cartNotifier: cartNotifier,
                    onClose: () => setState(() => _showCart = false),
                    s: s,
                  )
                : products.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (list) {
                      final available =
                          list.where((p) => p.quantity > 0).toList();
                      if (available.isEmpty) {
                        return EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: s.noProductsAvailable,
                          subtitle: s.addProductsFirst,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: available.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ProductTile(
                          product: available[i],
                          cartItem: cart
                              .where((c) => c.product.id == available[i].id)
                              .firstOrNull,
                          onAdd: () => cartNotifier.addProduct(available[i]),
                          s: s,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isNotEmpty && !_showCart
          ? _CheckoutBar(
              total: cartNotifier.total,
              onCheckout: () => setState(() => _showCart = true),
              s: s,
            )
          : null,
    );
  }
}

// ── Product Tile ────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final CartItem? cartItem;
  final VoidCallback onAdd;
  final AppStrings s;

  const _ProductTile(
      {required this.product,
      this.cartItem,
      required this.onAdd,
      required this.s});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inCart = cartItem != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inCart
              ? AppColors.primary.withValues(alpha: 0.4)
              : theme.colorScheme.outline,
          width: inCart ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      Formatters.currency(product.price),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? AppColors.warning.withValues(alpha: 0.12)
                            : AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.quantity} ${product.unitName ?? s.pcs}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: product.isLowStock
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (inCart)
            Text('×${cartItem!.quantity}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: inCart
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded,
                  color: inCart ? Colors.white : AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Panel ──────────────────────────────────────────────────────────────

class _CartPanel extends ConsumerWidget {
  final List<CartItem> cart;
  final CartNotifier cartNotifier;
  final VoidCallback onClose;
  final AppStrings s;

  const _CartPanel(
      {required this.cart,
      required this.cartNotifier,
      required this.onClose,
      required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Text(s.cart, style: theme.textTheme.headlineSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(s.back),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cart.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = cart[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: theme.textTheme.titleMedium),
                          Text(Formatters.currency(item.product.price),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (item.quantity <= 1) {
                              cartNotifier.removeProduct(item.product.id!);
                            } else {
                              cartNotifier.updateQuantity(
                                  item.product.id!, item.quantity - 1);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('${item.quantity}',
                              style: theme.textTheme.titleMedium),
                        ),
                        _QtyButton(
                          icon: Icons.add_rounded,
                          onTap: () => cartNotifier.updateQuantity(
                              item.product.id!, item.quantity + 1),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Formatters.currency(item.subtotal),
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _CompleteSaleBar(
            cart: cart, cartNotifier: cartNotifier, onClose: onClose, s: s),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ── Complete Sale Bar ───────────────────────────────────────────────────────

class _CompleteSaleBar extends ConsumerStatefulWidget {
  final List<CartItem> cart;
  final CartNotifier cartNotifier;
  final VoidCallback onClose;
  final AppStrings s;

  const _CompleteSaleBar(
      {required this.cart,
      required this.cartNotifier,
      required this.onClose,
      required this.s});

  @override
  ConsumerState<_CompleteSaleBar> createState() => _CompleteSaleBarState();
}

class _CompleteSaleBarState extends ConsumerState<_CompleteSaleBar> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final ok =
        await ref.read(salesProvider.notifier).completeSale(widget.cart);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      widget.cartNotifier.clear();
      widget.onClose();
      ref.invalidate(productsProvider);
      ref.invalidate(lowStockCountProvider);
      ref.invalidate(totalProductsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.s.saleSuccess),
          backgroundColor: AppColors.success,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cartNotifier.total;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.s.total,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(Formatters.currency(total),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const Spacer(),
            _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _confirm,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(widget.s.completeSale,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Checkout Bar ────────────────────────────────────────────────────────────

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  final AppStrings s;

  const _CheckoutBar(
      {required this.total, required this.onCheckout, required this.s});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        child: ElevatedButton(
          onPressed: onCheckout,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                '${s.viewCart}  •  ${Formatters.currency(total)}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
