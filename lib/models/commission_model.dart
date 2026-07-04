/// A ledger row for what an agency owes the platform on one confirmed
/// booking (opened automatically by the `open_commission` DB trigger).
class Commission {
  final String id;
  final String bookingId;
  final String companyId;
  final String companyName;
  final double amount;
  final String status; // 'owed' | 'collected' | 'waived'
  final DateTime createdAt;

  const Commission({
    required this.id,
    required this.bookingId,
    required this.companyId,
    this.companyName = '',
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Commission.fromRow(Map<String, dynamic> r) {
    final comp = (r['companies'] ?? const {}) as Map<String, dynamic>;
    return Commission(
      id: r['id'] as String,
      bookingId: r['booking_id'] as String,
      companyId: r['company_id'] as String,
      companyName: (comp['name'] ?? '') as String,
      amount: ((r['amount_iqd'] ?? 0) as num).toDouble(),
      status: (r['status'] ?? 'owed') as String,
      createdAt: DateTime.parse(r['created_at'] as String),
    );
  }
}
