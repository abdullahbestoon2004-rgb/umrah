import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Semantic buckets every dashboard status maps into. The colors are the
/// exact values already used by `Booking.statusBg/statusColor` and the
/// commission ledger — this widget is the single source of truth for them.
enum StatusKind { pending, positive, negative, neutral }

class StatusChip extends StatelessWidget {
  final StatusKind kind;
  final String label;
  const StatusChip({super.key, required this.kind, required this.label});

  /// Maps a booking's status string ('Pending' | 'Confirmed' | 'Cancelled' |
  /// 'Completed') to its semantic bucket.
  static StatusKind forBooking(String status) {
    switch (status) {
      case 'Confirmed':
        return StatusKind.positive;
      case 'Pending':
        return StatusKind.pending;
      case 'Cancelled':
        return StatusKind.negative;
      default:
        return StatusKind.neutral;
    }
  }

  /// Maps a commission status ('owed' | 'collected' | 'waived').
  static StatusKind forCommission(String status) {
    switch (status) {
      case 'owed':
        return StatusKind.pending;
      case 'collected':
        return StatusKind.positive;
      default:
        return StatusKind.neutral;
    }
  }

  Color get _bg {
    switch (kind) {
      case StatusKind.pending:
        return const Color(0xFFFFF8E8);
      case StatusKind.positive:
        return const Color(0xFFEAF1EC);
      case StatusKind.negative:
        return const Color(0xFFFFF0EE);
      case StatusKind.neutral:
        return const Color(0xFFF2F2F2);
    }
  }

  Color get _fg {
    switch (kind) {
      case StatusKind.pending:
        return const Color(0xFFC9A24B);
      case StatusKind.positive:
        return const Color(0xFF0F5C4D);
      case StatusKind.negative:
        return const Color(0xFFB3452E);
      case StatusKind.neutral:
        return const Color(0xFF8A948C);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.fromSTEB(9, 4, 9, 4),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: AppTheme.sans(10.5, weight: FontWeight.w700, color: _fg),
    ),
  );
}
