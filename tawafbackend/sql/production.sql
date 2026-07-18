-- Tawaf MySQL 8 / MariaDB 10.6 production schema
-- Business tables are empty. One forced-password-change administrator and
-- the built-in badge/settings reference rows are inserted so the dashboard
-- can be accessed immediately after import.

SET NAMES utf8mb4;
SET time_zone = '+03:00';
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('client','agency','admin') NOT NULL DEFAULT 'client',
  full_name VARCHAR(190) NOT NULL DEFAULT '',
  phone VARCHAR(50) NOT NULL DEFAULT '',
  status ENUM('active','suspended','deleted') NOT NULL DEFAULT 'active',
  marketing_emails TINYINT(1) NOT NULL DEFAULT 1,
  share_activity TINYINT(1) NOT NULL DEFAULT 0,
  preferred_pay_method ENUM('cash','card','fib') NOT NULL DEFAULT 'cash',
  two_factor_enabled TINYINT(1) NOT NULL DEFAULT 0,
  force_password_change TINYINT(1) NOT NULL DEFAULT 0,
  passport_photo_url VARCHAR(500) NULL,
  selfie_photo_url VARCHAR(500) NULL,
  identity_status ENUM('not_submitted','under_review','approved','rejected') NOT NULL DEFAULT 'not_submitted',
  identity_reason TEXT NULL,
  email_verified_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX users_role_status_idx (role, status),
  INDEX users_created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_sessions (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  device_label VARCHAR(120) NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  last_used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT auth_sessions_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX auth_sessions_user_idx (user_id, expires_at),
  INDEX auth_sessions_expiry_idx (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_resets (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  code_hash CHAR(64) NOT NULL,
  attempts SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT password_resets_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX password_resets_user_idx (user_id, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rate_limits (
  id CHAR(36) PRIMARY KEY,
  action_name VARCHAR(50) NOT NULL,
  key_hash CHAR(64) NOT NULL,
  attempts SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY rate_limits_action_key (action_name, key_hash),
  INDEX rate_limits_expiry_idx (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS companies (
  id CHAR(36) PRIMARY KEY,
  owner_id CHAR(36) NOT NULL,
  name VARCHAR(190) NOT NULL,
  name_ar VARCHAR(190) NULL,
  name_en VARCHAR(190) NULL,
  location VARCHAR(190) NOT NULL DEFAULT '',
  logo_url VARCHAR(500) NULL,
  banner_url VARCHAR(500) NULL,
  tint VARCHAR(20) NOT NULL DEFAULT '#0F5C4D',
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  reviews INT UNSIGNED NOT NULL DEFAULT 0,
  since SMALLINT UNSIGNED NULL,
  about TEXT NULL,
  about_ar TEXT NULL,
  about_en TEXT NULL,
  tags LONGTEXT NULL,
  is_verified TINYINT(1) NOT NULL DEFAULT 0,
  is_promoted TINYINT(1) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  status ENUM('pending','active','suspended','rejected') NOT NULL DEFAULT 'pending',
  verification_status ENUM('draft','pending','approved','rejected','needs_changes') NOT NULL DEFAULT 'draft',
  verification_reason TEXT NULL,
  submitted_at DATETIME NULL,
  reviewed_at DATETIME NULL,
  reviewed_by CHAR(36) NULL,
  first_offer_approved TINYINT(1) NOT NULL DEFAULT 0,
  license_number VARCHAR(120) NULL,
  office_address VARCHAR(255) NULL,
  phone VARCHAR(50) NULL,
  whatsapp VARCHAR(50) NULL,
  office_hours VARCHAR(190) NULL,
  branches LONGTEXT NULL,
  gallery_urls LONGTEXT NULL,
  intro_video_url VARCHAR(500) NULL,
  cancellation_policy TEXT NULL,
  cancellation_policy_ar TEXT NULL,
  cancellation_policy_en TEXT NULL,
  accepted_payment_methods LONGTEXT NULL,
  pilgrims_served INT UNSIGNED NOT NULL DEFAULT 0,
  median_response_minutes INT UNSIGNED NULL,
  verification_details LONGTEXT NULL,
  commission_rate DECIMAL(5,4) NOT NULL DEFAULT 0.0500,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT companies_owner_fk FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT companies_reviewer_fk FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY companies_owner_unique (owner_id),
  INDEX companies_public_idx (is_active, is_verified, rating),
  INDEX companies_review_idx (verification_status, submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_status_history (
  id CHAR(36) PRIMARY KEY,
  agency_id CHAR(36) NOT NULL,
  old_status VARCHAR(40) NULL,
  new_status VARCHAR(40) NOT NULL,
  reason TEXT NULL,
  changed_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT agency_status_company_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT agency_status_user_fk FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX agency_status_history_idx (agency_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_documents (
  id CHAR(36) PRIMARY KEY,
  agency_id CHAR(36) NOT NULL,
  document_type VARCHAR(80) NOT NULL,
  storage_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NULL,
  file_size INT UNSIGNED NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  admin_feedback TEXT NULL,
  reviewed_by CHAR(36) NULL,
  reviewed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT agency_documents_company_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT agency_documents_reviewer_fk FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX agency_documents_review_idx (agency_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS badges (
  id CHAR(36) PRIMARY KEY,
  badge_key VARCHAR(80) NOT NULL UNIQUE,
  name_ku VARCHAR(120) NOT NULL,
  name_ar VARCHAR(120) NOT NULL,
  name_en VARCHAR(120) NOT NULL,
  icon VARCHAR(80) NOT NULL DEFAULT 'verified',
  type ENUM('auto','manual') NOT NULL DEFAULT 'manual',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_badges (
  agency_id CHAR(36) NOT NULL,
  badge_id CHAR(36) NOT NULL,
  assigned_by CHAR(36) NULL,
  assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (agency_id, badge_id),
  CONSTRAINT agency_badges_company_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT agency_badges_badge_fk FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE,
  CONSTRAINT agency_badges_user_fk FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_reports (
  id CHAR(36) PRIMARY KEY,
  reporter_id CHAR(36) NOT NULL,
  agency_id CHAR(36) NOT NULL,
  reason VARCHAR(120) NOT NULL,
  details TEXT NULL,
  status ENUM('open','reviewing','resolved','dismissed') NOT NULL DEFAULT 'open',
  resolution_note TEXT NULL,
  resolved_by CHAR(36) NULL,
  resolved_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT agency_reports_reporter_fk FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT agency_reports_company_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT agency_reports_resolver_fk FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX agency_reports_status_idx (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS packages (
  id CHAR(36) PRIMARY KEY,
  company_id CHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  title_ar VARCHAR(255) NULL,
  title_en VARCHAR(255) NULL,
  overview TEXT NULL,
  overview_ar TEXT NULL,
  overview_en TEXT NULL,
  price_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  original_iqd BIGINT UNSIGNED NULL,
  days SMALLINT UNSIGNED NOT NULL DEFAULT 7,
  nights SMALLINT UNSIGNED NOT NULL DEFAULT 6,
  transport ENUM('plane','bus') NOT NULL DEFAULT 'plane',
  carrier VARCHAR(255) NULL,
  transfer_note TEXT NULL,
  acc_stars TINYINT UNSIGNED NOT NULL DEFAULT 3,
  hotel TEXT NULL,
  hotel_makkah_description TEXT NULL,
  hotel_madinah_description TEXT NULL,
  distance_haram VARCHAR(190) NULL,
  room VARCHAR(190) NULL,
  room_occupancies LONGTEXT NULL,
  meals VARCHAR(190) NULL,
  includes LONGTEXT NULL,
  badge VARCHAR(120) NULL,
  image_url VARCHAR(500) NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  is_featured TINYINT(1) NOT NULL DEFAULT 0,
  lifecycle_status ENUM('draft','pending_review','published','needs_changes','paused','sold_out','archived') NOT NULL DEFAULT 'draft',
  review_reason TEXT NULL,
  capacity INT UNSIGNED NULL,
  seats_reserved INT UNSIGNED NOT NULL DEFAULT 0,
  departure_date DATE NULL,
  return_date DATE NULL,
  submitted_at DATETIME NULL,
  reviewed_at DATETIME NULL,
  reviewed_by CHAR(36) NULL,
  package_tier VARCHAR(50) NOT NULL DEFAULT 'standard',
  group_type VARCHAR(50) NOT NULL DEFAULT 'group',
  season_tag VARCHAR(50) NOT NULL DEFAULT 'regular',
  departure_airport VARCHAR(190) NULL,
  airline_name VARCHAR(190) NULL,
  airline_logo_url VARCHAR(500) NULL,
  flight_type VARCHAR(80) NULL,
  bus_between_cities TINYINT(1) NOT NULL DEFAULT 0,
  airport_transfers TINYINT(1) NOT NULL DEFAULT 0,
  transport_notes TEXT NULL,
  meals_per_day TINYINT UNSIGNED NULL,
  video_url VARCHAR(500) NULL,
  cancellation_policy TEXT NULL,
  cancellation_policy_ar TEXT NULL,
  cancellation_policy_en TEXT NULL,
  deposit_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  non_refundable_deposit TINYINT(1) NOT NULL DEFAULT 0,
  deposit_terms TEXT NULL,
  deposit_terms_ar TEXT NULL,
  deposit_terms_en TEXT NULL,
  accepted_payment_methods LONGTEXT NULL,
  force_unpublish_reason TEXT NULL,
  commission_rate DECIMAL(5,4) NULL,
  content_version INT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT packages_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT packages_reviewer_fk FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX packages_public_idx (is_published, departure_date, price_iqd),
  INDEX packages_company_idx (company_id, lifecycle_status),
  INDEX packages_review_idx (lifecycle_status, submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS itinerary_days (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  day_no SMALLINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  title_ar VARCHAR(255) NULL,
  title_en VARCHAR(255) NULL,
  summary TEXT NULL,
  summary_ar TEXT NULL,
  summary_en TEXT NULL,
  CONSTRAINT itinerary_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  UNIQUE KEY itinerary_package_day_unique (package_id, day_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS offer_pricing (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  occupancy_type ENUM('single','double','triple','quad','quintuple') NOT NULL,
  price_iqd BIGINT UNSIGNED NOT NULL,
  price_usd DECIMAL(12,2) NULL,
  CONSTRAINT offer_pricing_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  UNIQUE KEY offer_pricing_unique (package_id, occupancy_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hotels (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  name_ar VARCHAR(190) NULL,
  name_en VARCHAR(190) NULL,
  description TEXT NULL,
  description_ar TEXT NULL,
  description_en TEXT NULL,
  city ENUM('makkah','madinah') NOT NULL,
  star_rating TINYINT UNSIGNED NOT NULL DEFAULT 3,
  photo_urls LONGTEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS offer_hotels (
  package_id CHAR(36) NOT NULL,
  hotel_id CHAR(36) NOT NULL,
  city ENUM('makkah','madinah') NOT NULL,
  nights SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  distance_from_haram_m INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (package_id, hotel_id),
  CONSTRAINT offer_hotels_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  CONSTRAINT offer_hotels_hotel_fk FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS offer_inclusions (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  type VARCHAR(80) NOT NULL,
  included TINYINT(1) NOT NULL DEFAULT 1,
  details TEXT NULL,
  details_ar TEXT NULL,
  details_en TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  CONSTRAINT offer_inclusions_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  INDEX offer_inclusions_idx (package_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS offer_media (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  media_type ENUM('photo','video') NOT NULL DEFAULT 'photo',
  url VARCHAR(500) NOT NULL,
  alt_text VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT offer_media_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  INDEX offer_media_idx (package_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bookings (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  client_id CHAR(36) NOT NULL,
  travellers SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price_iqd BIGINT UNSIGNED NOT NULL,
  total_iqd BIGINT UNSIGNED NOT NULL,
  commission_rate DECIMAL(5,4) NOT NULL DEFAULT 0.0500,
  commission_iqd BIGINT UNSIGNED NOT NULL,
  payout_iqd BIGINT UNSIGNED NOT NULL,
  pay_method ENUM('cash','card','fib') NOT NULL,
  pay_status ENUM('unpaid','partially_paid','paid','failed','refunded') NOT NULL DEFAULT 'unpaid',
  status ENUM('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'pending',
  operational_stage ENUM('requested','needs_information','awaiting_payment','confirmed','ready','in_progress','completed','cancelled','rejected','expired') NOT NULL DEFAULT 'requested',
  status_reason TEXT NULL,
  departure_date DATE NULL,
  contact_phone VARCHAR(50) NULL,
  note TEXT NULL,
  room_label VARCHAR(100) NULL,
  room_occupancy TINYINT UNSIGNED NULL,
  room_count SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  meal_preference VARCHAR(100) NULL,
  expires_at DATETIME NULL,
  accepted_at DATETIME NULL,
  ready_at DATETIME NULL,
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  cancelled_at DATETIME NULL,
  cancelled_by CHAR(36) NULL,
  amount_due_now_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  amount_paid_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'IQD',
  quote_version INT UNSIGNED NOT NULL DEFAULT 1,
  quote_snapshot LONGTEXT NULL,
  cancellation_policy_snapshot TEXT NULL,
  deposit_iqd_snapshot BIGINT UNSIGNED NOT NULL DEFAULT 0,
  non_refundable_deposit_snapshot TINYINT(1) NOT NULL DEFAULT 0,
  refund_due_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  refund_status ENUM('none','pending','completed','failed') NOT NULL DEFAULT 'none',
  request_key VARCHAR(120) NULL,
  active_booking_guard TINYINT GENERATED ALWAYS AS (
    IF(
      operational_stage IN ('requested','needs_information','awaiting_payment','confirmed','ready','in_progress')
      AND refund_status <> 'completed',
      1,
      NULL
    )
  ) STORED,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT bookings_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE RESTRICT,
  CONSTRAINT bookings_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT,
  CONSTRAINT bookings_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE RESTRICT,
  CONSTRAINT bookings_cancelled_by_fk FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY bookings_request_unique (client_id, request_key),
  INDEX bookings_client_idx (client_id, created_at),
  INDEX bookings_company_idx (company_id, operational_stage),
  INDEX bookings_package_idx (package_id, operational_stage),
  UNIQUE KEY bookings_one_active_per_client (client_id, active_booking_guard)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS booking_travellers (
  id CHAR(36) PRIMARY KEY,
  booking_id CHAR(36) NOT NULL,
  client_id CHAR(36) NOT NULL,
  full_name VARCHAR(190) NOT NULL,
  local_name VARCHAR(190) NULL,
  passport_no VARCHAR(80) NULL,
  passport_image_path VARCHAR(500) NULL,
  selfie_image_path VARCHAR(500) NULL,
  date_of_birth DATE NULL,
  phone VARCHAR(50) NULL,
  is_lead TINYINT(1) NOT NULL DEFAULT 0,
  gender VARCHAR(30) NULL,
  nationality VARCHAR(100) NULL,
  passport_expiry_date DATE NULL,
  national_id VARCHAR(100) NULL,
  emergency_contact VARCHAR(190) NULL,
  medical_notes TEXT NULL,
  accessibility_notes TEXT NULL,
  document_status ENUM('missing','uploaded','under_review','approved','rejected') NOT NULL DEFAULT 'missing',
  document_reason TEXT NULL,
  visa_status ENUM('not_started','documents_missing','ready_to_apply','submitted','under_review','approved','rejected') NOT NULL DEFAULT 'not_started',
  visa_reference VARCHAR(190) NULL,
  visa_reason TEXT NULL,
  visa_updated_at DATETIME NULL,
  transport_seat VARCHAR(50) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT travellers_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT travellers_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX travellers_booking_idx (booking_id, is_lead)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS saved_offers (
  client_id CHAR(36) NOT NULL,
  package_id CHAR(36) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (client_id, package_id),
  CONSTRAINT saved_offers_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT saved_offers_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payment_cards (
  id CHAR(36) PRIMARY KEY,
  client_id CHAR(36) NOT NULL,
  provider_token VARCHAR(255) NOT NULL,
  brand VARCHAR(40) NULL,
  last4 CHAR(4) NULL,
  expiry_month TINYINT UNSIGNED NULL,
  expiry_year SMALLINT UNSIGNED NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT payment_cards_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX payment_cards_client_idx (client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notifications (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  type VARCHAR(80) NOT NULL,
  arg VARCHAR(255) NULL,
  `read` TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT notifications_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX notifications_user_idx (user_id, `read`, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS home_ads (
  id CHAR(36) PRIMARY KEY,
  company_id CHAR(36) NULL,
  package_id CHAR(36) NULL,
  title VARCHAR(255) NOT NULL,
  title_ar VARCHAR(255) NULL,
  title_en VARCHAR(255) NULL,
  image_url VARCHAR(500) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  created_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT home_ads_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
  CONSTRAINT home_ads_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE SET NULL,
  CONSTRAINT home_ads_user_fk FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX home_ads_active_idx (is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS commissions (
  id CHAR(36) PRIMARY KEY,
  booking_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  amount_iqd BIGINT UNSIGNED NOT NULL,
  status ENUM('owed','collected','waived') NOT NULL DEFAULT 'owed',
  collected_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT commissions_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT commissions_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  UNIQUE KEY commissions_booking_unique (booking_id),
  INDEX commissions_status_idx (company_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payments (
  id CHAR(36) PRIMARY KEY,
  booking_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  client_id CHAR(36) NOT NULL,
  amount_iqd BIGINT UNSIGNED NOT NULL,
  refunded_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  method ENUM('cash','card','fib') NOT NULL,
  status ENUM('initiated','succeeded','failed','refunded') NOT NULL DEFAULT 'initiated',
  provider_reference VARCHAR(255) NULL,
  idempotency_key VARCHAR(190) NULL UNIQUE,
  failure_reason TEXT NULL,
  metadata LONGTEXT NULL,
  confirmed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT payments_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE RESTRICT,
  CONSTRAINT payments_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT,
  CONSTRAINT payments_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX payments_booking_idx (booking_id),
  INDEX payments_provider_idx (provider_reference),
  INDEX payments_status_idx (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payouts (
  id CHAR(36) PRIMARY KEY,
  company_id CHAR(36) NOT NULL,
  amount_iqd BIGINT UNSIGNED NOT NULL,
  method VARCHAR(80) NULL,
  reference VARCHAR(190) NULL,
  status ENUM('pending','completed','failed') NOT NULL DEFAULT 'pending',
  period_start DATE NULL,
  period_end DATE NULL,
  created_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  CONSTRAINT payouts_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT,
  CONSTRAINT payouts_user_fk FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX payouts_company_idx (company_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_ledger (
  id CHAR(36) PRIMARY KEY,
  company_id CHAR(36) NOT NULL,
  booking_id CHAR(36) NULL,
  payment_id CHAR(36) NULL,
  payout_id CHAR(36) NULL,
  entry_type ENUM('booking_credit','cash_commission_debit','payout','refund_reversal','adjustment') NOT NULL,
  amount_iqd BIGINT NOT NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT agency_ledger_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT,
  CONSTRAINT agency_ledger_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  CONSTRAINT agency_ledger_payment_fk FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL,
  CONSTRAINT agency_ledger_payout_fk FOREIGN KEY (payout_id) REFERENCES payouts(id) ON DELETE SET NULL,
  INDEX agency_ledger_company_idx (company_id, created_at),
  INDEX agency_ledger_booking_idx (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS traveller_documents (
  id CHAR(36) PRIMARY KEY,
  traveller_id CHAR(36) NOT NULL,
  booking_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  kind VARCHAR(50) NOT NULL,
  storage_path VARCHAR(500) NOT NULL,
  original_name VARCHAR(255) NULL,
  mime_type VARCHAR(100) NULL,
  file_size INT UNSIGNED NULL,
  status ENUM('under_review','approved','rejected') NOT NULL DEFAULT 'under_review',
  rejection_reason TEXT NULL,
  expires_on DATE NULL,
  reviewed_by CHAR(36) NULL,
  reviewed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT traveller_documents_traveller_fk FOREIGN KEY (traveller_id) REFERENCES booking_travellers(id) ON DELETE CASCADE,
  CONSTRAINT traveller_documents_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT traveller_documents_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT traveller_documents_user_fk FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX traveller_documents_booking_idx (booking_id, status),
  INDEX traveller_documents_company_idx (company_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_announcements (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  created_by CHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  audience ENUM('all','confirmed','unpaid','documents_missing') NOT NULL DEFAULT 'all',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT trip_announcements_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  CONSTRAINT trip_announcements_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT trip_announcements_user_fk FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
  INDEX trip_announcements_package_idx (package_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_rooms (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  city ENUM('makkah','madinah') NOT NULL,
  label VARCHAR(100) NOT NULL,
  capacity TINYINT UNSIGNED NOT NULL,
  gender_policy ENUM('male','female','family') NOT NULL DEFAULT 'family',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT trip_rooms_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  CONSTRAINT trip_rooms_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  UNIQUE KEY trip_rooms_label_unique (package_id, city, label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_room_assignments (
  room_id CHAR(36) NOT NULL,
  traveller_id CHAR(36) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (room_id, traveller_id),
  UNIQUE KEY trip_room_traveller_unique (traveller_id),
  CONSTRAINT trip_room_assignments_room_fk FOREIGN KEY (room_id) REFERENCES trip_rooms(id) ON DELETE CASCADE,
  CONSTRAINT trip_room_assignments_traveller_fk FOREIGN KEY (traveller_id) REFERENCES booking_travellers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_transport_segments (
  id CHAR(36) PRIMARY KEY,
  package_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  mode ENUM('flight','bus') NOT NULL,
  provider VARCHAR(190) NULL,
  reference_no VARCHAR(120) NULL,
  vehicle_no VARCHAR(120) NULL,
  driver_name VARCHAR(190) NULL,
  driver_phone VARCHAR(50) NULL,
  guide_name VARCHAR(190) NULL,
  departure_place VARCHAR(255) NULL,
  departure_at DATETIME NULL,
  arrival_place VARCHAR(255) NULL,
  arrival_at DATETIME NULL,
  baggage VARCHAR(255) NULL,
  meeting_point TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT transport_segments_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE,
  CONSTRAINT transport_segments_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  INDEX transport_segments_package_idx (package_id, departure_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_transport_assignments (
  segment_id CHAR(36) NOT NULL,
  traveller_id CHAR(36) NOT NULL,
  seat_no VARCHAR(50) NULL,
  pickup_point VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (segment_id, traveller_id),
  CONSTRAINT transport_assignments_segment_fk FOREIGN KEY (segment_id) REFERENCES trip_transport_segments(id) ON DELETE CASCADE,
  CONSTRAINT transport_assignments_traveller_fk FOREIGN KEY (traveller_id) REFERENCES booking_travellers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agency_staff (
  id CHAR(36) PRIMARY KEY,
  company_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  role ENUM('manager','operations','finance','support','guide') NOT NULL DEFAULT 'support',
  permissions LONGTEXT NULL,
  status ENUM('active','invited','disabled') NOT NULL DEFAULT 'active',
  invited_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT agency_staff_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT agency_staff_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT agency_staff_inviter_fk FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY agency_staff_unique (company_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS support_messages (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NULL,
  email VARCHAR(190) NULL,
  message TEXT NOT NULL,
  status ENUM('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
  assigned_to CHAR(36) NULL,
  resolution_note TEXT NULL,
  resolved_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT support_messages_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT support_messages_assignee_fk FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  INDEX support_messages_status_idx (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reviews (
  id CHAR(36) PRIMARY KEY,
  booking_id CHAR(36) NOT NULL,
  company_id CHAR(36) NOT NULL,
  client_id CHAR(36) NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  public_reply TEXT NULL,
  replied_at DATETIME NULL,
  moderation_status ENUM('visible','hidden','flagged') NOT NULL DEFAULT 'visible',
  flagged_reason TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT reviews_booking_fk FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  CONSTRAINT reviews_company_fk FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT reviews_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY reviews_booking_unique (booking_id),
  INDEX reviews_company_idx (company_id, moderation_status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inquiries (
  id CHAR(36) PRIMARY KEY,
  client_id CHAR(36) NOT NULL,
  agency_id CHAR(36) NOT NULL,
  offer_id CHAR(36) NULL,
  status ENUM('open','closed') NOT NULL DEFAULT 'open',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT inquiries_client_fk FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT inquiries_agency_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT inquiries_offer_fk FOREIGN KEY (offer_id) REFERENCES packages(id) ON DELETE SET NULL,
  INDEX inquiries_agency_idx (agency_id, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inquiry_messages (
  id CHAR(36) PRIMARY KEY,
  inquiry_id CHAR(36) NOT NULL,
  sender_id CHAR(36) NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT inquiry_messages_inquiry_fk FOREIGN KEY (inquiry_id) REFERENCES inquiries(id) ON DELETE CASCADE,
  CONSTRAINT inquiry_messages_sender_fk FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX inquiry_messages_thread_idx (inquiry_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS carousel_requests (
  id CHAR(36) PRIMARY KEY,
  agency_id CHAR(36) NOT NULL,
  package_id CHAR(36) NULL,
  title VARCHAR(255) NOT NULL,
  requested_days SMALLINT UNSIGNED NOT NULL DEFAULT 7,
  price_iqd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
  reviewed_by CHAR(36) NULL,
  review_note TEXT NULL,
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT carousel_requests_company_fk FOREIGN KEY (agency_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT carousel_requests_package_fk FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE SET NULL,
  CONSTRAINT carousel_requests_user_fk FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX carousel_requests_status_idx (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS error_logs (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NULL,
  message TEXT NOT NULL,
  stack MEDIUMTEXT NULL,
  context VARCHAR(255) NULL,
  app_version VARCHAR(50) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT error_logs_user_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX error_logs_created_idx (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id CHAR(36) PRIMARY KEY,
  actor_id CHAR(36) NULL,
  actor_role VARCHAR(30) NOT NULL DEFAULT 'system',
  entity_type VARCHAR(80) NOT NULL,
  entity_id CHAR(36) NULL,
  action VARCHAR(100) NOT NULL,
  before_data LONGTEXT NULL,
  after_data LONGTEXT NULL,
  note TEXT NULL,
  ip_address VARCHAR(45) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT audit_logs_actor_fk FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX audit_logs_entity_idx (entity_type, entity_id, created_at),
  INDEX audit_logs_actor_idx (actor_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS system_settings (
  setting_key VARCHAR(100) PRIMARY KEY,
  setting_value TEXT NULL,
  value_type ENUM('string','number','boolean','json') NOT NULL DEFAULT 'string',
  is_public TINYINT(1) NOT NULL DEFAULT 0,
  description VARCHAR(255) NULL,
  updated_by CHAR(36) NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT system_settings_user_fk FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (id, email, password_hash, role, full_name, status, force_password_change, email_verified_at)
VALUES ('00000000-0000-4000-8000-000000000001', 'admin@707222.xyz', '$2y$12$rWeze1RH9YonVTlmWU4PzObI46Fno2eqPzCyUUdd/gm9yek504Mn.', 'admin', 'Tawaf Administrator', 'active', 1, UTC_TIMESTAMP())
ON DUPLICATE KEY UPDATE email = VALUES(email);

INSERT INTO badges (id, badge_key, name_ku, name_ar, name_en, icon, type) VALUES
('10000000-0000-4000-8000-000000000001', 'verified', 'پشتڕاستکراوە', 'موثقة', 'Verified', 'verified', 'auto'),
('10000000-0000-4000-8000-000000000002', 'top_rated', 'هەڵسەنگاندنی بەرز', 'الأعلى تقييماً', 'Top rated', 'star', 'auto'),
('10000000-0000-4000-8000-000000000003', 'trusted_partner', 'هاوبەشی متمانەپێکراو', 'شريك موثوق', 'Trusted partner', 'shield', 'manual'),
('10000000-0000-4000-8000-000000000004', 'fast_response', 'وەڵامی خێرا', 'استجابة سريعة', 'Fast response', 'bolt', 'auto')
ON DUPLICATE KEY UPDATE name_en = VALUES(name_en);

INSERT INTO system_settings (setting_key, setting_value, value_type, is_public, description) VALUES
('platform_commission_rate', '0.05', 'number', 0, 'Default platform commission rate'),
('booking_request_expiry_hours', '24', 'number', 0, 'Hours before an unanswered booking request expires'),
('maintenance_mode', 'false', 'boolean', 1, 'Temporarily disable public app operations'),
('support_email', 'support@707222.xyz', 'string', 1, 'Customer support address')
ON DUPLICATE KEY UPDATE description = VALUES(description);

SET FOREIGN_KEY_CHECKS = 1;
