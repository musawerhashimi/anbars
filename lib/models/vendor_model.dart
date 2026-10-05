class VendorModel {
  final int? id;
  final String name;
  final String? contactInfo;

  const VendorModel({this.id, required this.name, this.contactInfo});

  factory VendorModel.fromMap(Map<String, dynamic> map) => VendorModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        contactInfo: map['contact_info'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contact_info': contactInfo,
      };

  VendorModel copyWith({int? id, String? name, String? contactInfo}) => VendorModel(
        id: id ?? this.id,
        name: name ?? this.name,
        contactInfo: contactInfo ?? this.contactInfo,
      );
}
