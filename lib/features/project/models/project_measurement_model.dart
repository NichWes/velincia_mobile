class ProjectMeasurementModel {
  final int id;
  final int projectId;
  final String keyName;
  final double value;
  final String unit;

  ProjectMeasurementModel({
    required this.id,
    required this.projectId,
    required this.keyName,
    required this.value,
    required this.unit,
  });

  factory ProjectMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ProjectMeasurementModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      keyName: json['key']?.toString() ?? '',
      value: double.tryParse(json['value'].toString()) ?? 0,
      unit: json['unit']?.toString() ?? 'cm',
    );
  }
}

class ProjectMeasurementSummary {
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? areaM2;
  final double? wallAreaM2;
  final double? volumeM3;

  ProjectMeasurementSummary({
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.areaM2,
    this.wallAreaM2,
    this.volumeM3,
  });

  factory ProjectMeasurementSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProjectMeasurementSummary();

    double? parse(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return ProjectMeasurementSummary(
      lengthCm: parse(json['length_cm']),
      widthCm: parse(json['width_cm']),
      heightCm: parse(json['height_cm']),
      areaM2: parse(json['area_m2']),
      wallAreaM2: parse(json['wall_area_m2']),
      volumeM3: parse(json['volume_m3']),
    );
  }
}
