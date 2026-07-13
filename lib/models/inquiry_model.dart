class InquiryMessage {
  final String id;
  final String senderId;
  final String body;
  final DateTime createdAt;

  const InquiryMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory InquiryMessage.fromRow(Map<String, dynamic> row) => InquiryMessage(
    id: row['id'] as String,
    senderId: row['sender_id'] as String,
    body: (row['body'] ?? '') as String,
    createdAt:
        DateTime.tryParse((row['created_at'] ?? '') as String) ??
        DateTime.now(),
  );
}

class InquiryThread {
  final String id;
  final String clientId;
  final String agencyId;
  final String? offerId;
  final String status;
  final DateTime createdAt;
  final List<InquiryMessage> messages;

  const InquiryThread({
    required this.id,
    required this.clientId,
    required this.agencyId,
    this.offerId,
    required this.status,
    required this.createdAt,
    this.messages = const [],
  });

  InquiryMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  factory InquiryThread.fromRow(Map<String, dynamic> row) {
    final messages =
        ((row['inquiry_messages'] as List?) ?? const [])
            .map((item) => InquiryMessage.fromRow(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return InquiryThread(
      id: row['id'] as String,
      clientId: row['client_id'] as String,
      agencyId: row['agency_id'] as String,
      offerId: row['offer_id'] as String?,
      status: (row['status'] ?? 'open') as String,
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '') as String) ??
          DateTime.now(),
      messages: messages,
    );
  }
}
