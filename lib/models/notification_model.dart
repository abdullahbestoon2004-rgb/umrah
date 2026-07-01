enum NotificationType { welcome, promo, tripReminder, bookingConfirmed, bookingCancelled }

class AppNotification {
  final String id;
  final NotificationType type;
  final String? arg; // e.g. offer title for booking notifications
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    this.arg,
    required this.time,
    this.read = false,
  });
}
