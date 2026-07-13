class Review {
  final String id;
  final String bookingId;
  final String companyId;
  final int rating;
  final String comment;
  final String publicReply;
  final DateTime? repliedAt;
  final String moderationStatus;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.companyId,
    required this.rating,
    this.comment = '',
    this.publicReply = '',
    this.repliedAt,
    this.moderationStatus = 'visible',
    required this.createdAt,
  });

  factory Review.fromRow(Map<String, dynamic> r) => Review(
    id: r['id'] as String,
    bookingId: r['booking_id'] as String,
    companyId: r['company_id'] as String,
    rating: (r['rating'] ?? 0) as int,
    comment: (r['comment'] ?? '') as String,
    publicReply: (r['public_reply'] ?? '') as String,
    repliedAt: r['replied_at'] == null
        ? null
        : DateTime.tryParse(r['replied_at'] as String),
    moderationStatus: (r['moderation_status'] ?? 'visible') as String,
    createdAt: DateTime.parse(r['created_at'] as String),
  );
}
