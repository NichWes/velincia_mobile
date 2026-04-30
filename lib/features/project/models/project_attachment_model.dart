class ProjectAttachment {
  final int id;
  final String fileUrl;
  final String fileName;
  final String mimeType;
  final int fileSize;

  ProjectAttachment({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
  });

  factory ProjectAttachment.fromJson(Map<String, dynamic> json) {
    return ProjectAttachment(
      id: json['id'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
    );
  }
}
