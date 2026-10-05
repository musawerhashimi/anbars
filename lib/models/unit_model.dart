class UnitModel {
  final int? id;
  final String name;

  const UnitModel({this.id, required this.name});

  factory UnitModel.fromMap(Map<String, dynamic> map) =>
      UnitModel(id: map['id'] as int?, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  UnitModel copyWith({int? id, String? name}) =>
      UnitModel(id: id ?? this.id, name: name ?? this.name);
}
