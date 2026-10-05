class SaleModel {
  final int? id;
  final double totalAmount;
  final String? note;
  final String? createdAt;
  final List<SaleItemModel> items;

  // Aggregated from sale_items
  final int itemCount;
  final int totalQty;

  const SaleModel({
    this.id,
    required this.totalAmount,
    this.note,
    this.createdAt,
    this.items = const [],
    this.itemCount = 0,
    this.totalQty = 0,
  });

  DateTime? get date =>
      createdAt == null ? null : DateTime.tryParse(createdAt!);

  factory SaleModel.fromMap(Map<String, dynamic> map) => SaleModel(
        id: map['id'] as int?,
        totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
        note: map['note'] as String?,
        createdAt: map['created_at'] as String?,
        itemCount: (map['item_count'] as num?)?.toInt() ?? 0,
        totalQty: (map['total_qty'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'total_amount': totalAmount,
        'note': note,
        'created_at': createdAt,
      };
}

class SaleItemModel {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;

  // Joined fields
  final String? productName;

  const SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
  });

  double get subtotal => quantity * price;

  factory SaleItemModel.fromMap(Map<String, dynamic> map) => SaleItemModel(
        id: map['id'] as int?,
        saleId: map['sale_id'] as int,
        productId: map['product_id'] as int,
        quantity: map['quantity'] as int,
        price: (map['price'] as num).toDouble(),
        productName: map['product_name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };
}
