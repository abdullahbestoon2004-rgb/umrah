import 'package:umrah_app/models/booking_model.dart';

void main() {
  final rawJson = [
    {
      "id": "15e3b45b-2ea8-46a0-8a5e-18ab85a070ed",
      "package_id": "325d8fa1-83d8-4e0a-97ca-4e1d97253ea6",
      "company_id": "0946fe68-0a6c-4f7d-a4f0-a035d15b2a6a",
      "client_id": "f80f5827-4976-4d35-83b8-e7f45bdfb9aa",
      "travellers": 2,
      "unit_price_iqd": 140000,
      "total_iqd": 280000,
      "commission_rate": 0.0500,
      "commission_iqd": 14000,
      "payout_iqd": 266000,
      "pay_method": "cash",
      "pay_status": "paid",
      "status": "completed",
      "contact_phone": "07502045634",
      "note": "room:ژووری دوو کەسی\np1:faded | 1996-01-10 | 07502045634\np2:asdf | 1996-01-25",
      "created_at": "2026-07-13T11:52:52.033201+00:00",
      "amount_paid_iqd": 280000,
      "currency": "IQD",
      "operational_stage": "completed",
      "status_reason": null,
      "departure_date": null,
      "room_label": "ژووری دوو کەسی",
      "room_occupancy": 2,
      "expires_at": "2026-07-14T11:52:52.033201+00:00",
      "accepted_at": "2026-07-14T08:18:08.130563+00:00",
      "ready_at": "2026-07-14T14:06:14.628734+00:00",
      "started_at": "2026-07-14T14:06:15.482363+00:00",
      "completed_at": "2026-07-14T14:06:16.568116+00:00",
      "cancelled_at": null,
      "cancelled_by": null,
      "meal_preference": "Breakfast",
      "room_count": 1,
      "amount_due_now_iqd": 280000,
      "quote_version": 1,
      "quote_snapshot": {
        "version": 1,
        "total_iqd": 280000,
        "travellers": 2,
        "unit_price_iqd": 140000,
        "legacy_snapshot": true
      },
      "cancellation_policy_snapshot": null,
      "deposit_iqd_snapshot": 0,
      "non_refundable_deposit_snapshot": false,
      "refund_due_iqd": 0,
      "refund_status": "none",
      "request_key": null,
      "packages": {
        "title": "madinah",
        "title_ar": null,
        "title_en": null,
        "return_date": null
      },
      "companies": {
        "name": "itland",
        "tint": "#3d5a3d",
        "name_ar": null,
        "name_en": "itland",
        "is_verified": true
      },
      "booking_travellers": [
        {"visa_status": "not_started", "document_status": "missing"},
        {"visa_status": "not_started", "document_status": "missing"}
      ]
    },
    {
      "id": "06946783-dbbd-4005-b6d1-250c2449185a",
      "package_id": "1dc3cbbc-b942-4b67-a326-9cf7143b6aac",
      "company_id": "0946fe68-0a6c-4f7d-a4f0-a035d15b2a6a",
      "client_id": "f80f5827-4976-4d35-83b8-e7f45bdfb9aa",
      "travellers": 1,
      "unit_price_iqd": 2000000,
      "total_iqd": 2000000,
      "commission_rate": 0.0500,
      "commission_iqd": 100000,
      "payout_iqd": 1900000,
      "pay_method": "cash",
      "pay_status": "paid",
      "status": "completed",
      "contact_phone": "07502045634",
      "note": "room:ژووری سێ کەسی\np1:ee | 1996-01-01 | 07502045634",
      "created_at": "2026-07-13T09:21:30.267657+00:00",
      "amount_paid_iqd": 2000000,
      "currency": "IQD",
      "operational_stage": "completed",
      "status_reason": null,
      "departure_date": null,
      "room_label": "ژووری سێ کەسی",
      "room_occupancy": 3,
      "expires_at": "2026-07-14T09:21:30.267657+00:00",
      "accepted_at": "2026-07-14T14:06:01.620572+00:00",
      "ready_at": "2026-07-14T14:06:17.41063+00:00",
      "started_at": "2026-07-14T14:06:17.809531+00:00",
      "completed_at": "2026-07-14T14:06:18.185932+00:00",
      "cancelled_at": null,
      "cancelled_by": null,
      "meal_preference": "Breakfast",
      "room_count": 1,
      "amount_due_now_iqd": 2000000,
      "quote_version": 1,
      "quote_snapshot": {
        "version": 1,
        "total_iqd": 2000000,
        "travellers": 1,
        "unit_price_iqd": 2000000,
        "legacy_snapshot": true
      },
      "cancellation_policy_snapshot": null,
      "deposit_iqd_snapshot": 0,
      "non_refundable_deposit_snapshot": false,
      "refund_due_iqd": 0,
      "refund_status": "none",
      "request_key": null,
      "packages": null,
      "companies": {
        "name": "itland",
        "tint": "#3d5a3d",
        "name_ar": null,
        "name_en": "itland",
        "is_verified": true
      },
      "booking_travellers": [
        {"visa_status": "not_started", "document_status": "missing"}
      ]
    }
  ];

  print('Testing mapping of raw json...');
  for (var i = 0; i < rawJson.length; i++) {
    try {
      final b = Booking.fromRow(rawJson[i]);
      print('Row $i mapped successfully: ID = ${b.id}, Title = ${b.title}');
    } catch (e, stack) {
      print('Row $i FAILED with error: $e');
      print(stack);
    }
  }
}
