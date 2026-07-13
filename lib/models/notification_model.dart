enum NotificationType {
  welcome,
  promo,
  tripReminder,
  bookingRequested,
  bookingConfirmed,
  bookingCancelled,
  companyReview,
  packageReview,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String? arg; // e.g. offer title for booking notifications
  final DateTime time;
  bool read;

  /// Local-only entries (welcome message, instant feedback on the client's
  /// own actions) have no matching server row, so read/clear on them is a
  /// no-op against the backend rather than an error.
  final bool isRemote;

  AppNotification({
    required this.id,
    required this.type,
    this.arg,
    required this.time,
    this.read = false,
    this.isRemote = false,
  });

  factory AppNotification.fromRow(Map<String, dynamic> r) => AppNotification(
    id: r['id'] as String,
    type: NotificationType.values.firstWhere(
      (v) => v.name == r['type'],
      orElse: () => NotificationType.promo,
    ),
    arg: r['arg'] as String?,
    time: DateTime.parse(r['created_at'] as String),
    read: (r['read'] ?? false) as bool,
    isRemote: true,
  );

  /// Local-only entries are persisted to shared_preferences so their read
  /// state survives app restarts (remote rows keep theirs on the server).
  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'] as String,
    type: NotificationType.values.firstWhere(
      (v) => v.name == j['type'],
      orElse: () => NotificationType.promo,
    ),
    arg: j['arg'] as String?,
    time: DateTime.parse(j['time'] as String),
    read: (j['read'] ?? false) as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'arg': arg,
    'time': time.toIso8601String(),
    'read': read,
  };
}
