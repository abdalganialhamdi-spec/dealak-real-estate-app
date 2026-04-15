class PropertyFeatureModel {
  final int id;
  final String name;
  final String? value;

  const PropertyFeatureModel({required this.id, required this.name, this.value});

  factory PropertyFeatureModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeatureModel(id: json['id'], name: json['name'] ?? '', value: json['value']);
  }
}
