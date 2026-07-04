import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/notification_model.dart';
import '../../l10n/generated/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final items = provider.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(t.notificationsTitle, style: AppTheme.serif(26))),
                  if (items.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.ink),
                      color: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (v) {
                        if (v == 'read') provider.markAllNotificationsRead();
                        if (v == 'clear') provider.clearNotifications();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'read', child: Text(t.notificationsMarkAllRead, style: AppTheme.sans(13))),
                        PopupMenuItem(value: 'clear', child: Text(t.notificationsClearAll, style: AppTheme.sans(13, color: AppColors.errorRed))),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.mutedLight),
                        const SizedBox(height: 14),
                        Text(t.notificationsEmptyTitle, style: AppTheme.serif(20)),
                        const SizedBox(height: 6),
                        Text(t.notificationsEmptyBody, style: AppTheme.sans(13, color: AppColors.muted)),
                      ]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _NotificationCard(item: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  const _NotificationCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case NotificationType.welcome: return Icons.celebration_rounded;
      case NotificationType.promo: return Icons.local_offer_rounded;
      case NotificationType.tripReminder: return Icons.flight_takeoff_rounded;
      case NotificationType.bookingRequested: return Icons.schedule_send_rounded;
      case NotificationType.bookingConfirmed: return Icons.check_circle_rounded;
      case NotificationType.bookingCancelled: return Icons.cancel_rounded;
    }
  }

  Color get _tint {
    switch (item.type) {
      case NotificationType.bookingCancelled: return AppColors.errorRed;
      case NotificationType.promo: return AppColors.gold;
      case NotificationType.bookingRequested: return AppColors.gold;
      default: return AppColors.primary;
    }
  }

  String _title(AppLocalizations t) {
    switch (item.type) {
      case NotificationType.welcome: return t.notifWelcomeTitle;
      case NotificationType.promo: return t.notifPromoTitle;
      case NotificationType.tripReminder: return t.notifTripReminderTitle;
      case NotificationType.bookingRequested: return t.notifBookingRequestedTitle;
      case NotificationType.bookingConfirmed: return t.notifBookingConfirmedTitle;
      case NotificationType.bookingCancelled: return t.notifBookingCancelledTitle;
    }
  }

  String _body(AppLocalizations t) {
    final arg = item.arg ?? '';
    switch (item.type) {
      case NotificationType.welcome: return t.notifWelcomeBody;
      case NotificationType.promo: return t.notifPromoBody;
      case NotificationType.tripReminder: return t.notifTripReminderBody(arg);
      case NotificationType.bookingRequested: return t.notifBookingRequestedBody(arg);
      case NotificationType.bookingConfirmed: return t.notifBookingConfirmedBody(arg);
      case NotificationType.bookingCancelled: return t.notifBookingCancelledBody(arg);
    }
  }

  String _timeAgo(AppLocalizations t) {
    final diff = DateTime.now().difference(item.time);
    if (diff.inMinutes < 1) return t.notifJustNow;
    if (diff.inHours < 1) return t.notifMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return t.notifHoursAgo(diff.inHours);
    return t.notifDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.read<AppProvider>().markNotificationRead(item.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.read ? AppColors.surface : const Color(0xFFEFF6F1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.read ? AppColors.border : AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _tint.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon, color: _tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_title(t), style: AppTheme.sans(13.5, weight: FontWeight.w700)),
                      ),
                      if (!item.read)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(_body(t), style: AppTheme.sans(12.5, color: const Color(0xFF62706A)).copyWith(height: 1.5)),
                  const SizedBox(height: 6),
                  Text(_timeAgo(t), style: AppTheme.sans(11, color: AppColors.mutedLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
