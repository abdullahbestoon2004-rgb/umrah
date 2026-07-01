import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String offerId;
  final String title;
  final String companyName;
  final List<Color> gradColors;
  final String date;
  final int travelers;
  final String status;
  final String ref;
  final double total;

  const Booking({
    required this.id,
    required this.offerId,
    required this.title,
    required this.companyName,
    required this.gradColors,
    required this.date,
    required this.travelers,
    required this.status,
    required this.ref,
    required this.total,
  });

  String get totalFmt => '\$${total.round()}';

  Booking copyWith({String? status}) => Booking(
        id: id,
        offerId: offerId,
        title: title,
        companyName: companyName,
        gradColors: gradColors,
        date: date,
        travelers: travelers,
        status: status ?? this.status,
        ref: ref,
        total: total,
      );

  Color get statusBg {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFFEAF1EC);
      case 'Pending':
        return const Color(0xFFFFF8E8);
      case 'Cancelled':
        return const Color(0xFFFFF0EE);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF0F5C4D);
      case 'Pending':
        return const Color(0xFFC9A24B);
      case 'Cancelled':
        return const Color(0xFFB3452E);
      default:
        return const Color(0xFF8A948C);
    }
  }
}
