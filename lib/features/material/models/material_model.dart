class MaterialModel {
  final int id;
  final String category;
  final String name;
  final String? brand;
  final String? variant;
  final String unit;
  final double? priceEstimate;
  final bool isActive;

  MaterialModel({
    required this.id,
    required this.category,
    required this.name,
    this.brand,
    this.variant,
    required this.unit,
    this.priceEstimate,
    required this.isActive,
  });

  String get displayName {
    final parts = <String>[name];
    if (variant != null && variant!.trim().isNotEmpty) {
      parts.add(variant!.trim());
    }
    return parts.join(' ');
  }

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      category: json['category']?.toString() ?? '-',
      name: json['name']?.toString() ?? 'Tanpa Nama',
      brand: json['brand']?.toString(),
      variant: json['variant']?.toString(),
      unit: json['unit']?.toString() ?? '-',
      priceEstimate: json['price_estimate'] != null
          ? double.tryParse(json['price_estimate'].toString())
          : null,
      isActive: json['is_active'] == true,
    );
  }
}
