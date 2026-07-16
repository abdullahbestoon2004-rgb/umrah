class AgencyLedgerEntry {
  final String id;
  final String? bookingId;
  final String? paymentId;
  final String? payoutId;
  final String type;
  final double amountIqd;
  final String description;
  final DateTime createdAt;

  const AgencyLedgerEntry({
    required this.id,
    this.bookingId,
    this.paymentId,
    this.payoutId,
    required this.type,
    required this.amountIqd,
    this.description = '',
    required this.createdAt,
  });

  factory AgencyLedgerEntry.fromRow(Map<String, dynamic> row) =>
      AgencyLedgerEntry(
        id: row['id'] as String,
        bookingId: row['booking_id'] as String?,
        paymentId: row['payment_id'] as String?,
        payoutId: row['payout_id'] as String?,
        type: (row['entry_type'] ?? '') as String,
        amountIqd: ((row['amount_iqd'] ?? 0) as num).toDouble(),
        description: (row['description'] ?? '') as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

class AgencyPayout {
  final String id;
  final double amountIqd;
  final String method;
  final String reference;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AgencyPayout({
    required this.id,
    required this.amountIqd,
    this.method = '',
    this.reference = '',
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory AgencyPayout.fromRow(Map<String, dynamic> row) => AgencyPayout(
    id: row['id'] as String,
    amountIqd: ((row['amount_iqd'] ?? 0) as num).toDouble(),
    method: (row['method'] ?? '') as String,
    reference: (row['reference'] ?? '') as String,
    status: (row['status'] ?? 'pending') as String,
    createdAt: DateTime.parse(row['created_at'] as String),
    completedAt: row['completed_at'] == null
        ? null
        : DateTime.tryParse(row['completed_at'] as String),
  );
}

class AgencyWallet {
  final double balanceIqd;
  final List<AgencyLedgerEntry> entries;
  final List<AgencyPayout> payouts;

  const AgencyWallet({
    this.balanceIqd = 0,
    this.entries = const [],
    this.payouts = const [],
  });

  double get pendingPayoutIqd => payouts
      .where((payout) => payout.status == 'pending')
      .fold(0, (sum, payout) => sum + payout.amountIqd);
  double get availablePayoutIqd =>
      (balanceIqd - pendingPayoutIqd).clamp(0, double.infinity);
  double get amountOwedToPlatformIqd => balanceIqd < 0 ? -balanceIqd : 0;
}

class TripAnnouncement {
  final String id;
  final String packageId;
  final String companyId;
  final String title;
  final String body;
  final String audience;
  final DateTime createdAt;

  const TripAnnouncement({
    required this.id,
    required this.packageId,
    required this.companyId,
    required this.title,
    required this.body,
    this.audience = 'all',
    required this.createdAt,
  });

  factory TripAnnouncement.fromRow(Map<String, dynamic> row) =>
      TripAnnouncement(
        id: row['id'] as String,
        packageId: row['package_id'] as String,
        companyId: row['company_id'] as String,
        title: (row['title'] ?? '') as String,
        body: (row['body'] ?? '') as String,
        audience: (row['audience'] ?? 'all') as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

class TripRoom {
  final String id;
  final String packageId;
  final String companyId;
  final String city;
  final String label;
  final int capacity;
  final String genderPolicy;
  final int assignedCount;

  const TripRoom({
    required this.id,
    required this.packageId,
    required this.companyId,
    required this.city,
    required this.label,
    required this.capacity,
    this.genderPolicy = 'family',
    this.assignedCount = 0,
  });

  int get remaining => (capacity - assignedCount).clamp(0, capacity);

  factory TripRoom.fromRow(Map<String, dynamic> row) => TripRoom(
    id: row['id'] as String,
    packageId: row['package_id'] as String,
    companyId: row['company_id'] as String,
    city: (row['city'] ?? 'makkah') as String,
    label: (row['label'] ?? '') as String,
    capacity: ((row['capacity'] ?? 1) as num).toInt(),
    genderPolicy: (row['gender_policy'] ?? 'family') as String,
    assignedCount: row['trip_room_assignments'] is List
        ? (row['trip_room_assignments'] as List).length
        : 0,
  );
}

class TripTransportSegment {
  final String id;
  final String packageId;
  final String companyId;
  final String mode;
  final String provider;
  final String referenceNo;
  final String vehicleNo;
  final String driverName;
  final String driverPhone;
  final String guideName;
  final String departurePlace;
  final DateTime? departureAt;
  final String arrivalPlace;
  final DateTime? arrivalAt;
  final String baggage;
  final String meetingPoint;

  const TripTransportSegment({
    required this.id,
    required this.packageId,
    required this.companyId,
    required this.mode,
    this.provider = '',
    this.referenceNo = '',
    this.vehicleNo = '',
    this.driverName = '',
    this.driverPhone = '',
    this.guideName = '',
    this.departurePlace = '',
    this.departureAt,
    this.arrivalPlace = '',
    this.arrivalAt,
    this.baggage = '',
    this.meetingPoint = '',
  });

  factory TripTransportSegment.fromRow(Map<String, dynamic> row) =>
      TripTransportSegment(
        id: row['id'] as String,
        packageId: row['package_id'] as String,
        companyId: row['company_id'] as String,
        mode: (row['mode'] ?? 'bus') as String,
        provider: (row['provider'] ?? '') as String,
        referenceNo: (row['reference_no'] ?? '') as String,
        vehicleNo: (row['vehicle_no'] ?? '') as String,
        driverName: (row['driver_name'] ?? '') as String,
        driverPhone: (row['driver_phone'] ?? '') as String,
        guideName: (row['guide_name'] ?? '') as String,
        departurePlace: (row['departure_place'] ?? '') as String,
        departureAt: row['departure_at'] == null
            ? null
            : DateTime.tryParse(row['departure_at'] as String),
        arrivalPlace: (row['arrival_place'] ?? '') as String,
        arrivalAt: row['arrival_at'] == null
            ? null
            : DateTime.tryParse(row['arrival_at'] as String),
        baggage: (row['baggage'] ?? '') as String,
        meetingPoint: (row['meeting_point'] ?? '') as String,
      );
}

class TravellerDocument {
  final String id;
  final String travellerId;
  final String bookingId;
  final String kind;
  final String storagePath;
  final String status;
  final String rejectionReason;
  final DateTime? expiresOn;
  final DateTime createdAt;

  const TravellerDocument({
    required this.id,
    required this.travellerId,
    required this.bookingId,
    required this.kind,
    required this.storagePath,
    required this.status,
    this.rejectionReason = '',
    this.expiresOn,
    required this.createdAt,
  });

  factory TravellerDocument.fromRow(Map<String, dynamic> row) =>
      TravellerDocument(
        id: row['id'] as String,
        travellerId: row['traveller_id'] as String,
        bookingId: row['booking_id'] as String,
        kind: (row['kind'] ?? 'other') as String,
        storagePath: (row['storage_path'] ?? '') as String,
        status: (row['status'] ?? 'under_review') as String,
        rejectionReason: (row['rejection_reason'] ?? '') as String,
        expiresOn: row['expires_on'] == null
            ? null
            : DateTime.tryParse(row['expires_on'] as String),
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

class AgencyStaffMember {
  final String id;
  final String companyId;
  final String userId;
  final String name;
  final String role;
  final List<String> permissions;
  final String status;

  const AgencyStaffMember({
    required this.id,
    required this.companyId,
    required this.userId,
    this.name = '',
    required this.role,
    this.permissions = const [],
    this.status = 'active',
  });

  factory AgencyStaffMember.fromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] is Map
        ? Map<String, dynamic>.from(row['profiles'] as Map)
        : const <String, dynamic>{};
    return AgencyStaffMember(
      id: row['id'] as String,
      companyId: row['company_id'] as String,
      userId: row['user_id'] as String,
      name: (profile['full_name'] ?? '') as String,
      role: (row['role'] ?? 'support') as String,
      permissions: ((row['permissions'] ?? const []) as List).cast<String>(),
      status: (row['status'] ?? 'active') as String,
    );
  }
}
