/// One row of the sold-products report: a product's sales aggregated
/// over a period.
class SoldProductModel {
  final int productId;
  final String name;
  final String? unitName;
  final int quantity;
  final double total;
  final int saleCount;

  const SoldProductModel({
    required this.productId,
    required this.name,
    this.unitName,
    required this.quantity,
    required this.total,
    required this.saleCount,
  });

  double get averagePrice => quantity == 0 ? 0 : total / quantity;

  factory SoldProductModel.fromMap(Map<String, dynamic> map) =>
      SoldProductModel(
        productId: map['product_id'] as int,
        name: map['product_name'] as String? ?? '#${map['product_id']}',
        unitName: map['unit_name'] as String?,
        quantity: (map['qty'] as num?)?.toInt() ?? 0,
        total: (map['total'] as num?)?.toDouble() ?? 0,
        saleCount: (map['sale_count'] as num?)?.toInt() ?? 0,
      );
}
