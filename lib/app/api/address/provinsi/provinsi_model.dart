class ProvinsModel {
  final String id;
  final String name;

  ProvinsModel({
    required this.id,
    required this.name,
  });

  factory ProvinsModel.fromMap(MapEntry<String, dynamic> e) {
    return ProvinsModel(
      id: e.key,
      name: e.value.toString(),
    );
  }
}
