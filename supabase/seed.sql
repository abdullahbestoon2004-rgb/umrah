-- ============================================================================
-- SEED DATA — sample agencies + packages so the app isn't empty on first run.
-- Run AFTER schema.sql.  Optional — delete these rows once real agencies join.
-- ============================================================================
-- NOTE: these companies have no real owner account. To let an agency log in and
-- manage them, set owner_id to that agency's profile id after they register,
-- or just use these as read-only demo content.

-- A throwaway owner profile for demo content (so FKs are satisfied).
-- Replace with a real auth user id if you want to log in as this agency.
insert into profiles (id, role, full_name)
values ('00000000-0000-0000-0000-000000000001', 'agency', 'Demo Agency Owner')
on conflict (id) do nothing;

-- ---------- COMPANIES ----------
insert into companies (id, owner_id, name, name_ar, name_en, location, tint, rating, since, is_verified, is_active) values
('11111111-1111-1111-1111-111111111101','00000000-0000-0000-0000-000000000001',
  'گەشتیاری نوور','شركة النور للسياحة','Noor Travel','هەولێر','#0f5c4d',4.8,2009,true,true),
('11111111-1111-1111-1111-111111111102','00000000-0000-0000-0000-000000000001',
  'کاروانی سەلام','قوافل السلام','Salam Caravans','سلێمانی','#1b5e7a',4.6,2014,true,true),
('11111111-1111-1111-1111-111111111103','00000000-0000-0000-0000-000000000001',
  'گەشتی ئاسمان','رحلات السماء','Sama Trips','دهۆک','#7a4a1b',4.7,2017,true,true);

-- ---------- PACKAGES ----------
insert into packages (id, company_id, title, title_ar, title_en, overview,
  price_iqd, original_iqd, days, nights, transport, carrier, transfer_note,
  acc_stars, hotel, distance_haram, room, meals, includes, badge, is_published) values
('22222222-2222-2222-2222-222222222201','11111111-1111-1111-1111-111111111101',
  'عومرەی زێڕین','عمرة ذهبية','Golden Umrah',
  'گەشتێکی تەواوی عومرە بە مانەوە لە نزیکترین هۆتێلەکانی حەرەم.',
  2750000, 3100000, 12, 11, 'plane', 'Iraqi Airways', 'گواستنەوەی فڕۆکەخانە بۆ هۆتێل',
  5, 'Swissôtel Makkah', '250م بۆ حەرەم', 'ژووری چوارکەسی', 'بەیانی و ئێوارە',
  array['ڤیزا','گواستنەوە','مەکۆی ٥ ئەستێرە','ڕابەری گەشت'], 'باشترین نرخ', true),
('22222222-2222-2222-2222-222222222202','11111111-1111-1111-1111-111111111102',
  'عومرەی ئاسوودە','عمرة مريحة','Comfort Umrah',
  'پاکێجێکی هاوسەنگ بە گواستنەوەی پاس و مەکۆی نزیک.',
  1450000, null, 9, 8, 'bus', 'Deluxe Coach', 'گواستنەوەی هۆتێل بە پاس',
  4, 'Dar Al Eiman', '500م بۆ حەرەم', 'ژووری سێکەسی', 'بەیانی',
  array['ڤیزا','گواستنەوە','مەکۆی ٤ ئەستێرە'], null, true),
('22222222-2222-2222-2222-222222222203','11111111-1111-1111-1111-111111111103',
  'عومرەی تایبەت','عمرة خاصة','Premium Umrah',
  'تایبەت بۆ خێزان، بە ژووری تایبەت و خزمەتگوزاری VIP.',
  3900000, null, 14, 13, 'plane', 'Saudia', 'گواستنەوەی VIP',
  5, 'Fairmont Clock Tower', '٥٠م بۆ حەرەم', 'ژووری دووکەسی', 'هەموو ژەمەکان',
  array['ڤیزا','گواستنەوەی VIP','مەکۆی ٥ ئەستێرە','ڕابەری تایبەت','ئینتەرنێت'], 'تایبەت', true);

-- ---------- ITINERARY (for the first package) ----------
insert into itinerary_days (package_id, day_no, title, summary) values
('22222222-2222-2222-2222-222222222201',1,'گەیشتن بۆ مەککە','وەرگرتن لە فڕۆکەخانە و چوونە هۆتێل، پشوودان.'),
('22222222-2222-2222-2222-222222222201',2,'عومرە','ئەنجامدانی عومرە بە ڕابەری گەشت.'),
('22222222-2222-2222-2222-222222222201',3,'زیارەت','زیارەتی شوێنە پیرۆزەکانی مەککە.'),
('22222222-2222-2222-2222-222222222201',4,'چوون بۆ مەدینە','گواستنەوە بۆ مەدینەی مونەوەرە.'),
('22222222-2222-2222-2222-222222222201',5,'گەڕانەوە','گەڕانەوە بۆ وڵات.');
