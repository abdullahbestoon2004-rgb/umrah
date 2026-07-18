# Payments and Commission System

Tawaf uses a hybrid marketplace ledger implemented by the PHP API and MySQL
tables in `tawafbackend/sql/production.sql`.

## Money model

When a client pays online through FIB, Tawaf collects the full amount and owes
the agency the booking payout after commission. When a client pays cash at an
agency, the agency collects the money and owes Tawaf its commission.

`agency_ledger.amount_iqd` is signed:

| Entry | Meaning | Sign |
|---|---|---|
| `booking_credit` | Agency share of a successful online payment | Positive |
| `cash_commission_debit` | Commission owed on agency-collected cash | Negative |
| `payout` | Money transferred from Tawaf to an agency | Negative |
| `refund_reversal` | Reversal of an earlier earning | Opposite sign |
| `adjustment` | Audited manual correction | Either |

An agency balance is always the sum of its ledger entries. Positive means
Tawaf owes the agency; negative means the agency owes Tawaf.

## Booking snapshots

The PHP server—not the mobile app—selects the occupancy price and stores the
booking's `unit_price_iqd`, total, commission rate, commission, payout,
deposit, cancellation policy, and translated package/company names. Changing
a package later does not rewrite existing bookings.

The commission rate resolves from package override to company rate to the
platform default. The default can be edited in the admin dashboard Settings.

## FIB flow

1. The signed-in client calls `payments/fib/create` with a booking and an
   idempotency key.
2. PHP validates ownership and the amount, creates a local `payments` row,
   then creates the FIB payment using server-held credentials.
3. FIB calls `/tawafbackend/webhooks/fib`.
4. The webhook treats the callback only as a reference and asks FIB directly
   for the authoritative status before changing any Tawaf money rows.
5. A successful status updates the booking, posts the proportional agency
   ledger entry, and creates the commission record. Repeated callbacks are
   idempotent.

Configure these server environment variables:

```text
FIB_BASE_URL=https://fib.stage.fib.iq
FIB_CLIENT_ID=your-client-id
FIB_CLIENT_SECRET=your-client-secret
```

Use `https://fib.prod.fib.iq` only after production credentials and webhook
reachability are confirmed.

## Cash flow

The agency confirms cash in the app. PHP creates a successful cash payment,
updates the booking amount paid, and posts the proportional negative
commission entry. The device cannot edit money columns directly.

## Payouts

Administrators create pending payouts from an agency's positive available
balance in the Finance dashboard. Completing a payout posts one negative
ledger entry. Pending payouts are reserved when the dashboard calculates the
amount still available.

## Security invariants

- Database and FIB credentials exist only in PHP server configuration.
- Mobile authentication uses random, revocable opaque tokens stored as SHA-256
  hashes in `auth_sessions`.
- FIB callback bodies never decide payment success by themselves.
- All sensitive administrator actions are written to `audit_logs`.
- Private identity, agency, and traveller files are outside public access and
  use short-lived signed links or authenticated dashboard downloads.
