import 'project_item_model.dart';

class ProjectModel {
  final int id;
  final String title;
  final String? projectType;
  final double? budgetTarget;
  final String? notes;
  final String status;
  final int? itemsCount;
  final String? createdAt;
  final List<ProjectItemModel> items;

  ProjectModel({
    required this.id,
    required this.title,
    this.projectType,
    this.budgetTarget,
    this.notes,
    required this.status,
    this.itemsCount,
    this.createdAt,
    this.items = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title']?.toString() ?? 'Tanpa Judul',
      projectType: json['project_type']?.toString(),
      budgetTarget: json['budget_target'] != null
          ? double.tryParse(json['budget_target'].toString())
          : null,
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'draft',
      itemsCount: json['items_count'],
      createdAt: json['created_at']?.toString(),
      items: json['items'] is List
          ? (json['items'] as List)
              .map((e) => ProjectItemModel.fromJson(e))
              .toList()
          : [],
    );
  }
}
