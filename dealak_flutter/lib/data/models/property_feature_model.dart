class PropertyFeatureModel {
  final int id;
  final String name;
  final String? value;

  const PropertyFeatureModel({required this.id, required this.name, this.value});

  factory PropertyFeatureModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeatureModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString(),
    );
  }
}
