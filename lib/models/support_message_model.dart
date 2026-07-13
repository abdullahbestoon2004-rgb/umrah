class SupportMessage {
  final String id;
  final String? email;
  final String message;
  final DateTime createdAt;
  final String status;
  final String? resolutionNote;

  const SupportMessage({
    required this.id,
    this.email,
    required this.message,
    required this.createdAt,
    this.status = 'open',
    this.resolutionNote,
  });

  factory SupportMessage.fromRow(Map<String, dynamic> r) => SupportMessage(
    id: r['id'] as String,
    email: r['email'] as String?,
    message: (r['message'] ?? '') as String,
    createdAt: DateTime.parse(r['created_at'] as String),
    status: (r['status'] ?? 'open') as String,
    resolutionNote: r['resolution_note'] as String?,
  );
}
