import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/booking_model.dart';
import '../models/offer_model.dart';

class TripExportService {
  const TripExportService._();

  static Future<void> shareExcel({
    required Offer offer,
    required List<Booking> bookings,
    required List<BookingTraveller> travellers,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Passengers'];
    if (workbook.sheets.containsKey('Sheet1')) workbook.delete('Sheet1');
    sheet.appendRow(_headers.map(TextCellValue.new).toList());
    for (final traveller in travellers) {
      final booking = _bookingFor(traveller.bookingId, bookings);
      sheet.appendRow(
        _row(traveller, booking).map((value) => TextCellValue(value)).toList(),
      );
    }
    final bytes = workbook.save();
    if (bytes == null) throw StateError('Could not create workbook');
    final name = '${_safeName(offer.title)}-passengers.xlsx';
    await SharePlus.instance.share(
      ShareParams(
        subject: '${offer.title} passenger list',
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            name: name,
          ),
        ],
        fileNameOverrides: [name],
      ),
    );
  }

  static Future<void> sharePdf({
    required Offer offer,
    required List<Booking> bookings,
    required List<BookingTraveller> travellers,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Tawaf passenger manifest',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${_ascii(offer.title)}  |  ${travellers.length} passengers',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: _headers,
            data: [
              for (final traveller in travellers)
                _row(
                  traveller,
                  _bookingFor(traveller.bookingId, bookings),
                ).map(_ascii).toList(),
            ],
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0F5C4D),
            ),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            cellPadding: const pw.EdgeInsets.all(4),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
          ),
        ],
      ),
    );
    final bytes = await document.save();
    final name = '${_safeName(offer.title)}-passengers.pdf';
    await SharePlus.instance.share(
      ShareParams(
        subject: '${offer.title} passenger manifest',
        files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: name)],
        fileNameOverrides: [name],
      ),
    );
  }

  static const _headers = [
    'Booking',
    'Passport name',
    'Local name',
    'Passport',
    'Birth date',
    'Phone',
    'Documents',
    'Visa',
    'Seat',
    'Payment',
  ];

  static List<String> _row(BookingTraveller traveller, Booking? booking) => [
    booking?.ref ?? _shortId(traveller.bookingId),
    traveller.fullName,
    traveller.localName ?? '',
    traveller.passportNo ?? '',
    traveller.dateOfBirth?.toIso8601String().substring(0, 10) ?? '',
    traveller.phone ?? booking?.contactPhone ?? '',
    traveller.documentStatus,
    traveller.visaStatus,
    traveller.transportSeat ?? '',
    booking?.paymentStatus ?? '',
  ];

  static Booking? _bookingFor(String bookingId, List<Booking> bookings) {
    for (final booking in bookings) {
      if (booking.id == bookingId) return booking;
    }
    return null;
  }

  static String _shortId(String value) =>
      value.substring(0, value.length < 6 ? value.length : 6).toUpperCase();

  static String _safeName(String value) {
    final sanitized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return sanitized.isEmpty ? 'tawaf-trip' : sanitized;
  }

  // The built-in PDF font is Latin-only. Preserve official Latin passport
  // names and replace unsupported display-title characters without crashing.
  static String _ascii(String value) => value.runes
      .map(
        (rune) => rune >= 32 && rune <= 126 ? String.fromCharCode(rune) : '?',
      )
      .join();
}
