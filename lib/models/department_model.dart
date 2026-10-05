class DepartmentModel {
  final int? id;
  final String name;

  const DepartmentModel({this.id, required this.name});

  factory DepartmentModel.fromMap(Map<String, dynamic> map) =>
      DepartmentModel(id: map['id'] as int?, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  DepartmentModel copyWith({int? id, String? name}) =>
      DepartmentModel(id: id ?? this.id, name: name ?? this.name);
}
