-- Keep public media and private identity documents in Supabase Storage with
-- explicit limits. Access remains controlled by the existing storage.objects
-- RLS policies; these settings only constrain file size and MIME type.

update storage.buckets
set file_size_limit = 10485760,
    allowed_mime_types = array[
      'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'
    ]::text[]
where id in (
  'identity_verifications',
  'booking-passports',
  'package-images',
  'agency-media',
  'offer-media'
);

update storage.buckets
set file_size_limit = 10485760,
    allowed_mime_types = array[
      'image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif',
      'application/pdf'
    ]::text[]
where id in ('agency-documents', 'traveller-documents');
