class Review {
  final String id;
  final String bookingId;
  final String companyId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.companyId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  factory Review.fromRow(Map<String, dynamic> r) => Review(
        id: r['id'] as String,
        bookingId: r['booking_id'] as String,
        companyId: r['company_id'] as String,
        rating: (r['rating'] ?? 0) as int,
        comment: (r['comment'] ?? '') as String,
        createdAt: DateTime.parse(r['created_at'] as String),
      );
}
