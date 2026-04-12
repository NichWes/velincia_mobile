class ProjectEstimateModel {
  final EstimateProjectInfo project;
  final EstimateSummary summary;
  final List<EstimatePricedItem> priced;
  final List<EstimateUnpricedItem> unpriced;

  ProjectEstimateModel({
    required this.project,
    required this.summary,
    required this.priced,
    required this.unpriced,
  });

  factory ProjectEstimateModel.fromJson(Map<String, dynamic> json) {
    return ProjectEstimateModel(
      project: EstimateProjectInfo.fromJson(json['project'] ?? {}),
      summary: EstimateSummary.fromJson(json['summary'] ?? {}),
      priced: (json['priced'] as List? ?? [])
          .map((e) => EstimatePricedItem.fromJson(e))
          .toList(),
      unpriced: (json['unpriced'] as List? ?? [])
          .map((e) => EstimateUnpricedItem.fromJson(e))
          .toList(),
    );
  }
}

class EstimateProjectInfo {
  final int id;
  final String title;

  EstimateProjectInfo({
    required this.id,
    required this.title,
  });

  factory EstimateProjectInfo.fromJson(Map<String, dynamic> json) {
    return EstimateProjectInfo(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '-',
    );
  }
}

class EstimateSummary {
  final int totalItems;
  final int pricedItems;
  final int unpricedItems;
  final double totalEstimateNeeded;
  final double totalEstimatePurchased;
  final double progressPercent;

  EstimateSummary({
    required this.totalItems,
    required this.pricedItems,
    required this.unpricedItems,
    required this.totalEstimateNeeded,
    required this.totalEstimatePurchased,
    required this.progressPercent,
  });

  factory EstimateSummary.fromJson(Map<String, dynamic> json) {
    return EstimateSummary(
      totalItems: json['total_items'] ?? 0,
      pricedItems: json['priced_items'] ?? 0,
      unpricedItems: json['unpriced_items'] ?? 0,
      totalEstimateNeeded:
          double.tryParse(json['total_estimate_needed'].toString()) ?? 0,
      totalEstimatePurchased:
          double.tryParse(json['total_estimate_purchased'].toString()) ?? 0,
      progressPercent:
          double.tryParse(json['progress_percent'].toString()) ?? 0,
    );
  }
}

class EstimatePricedItem {
  final int projectItemId;
  final int? materialId;
  final String name;
  final String? unit;
  final int qtyNeeded;
  final int qtyPurchased;
  final double priceEstimate;
  final double subtotalNeeded;
  final double subtotalPurchased;
  final String status;

  EstimatePricedItem({
    required this.projectItemId,
    this.materialId,
    required this.name,
    this.unit,
    required this.qtyNeeded,
    required this.qtyPurchased,
    required this.priceEstimate,
    required this.subtotalNeeded,
    required this.subtotalPurchased,
    required this.status,
  });

  factory EstimatePricedItem.fromJson(Map<String, dynamic> json) {
    return EstimatePricedItem(
      projectItemId: json['project_item_id'] ?? 0,
      materialId: json['material_id'],
      name: json['name']?.toString() ?? '-',
      unit: json['unit']?.toString(),
      qtyNeeded: json['qty_needed'] ?? 0,
      qtyPurchased: json['qty_purchased'] ?? 0,
      priceEstimate: double.tryParse(json['price_estimate'].toString()) ?? 0,
      subtotalNeeded: double.tryParse(json['subtotal_needed'].toString()) ?? 0,
      subtotalPurchased:
          double.tryParse(json['subtotal_purchased'].toString()) ?? 0,
      status: json['status']?.toString() ?? '-',
    );
  }
}

class EstimateUnpricedItem {
  final int projectItemId;
  final int? materialId;
  final String name;
  final String? unit;
  final int qtyNeeded;
  final int qtyPurchased;
  final String status;
  final String? reason;

  EstimateUnpricedItem({
    required this.projectItemId,
    this.materialId,
    required this.name,
    this.unit,
    required this.qtyNeeded,
    required this.qtyPurchased,
    required this.status,
    this.reason,
  });

  factory EstimateUnpricedItem.fromJson(Map<String, dynamic> json) {
    return EstimateUnpricedItem(
      projectItemId: json['project_item_id'] ?? 0,
      materialId: json['material_id'],
      name: json['name']?.toString() ?? '-',
      unit: json['unit']?.toString(),
      qtyNeeded: json['qty_needed'] ?? 0,
      qtyPurchased: json['qty_purchased'] ?? 0,
      status: json['status']?.toString() ?? '-',
      reason: json['reason']?.toString(),
    );
  }
}
