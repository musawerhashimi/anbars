class CategoryModel {
  final int? id;
  final String name;

  const CategoryModel({this.id, required this.name});

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel(id: map['id'] as int?, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  CategoryModel copyWith({int? id, String? name}) =>
      CategoryModel(id: id ?? this.id, name: name ?? this.name);
}
