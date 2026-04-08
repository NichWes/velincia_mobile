class MaterialModel {
  final int id;
  final String name;
  final String? variant;
  final String? unit;
  final double? priceEstimate;

  MaterialModel({
    required this.id,
    required this.name,
    this.variant,
    this.unit,
    this.priceEstimate,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name']?.toString() ?? 'Tanpa Nama',
      variant: json['variant']?.toString(),
      unit: json['unit']?.toString(),
      priceEstimate: json['price_estimate'] != null
          ? double.tryParse(json['price_estimate'].toString())
          : null,
    );
  }
}
