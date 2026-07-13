class AgencyDocument {
  final String id;
  final String agencyId;
  final String documentType;
  final String fileName;
  final String status;
  final String? previewUrl;
  final String? adminFeedback;
  final DateTime createdAt;

  const AgencyDocument({
    required this.id,
    required this.agencyId,
    required this.documentType,
    required this.fileName,
    required this.status,
    this.previewUrl,
    this.adminFeedback,
    required this.createdAt,
  });

  factory AgencyDocument.fromRow(
    Map<String, dynamic> row, {
    String? previewUrl,
  }) => AgencyDocument(
    id: row['id'] as String,
    agencyId: row['agency_id'] as String,
    documentType: (row['document_type'] ?? '') as String,
    fileName: (row['file_name'] ?? '') as String,
    status: (row['status'] ?? 'pending') as String,
    previewUrl: previewUrl,
    adminFeedback: row['admin_feedback'] as String?,
    createdAt:
        DateTime.tryParse((row['created_at'] ?? '') as String) ??
        DateTime.now(),
  );
}
