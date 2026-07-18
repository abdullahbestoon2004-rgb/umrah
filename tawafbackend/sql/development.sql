-- Tawaf development fake data
-- First import production.sql into xyz_tawaf, then import this file.
-- All demo accounts use the password: Demo!2026

SET NAMES utf8mb4;
SET time_zone = '+03:00';
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO users (id, email, password_hash, role, full_name, phone, status, email_verified_at) VALUES
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'agency@tawaf.test', '$2y$12$XqAnl4RMOc5ytk1Sjd0bOurefJCIdQINs5K4hcVQSWj3A0HTZWoTe', 'agency', 'Aso Karim', '+9647501112233', 'active', UTC_TIMESTAMP()),
('cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'client@tawaf.test', '$2y$12$XqAnl4RMOc5ytk1Sjd0bOurefJCIdQINs5K4hcVQSWj3A0HTZWoTe', 'client', 'Shvan Ahmed', '+9647504445566', 'active', UTC_TIMESTAMP()),
('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb1', 'guide@tawaf.test', '$2y$12$XqAnl4RMOc5ytk1Sjd0bOurefJCIdQINs5K4hcVQSWj3A0HTZWoTe', 'agency', 'Dana Hassan', '+9647507778899', 'active', UTC_TIMESTAMP())
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

INSERT INTO companies (
  id, owner_id, name, name_ar, name_en, location, tint, rating, reviews, since,
  about, about_ar, about_en, tags, is_verified, is_promoted, status,
  verification_status, reviewed_by, reviewed_at, first_offer_approved,
  license_number, office_address, phone, whatsapp, office_hours, branches,
  accepted_payment_methods, pilgrims_served, median_response_minutes,
  verification_details, commission_rate
) VALUES (
  '20000000-0000-4000-8000-000000000001',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
  'گەشتیاری نوور', 'شركة نور للسفر', 'Noor Travel', 'Erbil', '#0F5C4D', 4.80, 1, 2009,
  'گەشتێکی ئارام و ڕێکخراو بۆ عومرە.', 'رحلات عمرة منظمة ومريحة.',
  'Organised, comfortable Umrah journeys.', '["Family groups","Licensed","24/7 support"]',
  1, 1, 'active', 'approved', '00000000-0000-4000-8000-000000000001', UTC_TIMESTAMP(), 1,
  'KRG-TR-2048', '100m Street, Erbil', '+9647501112233', '+9647501112233',
  'Sat–Thu 09:00–18:00', '["Erbil","Sulaymaniyah"]', '["cash","fib"]', 2450, 12,
  '["Licensed travel agency","Office inspected","Owner identity verified"]', 0.0500
)
ON DUPLICATE KEY UPDATE name_en = VALUES(name_en), rating = VALUES(rating);

INSERT INTO agency_badges (agency_id, badge_id, assigned_by) VALUES
('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001'),
('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE assigned_by = VALUES(assigned_by);

INSERT INTO agency_staff (id, company_id, user_id, role, permissions, status, invited_by) VALUES
('21000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb1', 'guide', '["operations","documents","announcements"]', 'active', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1')
ON DUPLICATE KEY UPDATE permissions = VALUES(permissions);

INSERT INTO packages (
  id, company_id, title, title_ar, title_en, overview, overview_ar, overview_en,
  price_iqd, original_iqd, days, nights, transport, carrier, acc_stars, hotel,
  hotel_makkah_description, hotel_madinah_description, distance_haram, room,
  room_occupancies, meals, includes, badge, is_published, is_featured,
  lifecycle_status, capacity, seats_reserved, departure_date, return_date,
  package_tier, group_type, season_tag, departure_airport, airline_name,
  flight_type, bus_between_cities, airport_transfers, transport_notes,
  meals_per_day, cancellation_policy, deposit_iqd, non_refundable_deposit,
  deposit_terms, accepted_payment_methods, reviewed_by, reviewed_at
) VALUES (
  '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001',
  'عومرەی زێڕین', 'العمرة الذهبية', 'Golden Umrah',
  'دوازدە ڕۆژ لە مەککە و مەدینە لەگەڵ خزمەتگوزاری تەواو.',
  'اثنا عشر يوماً في مكة والمدينة مع خدمة متكاملة.',
  'Twelve days in Makkah and Madinah with full service.',
  2750000, 3100000, 12, 11, 'plane', 'Iraqi Airways | Erbil International Airport', 5,
  'Swissôtel Makkah | Pullman Zamzam Madina', 'Direct Haram access', 'Near Al-Masjid an-Nabawi',
  '250m to Haram', 'Double, triple, or quad sharing', '[2,3,4]', 'Full board',
  '["Visa","Airport transfers","Ziyarat tours","Guide"]', 'Best value', 1, 1, 'published',
  40, 2, '2026-12-20', '2027-01-01', 'premium', 'group', 'winter', 'EBL', 'Iraqi Airways',
  'direct', 1, 1, 'Air-conditioned coaches between the holy cities.', 3,
  'Free cancellation until 30 days before departure.', 500000, 0,
  'A 500,000 IQD deposit confirms the booking.', '["cash","fib"]',
  '00000000-0000-4000-8000-000000000001', UTC_TIMESTAMP()
)
ON DUPLICATE KEY UPDATE title_en = VALUES(title_en), price_iqd = VALUES(price_iqd);

INSERT INTO itinerary_days (id, package_id, day_no, title, summary) VALUES
('30100000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 1, 'Arrival in Makkah', 'Airport welcome, hotel transfer, and group briefing.'),
('30100000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000001', 2, 'Umrah day', 'Guided Umrah with the group scholar.'),
('30100000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', 8, 'Travel to Madinah', 'Private coach to Madinah and hotel check-in.')
ON DUPLICATE KEY UPDATE summary = VALUES(summary);

INSERT INTO offer_pricing (id, package_id, occupancy_type, price_iqd) VALUES
('30200000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'double', 2750000),
('30200000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000001', 'triple', 2600000),
('30200000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', 'quad', 2450000)
ON DUPLICATE KEY UPDATE price_iqd = VALUES(price_iqd);

INSERT INTO hotels (id, name, name_ar, name_en, description, city, star_rating, photo_urls) VALUES
('30300000-0000-4000-8000-000000000001', 'Swissôtel Makkah', 'سويس أوتيل مكة', 'Swissôtel Makkah', 'Direct access to Abraj Al Bait.', 'makkah', 5, '[]'),
('30300000-0000-4000-8000-000000000002', 'Pullman Zamzam Madina', 'بولمان زمزم المدينة', 'Pullman Zamzam Madina', 'A short walk to the Prophet’s Mosque.', 'madinah', 5, '[]')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO offer_hotels (package_id, hotel_id, city, nights, distance_from_haram_m) VALUES
('30000000-0000-4000-8000-000000000001', '30300000-0000-4000-8000-000000000001', 'makkah', 7, 100),
('30000000-0000-4000-8000-000000000001', '30300000-0000-4000-8000-000000000002', 'madinah', 4, 220)
ON DUPLICATE KEY UPDATE nights = VALUES(nights);

INSERT INTO offer_inclusions (id, package_id, type, included, details, sort_order) VALUES
('30400000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'visa', 1, 'Umrah visa processing included', 0),
('30400000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000001', 'meals', 1, 'Three meals every day', 1),
('30400000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', 'insurance', 0, 'Travel insurance available separately', 2)
ON DUPLICATE KEY UPDATE details = VALUES(details);

INSERT INTO bookings (
  id, package_id, company_id, client_id, travellers, unit_price_iqd, total_iqd,
  commission_rate, commission_iqd, payout_iqd, pay_method, pay_status, status,
  operational_stage, departure_date, contact_phone, room_label, room_occupancy,
  room_count, meal_preference, amount_due_now_iqd, amount_paid_iqd, quote_snapshot,
  cancellation_policy_snapshot, deposit_iqd_snapshot, request_key, accepted_at
) VALUES (
  '40000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001',
  '20000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1',
  2, 2750000, 5500000, 0.0500, 275000, 5225000, 'fib', 'partially_paid', 'confirmed',
  'confirmed', '2026-12-20', '+9647504445566', 'Double room', 2, 1, 'Full board',
  500000, 500000,
  '{"offer_title":"عومرەی زێڕین","offer_title_en":"Golden Umrah","company_name":"گەشتیاری نوور","company_name_en":"Noor Travel"}',
  'Free cancellation until 30 days before departure.', 500000, 'demo-booking-0001', UTC_TIMESTAMP()
)
ON DUPLICATE KEY UPDATE operational_stage = VALUES(operational_stage);

INSERT INTO booking_travellers (id, booking_id, client_id, full_name, local_name, passport_no, date_of_birth, phone, is_lead, nationality, document_status, visa_status) VALUES
('41000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'SHVAN AHMED', 'شڤان ئەحمەد', 'A12345678', '1990-04-12', '+9647504445566', 1, 'Iraqi', 'approved', 'submitted'),
('41000000-0000-4000-8000-000000000002', '40000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'DILAN AHMED', 'دیلان ئەحمەد', 'A87654321', '1993-09-08', NULL, 0, 'Iraqi', 'under_review', 'documents_missing')
ON DUPLICATE KEY UPDATE passport_no = VALUES(passport_no);

INSERT INTO payments (id, booking_id, company_id, client_id, amount_iqd, method, status, provider_reference, idempotency_key, confirmed_at) VALUES
('42000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 500000, 'fib', 'succeeded', 'FIB-DEMO-001', 'fib-demo-001', UTC_TIMESTAMP())
ON DUPLICATE KEY UPDATE status = VALUES(status);

INSERT INTO commissions (id, booking_id, company_id, amount_iqd, status) VALUES
('43000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 275000, 'owed')
ON DUPLICATE KEY UPDATE amount_iqd = VALUES(amount_iqd);

INSERT INTO agency_ledger (id, company_id, booking_id, payment_id, entry_type, amount_iqd, description) VALUES
('44000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', '42000000-0000-4000-8000-000000000001', 'booking_credit', 475000, 'Agency share of the confirmed FIB deposit')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO home_ads (id, company_id, package_id, title, title_ar, title_en, sort_order, is_active, created_by) VALUES
('50000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'عومرەی زێڕین', 'العمرة الذهبية', 'Golden Umrah', 1, 1, '00000000-0000-4000-8000-000000000001')
ON DUPLICATE KEY UPDATE is_active = VALUES(is_active);

INSERT INTO support_messages (id, user_id, email, message, status) VALUES
('60000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'client@tawaf.test', 'Can I update a passport number after booking?', 'open')
ON DUPLICATE KEY UPDATE status = VALUES(status);

INSERT INTO reviews (id, booking_id, company_id, client_id, rating, comment, moderation_status) VALUES
('61000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 5, 'Clear communication and a very helpful team.', 'visible')
ON DUPLICATE KEY UPDATE comment = VALUES(comment);

INSERT INTO notifications (id, user_id, type, arg, `read`) VALUES
('62000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'bookingConfirmed', 'Golden Umrah', 0),
('62000000-0000-4000-8000-000000000002', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'bookingRequested', 'Golden Umrah', 1)
ON DUPLICATE KEY UPDATE arg = VALUES(arg);

INSERT INTO inquiries (id, client_id, agency_id, offer_id, status) VALUES
('63000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', '20000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'open')
ON DUPLICATE KEY UPDATE status = VALUES(status);

INSERT INTO inquiry_messages (id, inquiry_id, sender_id, body) VALUES
('63100000-0000-4000-8000-000000000001', '63000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', 'Is the flight baggage allowance included?'),
('63100000-0000-4000-8000-000000000002', '63000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'Yes, 30kg checked baggage and 7kg cabin baggage are included.')
ON DUPLICATE KEY UPDATE body = VALUES(body);

INSERT INTO trip_announcements (id, package_id, company_id, created_by, title, body, audience) VALUES
('64000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1', 'Pre-departure meeting', 'Please attend the document and luggage briefing at our Erbil office.', 'confirmed')
ON DUPLICATE KEY UPDATE body = VALUES(body);

INSERT INTO trip_rooms (id, package_id, company_id, city, label, capacity, gender_policy) VALUES
('65000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'makkah', 'M-1204', 2, 'family')
ON DUPLICATE KEY UPDATE capacity = VALUES(capacity);

INSERT INTO trip_room_assignments (room_id, traveller_id) VALUES
('65000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000001'),
('65000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000002')
ON DUPLICATE KEY UPDATE room_id = VALUES(room_id);

INSERT INTO trip_transport_segments (id, package_id, company_id, mode, provider, reference_no, departure_place, departure_at, arrival_place, arrival_at, baggage, meeting_point) VALUES
('66000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'flight', 'Iraqi Airways', 'IA-EBL-JED-77', 'Erbil International Airport', '2026-12-20 07:30:00', 'Jeddah King Abdulaziz Airport', '2026-12-20 10:10:00', '30kg checked + 7kg cabin', 'Departure Hall B, desk 12')
ON DUPLICATE KEY UPDATE departure_at = VALUES(departure_at);

INSERT INTO carousel_requests (id, agency_id, package_id, title, requested_days, price_iqd, status) VALUES
('67000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000001', 'Feature Golden Umrah for seven days', 7, 150000, 'pending')
ON DUPLICATE KEY UPDATE status = VALUES(status);

INSERT INTO agency_reports (id, reporter_id, agency_id, reason, details, status) VALUES
('68000000-0000-4000-8000-000000000001', 'cccccccc-cccc-4ccc-8ccc-ccccccccccc1', '20000000-0000-4000-8000-000000000001', 'listing_question', 'Sample report included to demonstrate the moderation inbox.', 'open')
ON DUPLICATE KEY UPDATE details = VALUES(details);

SET FOREIGN_KEY_CHECKS = 1;
