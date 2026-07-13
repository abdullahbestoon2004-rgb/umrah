import 'package:flutter/material.dart';
import 'company_model.dart';
import 'offer_model.dart';

/// Details for one traveller collected by the booking flow and stored in the
/// protected `booking_travellers` table.
class PilgrimInfo {
  final String fullName;
  final String passportNo;
  final DateTime? dateOfBirth;
  final String phone; // lead pilgrim only

  const PilgrimInfo({
    required this.fullName,
    this.passportNo = '',
    this.dateOfBirth,
    this.phone = '',
  });

  String toNoteLine(int index) {
    final dob = dateOfBirth == null
        ? ''
        : dateOfBirth!.toIso8601String().substring(0, 10);
    final parts = [fullName, dob, if (phone.isNotEmpty) phone];
    return 'p$index:${parts.join(' | ')}';
  }
}

class BookingTraveller {
  final String id;
  final String bookingId;
  final String fullName;
  final String? passportNo;
  final String? passportImagePath;
  final String? selfieImagePath;

  const BookingTraveller({
    required this.id,
    required this.bookingId,
    required this.fullName,
    this.passportNo,
    this.passportImagePath,
    this.selfieImagePath,
  });

  bool get passportComplete =>
      (passportNo ?? '').isNotEmpty &&
      (passportImagePath ?? '').isNotEmpty &&
      (selfieImagePath ?? '').isNotEmpty;

  factory BookingTraveller.fromRow(Map<String, dynamic> row) =>
      BookingTraveller(
        id: row['id'] as String,
        bookingId: row['booking_id'] as String,
        fullName: (row['full_name'] ?? '') as String,
        passportNo: row['passport_no'] as String?,
        passportImagePath: row['passport_image_path'] as String?,
        selfieImagePath: row['selfie_image_path'] as String?,
      );
}

class Booking {
  final String id;
  final String offerId;
  final String companyId;
  final String title; // Kurdish (base)
  final String? titleAr;
  final String? titleEn;
  final String companyName;
  final String? companyNameAr;
  final String? companyNameEn;
  final List<Color> gradColors;
  final DateTime? departureDate; // null = to be scheduled
  final int travelers;
  final String status; // 'Pending' | 'Confirmed' | 'Cancelled' | 'Completed'
  final String operationalStage;
  final String paymentStatus;
  final String? statusReason;
  final String? roomLabel;
  final int? roomOccupancy;
  final String? mealPreference;
  final DateTime? expiresAt;
  final String payMethod; // 'cash' | 'card' | 'fib'
  final String ref;
  final double total; // IQD

  Booking({
    required this.id,
    required this.offerId,
    this.companyId = '',
    required this.title,
    this.titleAr,
    this.titleEn,
    required this.companyName,
    this.companyNameAr,
    this.companyNameEn,
    required this.gradColors,
    this.departureDate,
    required this.travelers,
    required this.status,
    String? operationalStage,
    this.paymentStatus = 'unpaid',
    this.statusReason,
    this.roomLabel,
    this.roomOccupancy,
    this.mealPreference,
    this.expiresAt,
    this.payMethod = 'cash',
    required this.ref,
    required this.total,
  }) : operationalStage = operationalStage ?? status.toLowerCase();

  String get totalFmt => fmtIqd(total);

  String titleFor(String lang) {
    if (lang == 'en' && (titleEn ?? '').isNotEmpty) return titleEn!;
    if (lang == 'ar' && (titleAr ?? '').isNotEmpty) return titleAr!;
    return title;
  }

  String companyNameFor(String lang) {
    if (lang == 'en' && (companyNameEn ?? '').isNotEmpty) return companyNameEn!;
    if (lang == 'ar' && (companyNameAr ?? '').isNotEmpty) return companyNameAr!;
    return companyName;
  }

  Booking copyWith({
    String? status,
    String? operationalStage,
    String? paymentStatus,
  }) => Booking(
    id: id,
    offerId: offerId,
    companyId: companyId,
    title: title,
    titleAr: titleAr,
    titleEn: titleEn,
    companyName: companyName,
    companyNameAr: companyNameAr,
    companyNameEn: companyNameEn,
    gradColors: gradColors,
    departureDate: departureDate,
    travelers: travelers,
    status: status ?? this.status,
    operationalStage: operationalStage ?? this.operationalStage,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    statusReason: statusReason,
    roomLabel: roomLabel,
    roomOccupancy: roomOccupancy,
    mealPreference: mealPreference,
    expiresAt: expiresAt,
    payMethod: payMethod,
    ref: ref,
    total: total,
  );

  /// Maps a DB row (with joined packages/companies) into the UI model.
  /// The departure date is encoded in the row's `note` as `dep:YYYY-MM-DD`.
  factory Booking.fromRow(Map<String, dynamic> r) {
    final pkg = (r['packages'] ?? const {}) as Map<String, dynamic>;
    final comp = (r['companies'] ?? const {}) as Map<String, dynamic>;
    final tint = Company.parseTint(comp['tint'] as String?);
    final dark = Color.alphaBlend(Colors.black.withOpacity(0.55), tint);
    DateTime? dep = r['departure_date'] == null
        ? null
        : DateTime.tryParse(r['departure_date'] as String);
    final note = (r['note'] ?? '') as String;
    final m = RegExp(r'dep:(\d{4}-\d{2}-\d{2})').firstMatch(note);
    if (dep == null && m != null) dep = DateTime.tryParse(m.group(1)!);
    final dbStatus = (r['status'] ?? 'pending') as String;
    return Booking(
      id: r['id'] as String,
      offerId: (r['package_id'] ?? '') as String,
      companyId: (r['company_id'] ?? '') as String,
      title: (pkg['title'] ?? '') as String,
      titleAr: pkg['title_ar'] as String?,
      titleEn: pkg['title_en'] as String?,
      companyName: (comp['name'] ?? '') as String,
      companyNameAr: comp['name_ar'] as String?,
      companyNameEn: comp['name_en'] as String?,
      gradColors: [tint, dark],
      departureDate: dep,
      travelers: (r['travellers'] ?? 1) as int,
      status: dbStatus[0].toUpperCase() + dbStatus.substring(1),
      operationalStage: (r['operational_stage'] ?? dbStatus) as String,
      paymentStatus: (r['pay_status'] ?? 'unpaid') as String,
      statusReason: r['status_reason'] as String?,
      roomLabel: r['room_label'] as String?,
      roomOccupancy: (r['room_occupancy'] as num?)?.toInt(),
      mealPreference: r['meal_preference'] as String?,
      expiresAt: r['expires_at'] == null
          ? null
          : DateTime.tryParse(r['expires_at'] as String),
      payMethod: (r['pay_method'] ?? 'cash') as String,
      ref: 'UM-${(r['id'] as String).substring(0, 6).toUpperCase()}',
      total: ((r['total_iqd'] ?? 0) as num).toDouble(),
    );
  }

  Color get statusBg {
    switch (operationalStage) {
      case 'confirmed':
      case 'ready':
      case 'in_progress':
        return const Color(0xFFEAF1EC);
      case 'requested':
      case 'needs_information':
      case 'awaiting_payment':
        return const Color(0xFFFFF8E8);
      case 'cancelled':
      case 'rejected':
      case 'expired':
        return const Color(0xFFFFF0EE);
      default:
        return const Color(0xFFF2F2F2);
    }
  }

  Color get statusColor {
    switch (operationalStage) {
      case 'confirmed':
      case 'ready':
      case 'in_progress':
        return const Color(0xFF0F5C4D);
      case 'requested':
      case 'needs_information':
      case 'awaiting_payment':
        return const Color(0xFFC9A24B);
      case 'cancelled':
      case 'rejected':
      case 'expired':
        return const Color(0xFFB3452E);
      default:
        return const Color(0xFF8A948C);
    }
  }
}
