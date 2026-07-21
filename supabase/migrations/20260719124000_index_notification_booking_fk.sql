-- PostgreSQL does not automatically index foreign-key columns. Notifications
-- are deleted with their booking, so cover that cascade lookup.
create index if not exists notifications_booking_id_idx
  on public.notifications (booking_id);
