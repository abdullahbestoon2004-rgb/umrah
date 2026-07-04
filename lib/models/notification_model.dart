enum NotificationType {
  welcome, promo, tripReminder, bookingRequested, bookingConfirmed, bookingCancelled
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
        type: NotificationType.values.byName(r['type'] as String),
        arg: r['arg'] as String?,
        time: DateTime.parse(r['created_at'] as String),
        read: (r['read'] ?? false) as bool,
        isRemote: true,
      );
}
