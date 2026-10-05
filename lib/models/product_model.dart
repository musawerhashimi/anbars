class ProductModel {
  final int? id;
  final String name;
  final int quantity;
  final int initialQuantity;
  final double price;
  final int? unitId;
  final int? categoryId;
  final int? departmentId;
  final int? vendorId;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  // Joined fields (populated via JOIN queries)
  final String? unitName;
  final String? categoryName;
  final String? departmentName;
  final String? vendorName;

  const ProductModel({
    this.id,
    required this.name,
    required this.quantity,
    this.initialQuantity = 0,
    required this.price,
    this.unitId,
    this.categoryId,
    this.departmentId,
    this.vendorId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.unitName,
    this.categoryName,
    this.departmentName,
    this.vendorName,
  });

  bool get isLowStock => quantity <= 5;

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        quantity: map['quantity'] as int? ?? 0,
        initialQuantity: map['initial_quantity'] as int? ?? 0,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        unitId: map['unit_id'] as int?,
        categoryId: map['category_id'] as int?,
        departmentId: map['department_id'] as int?,
        vendorId: map['vendor_id'] as int?,
        description: map['description'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
        unitName: map['unit_name'] as String?,
        categoryName: map['category_name'] as String?,
        departmentName: map['department_name'] as String?,
        vendorName: map['vendor_name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'initial_quantity': initialQuantity,
        'price': price,
        'unit_id': unitId,
        'category_id': categoryId,
        'department_id': departmentId,
        'vendor_id': vendorId,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  ProductModel copyWith({
    int? id,
    String? name,
    int? quantity,
    int? initialQuantity,
    double? price,
    int? unitId,
    int? categoryId,
    int? departmentId,
    int? vendorId,
    String? description,
    String? createdAt,
    String? updatedAt,
    String? unitName,
    String? categoryName,
    String? departmentName,
    String? vendorName,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        initialQuantity: initialQuantity ?? this.initialQuantity,
        price: price ?? this.price,
        unitId: unitId ?? this.unitId,
        categoryId: categoryId ?? this.categoryId,
        departmentId: departmentId ?? this.departmentId,
        vendorId: vendorId ?? this.vendorId,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        unitName: unitName ?? this.unitName,
        categoryName: categoryName ?? this.categoryName,
        departmentName: departmentName ?? this.departmentName,
        vendorName: vendorName ?? this.vendorName,
      );
}
