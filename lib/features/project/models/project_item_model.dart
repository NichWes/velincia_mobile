import 'material_model.dart';

class ProjectItemModel {
  final int id;
  final int? materialId;
  final String? customName;
  final int qtyNeeded;
  final int qtyPurchased;
  final String status;
  final String? notes;
  final MaterialModel? material;

  ProjectItemModel({
    required this.id,
    this.materialId,
    this.customName,
    required this.qtyNeeded,
    required this.qtyPurchased,
    required this.status,
    this.notes,
    this.material,
  });

  String get displayName {
    if (material != null) {
      final variant = material!.variant?.trim();
      if (variant != null && variant.isNotEmpty) {
        return '${material!.name} $variant';
      }
      return material!.name;
    }

    return customName ?? 'Custom Item';
  }

  factory ProjectItemModel.fromJson(Map<String, dynamic> json) {
    return ProjectItemModel(
      id: json['id'],
      materialId: json['material_id'],
      customName: json['custom_name']?.toString(),
      qtyNeeded: json['qty_needed'] ?? 0,
      qtyPurchased: json['qty_purchased'] ?? 0,
      status: json['status']?.toString() ?? 'not_bought',
      notes: json['notes']?.toString(),
      material: json['material'] != null
          ? MaterialModel.fromJson(json['material'])
          : null,
    );
  }
}
