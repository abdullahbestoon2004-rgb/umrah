import 'package:flutter/material.dart';
import 'company_model.dart';
import 'offer_model.dart';

/// Details for one traveller collected by the booking flow and stored in the
/// protected `booking_travellers` table.
class PilgrimInfo {
  final String fullName;
  final String localName;
  final String passportNo;
  final DateTime? dateOfBirth;
  final String phone; // lead pilgrim only

  const PilgrimInfo({
    required this.fullName,
    this.localName = '',
    this.passportNo = '',
    this.dateOfBirth,
    this.phone = '',
  });
}

class BookingTraveller {
  final String id;
  final String bookingId;
  final String fullName;
  final String? passportNo;
  final String? passportImagePath;
  final String? selfieImagePath;
  final DateTime? dateOfBirth;
  final String? phone;
  final bool isLead;
  final String? localName;
  final String? gender;
  final String? nationality;
  final DateTime? passportExpiryDate;
  final String? nationalId;
  final String? emergencyContact;
  final String? medicalNotes;
  final String? accessibilityNotes;
  final String documentStatus;
  final String? documentReason;
  final String visaStatus;
  final String? visaReference;
  final String? visaReason;
  final DateTime? visaUpdatedAt;
  final String? transportSeat;

  const BookingTraveller({
    required this.id,
    required this.bookingId,
    required this.fullName,
    this.passportNo,
    this.passportImagePath,
    this.selfieImagePath,
    this.dateOfBirth,
    this.phone,
    this.isLead = false,
    this.localName,
    this.gender,
    this.nationality,
    this.passportExpiryDate,
    this.nationalId,
    this.emergencyContact,
    this.medicalNotes,
    this.accessibilityNotes,
    this.documentStatus = 'missing',
    this.documentReason,
    this.visaStatus = 'not_started',
    this.visaReference,
    this.visaReason,
    this.visaUpdatedAt,
    this.transportSeat,
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
        dateOfBirth: row['date_of_birth'] == null
            ? null
            : DateTime.tryParse(row['date_of_birth'] as String),
        phone: row['phone'] as String?,
        isLead: (row['is_lead'] ?? false) as bool,
        localName: row['local_name'] as String?,
        gender: row['gender'] as String?,
        nationality: row['nationality'] as String?,
        passportExpiryDate: row['passport_expiry_date'] == null
            ? null
            : DateTime.tryParse(row['passport_expiry_date'] as String),
        nationalId: row['national_id'] as String?,
        emergencyContact: row['emergency_contact'] as String?,
        medicalNotes: row['medical_notes'] as String?,
        accessibilityNotes: row['accessibility_notes'] as String?,
        documentStatus: (row['document_status'] ?? 'missing') as String,
        documentReason: row['document_reason'] as String?,
        visaStatus: (row['visa_status'] ?? 'not_started') as String,
        visaReference: row['visa_reference'] as String?,
        visaReason: row['visa_reason'] as String?,
        visaUpdatedAt: row['visa_updated_at'] == null
            ? null
            : DateTime.tryParse(row['visa_updated_at'] as String),
        transportSeat: row['transport_seat'] as String?,
      );
}

class BookingQuote {
  final String offerId;
  final int version;
  final int travellers;
  final int roomOccupancy;
  final int roomCount;
  final double unitPriceIqd;
  final double totalIqd;
  final double amountDueNowIqd;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final String meal;
  final String cancellationPolicy;
  final List<String> acceptedPaymentMethods;

  const BookingQuote({
    required this.offerId,
    required this.version,
    required this.travellers,
    required this.roomOccupancy,
    required this.roomCount,
    required this.unitPriceIqd,
    required this.totalIqd,
    required this.amountDueNowIqd,
    this.departureDate,
    this.returnDate,
    this.meal = '',
    this.cancellationPolicy = '',
    this.acceptedPaymentMethods = const [],
  });

  factory BookingQuote.fromJson(Map<String, dynamic> json) => BookingQuote(
    offerId: (json['offer_id'] ?? '') as String,
    version: ((json['version'] ?? 1) as num).toInt(),
    travellers: ((json['travellers'] ?? 1) as num).toInt(),
    roomOccupancy: ((json['room_occupancy'] ?? 2) as num).toInt(),
    roomCount: ((json['room_count'] ?? 1) as num).toInt(),
    unitPriceIqd: ((json['unit_price_iqd'] ?? 0) as num).toDouble(),
    totalIqd: ((json['total_iqd'] ?? 0) as num).toDouble(),
    amountDueNowIqd: ((json['amount_due_now_iqd'] ?? 0) as num).toDouble(),
    departureDate: json['departure_date'] == null
        ? null
        : DateTime.tryParse(json['departure_date'].toString()),
    returnDate: json['return_date'] == null
        ? null
        : DateTime.tryParse(json['return_date'].toString()),
    meal: (json['meal'] ?? '') as String,
    cancellationPolicy: (json['cancellation_policy'] ?? '') as String,
    acceptedPaymentMethods:
        ((json['accepted_payment_methods'] ?? const []) as List).cast<String>(),
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
  final DateTime? returnDate;
  final bool companyVerified;
  final List<String> documentStatuses;
  final List<String> visaStatuses;
  final int travelers;
  final String status; // 'Pending' | 'Confirmed' | 'Cancelled' | 'Completed'
  final String operationalStage;
  final String paymentStatus;
  final String? statusReason;
  final String? roomLabel;
  final int? roomOccupancy;
  final String? mealPreference;
  final String? contactPhone;
  final String? note;
  final DateTime? expiresAt;
  final String payMethod; // 'cash' | 'card' | 'fib'
  final String ref;
  final double total; // IQD
  final double unitPrice;
  final int roomCount;
  final double amountDueNow;
  final double amountPaid;
  final int quoteVersion;
  final String cancellationPolicySnapshot;
  final double depositIqdSnapshot;
  final bool nonRefundableDepositSnapshot;
  final double refundDue;
  final String refundStatus;

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
    this.returnDate,
    this.companyVerified = false,
    this.documentStatuses = const [],
    this.visaStatuses = const [],
    required this.travelers,
    required this.status,
    String? operationalStage,
    this.paymentStatus = 'unpaid',
    this.statusReason,
    this.roomLabel,
    this.roomOccupancy,
    this.mealPreference,
    this.contactPhone,
    this.note,
    this.expiresAt,
    this.payMethod = 'cash',
    required this.ref,
    required this.total,
    this.unitPrice = 0,
    this.roomCount = 1,
    this.amountDueNow = 0,
    this.amountPaid = 0,
    this.quoteVersion = 1,
    this.cancellationPolicySnapshot = '',
    this.depositIqdSnapshot = 0,
    this.nonRefundableDepositSnapshot = false,
    this.refundDue = 0,
    this.refundStatus = 'none',
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
    returnDate: returnDate,
    companyVerified: companyVerified,
    documentStatuses: documentStatuses,
    visaStatuses: visaStatuses,
    travelers: travelers,
    status: status ?? this.status,
    operationalStage: operationalStage ?? this.operationalStage,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    statusReason: statusReason,
    roomLabel: roomLabel,
    roomOccupancy: roomOccupancy,
    mealPreference: mealPreference,
    contactPhone: contactPhone,
    note: note,
    expiresAt: expiresAt,
    payMethod: payMethod,
    ref: ref,
    total: total,
    unitPrice: unitPrice,
    roomCount: roomCount,
    amountDueNow: amountDueNow,
    amountPaid: amountPaid,
    quoteVersion: quoteVersion,
    cancellationPolicySnapshot: cancellationPolicySnapshot,
    depositIqdSnapshot: depositIqdSnapshot,
    nonRefundableDepositSnapshot: nonRefundableDepositSnapshot,
    refundDue: refundDue,
    refundStatus: refundStatus,
  );

  /// Maps a DB row (with joined packages/companies) into the UI model.
  /// The departure date is encoded in the row's `note` as `dep:YYYY-MM-DD`.
  factory Booking.fromRow(Map<String, dynamic> r) {
    final pkg = r['packages'] is Map
        ? Map<String, dynamic>.from(r['packages'] as Map)
        : const <String, dynamic>{};
    final comp = r['companies'] is Map
        ? Map<String, dynamic>.from(r['companies'] as Map)
        : const <String, dynamic>{};
    final travellerRows = r['booking_travellers'] is List
        ? (r['booking_travellers'] as List)
        : const [];
    final quote = r['quote_snapshot'] is Map
        ? Map<String, dynamic>.from(r['quote_snapshot'] as Map)
        : const <String, dynamic>{};
    final tint = Company.parseTint(comp['tint'] as String?);
    final dark = Color.alphaBlend(Colors.black.withValues(alpha: 0.55), tint);
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
      title: (quote['offer_title'] ?? pkg['title'] ?? '') as String,
      titleAr: (quote['offer_title_ar'] ?? pkg['title_ar']) as String?,
      titleEn: (quote['offer_title_en'] ?? pkg['title_en']) as String?,
      companyName: (quote['company_name'] ?? comp['name'] ?? '') as String,
      companyNameAr: (quote['company_name_ar'] ?? comp['name_ar']) as String?,
      companyNameEn: (quote['company_name_en'] ?? comp['name_en']) as String?,
      gradColors: [tint, dark],
      departureDate: dep,
      returnDate: (r['return_date'] ?? pkg['return_date']) == null
          ? null
          : DateTime.tryParse(
              (r['return_date'] ?? pkg['return_date']).toString(),
            ),
      companyVerified:
          (comp['is_verified'] ?? r['company_verified'] ?? false) == true ||
          (comp['is_verified'] ?? r['company_verified']) == 1,
      documentStatuses: travellerRows
          .map((row) => (row as Map)['document_status']?.toString())
          .whereType<String>()
          .toList(),
      visaStatuses: travellerRows
          .map((row) => (row as Map)['visa_status']?.toString())
          .whereType<String>()
          .toList(),
      travelers: (r['travellers'] ?? 1) as int,
      status: dbStatus[0].toUpperCase() + dbStatus.substring(1),
      operationalStage: (r['operational_stage'] ?? dbStatus) as String,
      paymentStatus: (r['pay_status'] ?? 'unpaid') as String,
      statusReason: r['status_reason'] as String?,
      roomLabel: r['room_label'] as String?,
      roomOccupancy: (r['room_occupancy'] as num?)?.toInt(),
      mealPreference: r['meal_preference'] as String?,
      contactPhone: r['contact_phone'] as String?,
      note: r['note'] as String?,
      expiresAt: r['expires_at'] == null
          ? null
          : DateTime.tryParse(r['expires_at'] as String),
      payMethod: (r['pay_method'] ?? 'cash') as String,
      ref: 'UM-${(r['id'] as String).substring(0, 6).toUpperCase()}',
      total: ((r['total_iqd'] ?? 0) as num).toDouble(),
      unitPrice: ((r['unit_price_iqd'] ?? 0) as num).toDouble(),
      roomCount: ((r['room_count'] ?? 1) as num).toInt(),
      amountDueNow: ((r['amount_due_now_iqd'] ?? r['total_iqd'] ?? 0) as num)
          .toDouble(),
      amountPaid: ((r['amount_paid_iqd'] ?? 0) as num).toDouble(),
      quoteVersion: ((r['quote_version'] ?? 1) as num).toInt(),
      cancellationPolicySnapshot:
          (r['cancellation_policy_snapshot'] ?? '') as String,
      depositIqdSnapshot: ((r['deposit_iqd_snapshot'] ?? 0) as num).toDouble(),
      nonRefundableDepositSnapshot:
          (r['non_refundable_deposit_snapshot'] ?? false) as bool,
      refundDue: ((r['refund_due_iqd'] ?? 0) as num).toDouble(),
      refundStatus: (r['refund_status'] ?? 'none') as String,
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
