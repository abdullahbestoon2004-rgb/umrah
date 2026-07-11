# Payments & Commission System

How money moves through the platform, what the ledger means, and how to extend
it. The database side lives in `supabase/patches_payments.sql`; the payment
gateway glue lives in `supabase/functions/`.

## The model in one paragraph

The platform runs a **hybrid marketplace**. When a client pays **online**
(FIB or card), the *platform* collects the full amount and owes the agency
`total − commission`. When a client pays **cash at the agency office**, the
*agency* collects and owes the platform the commission. Both directions flow
into one append-only ledger per agency (`agency_ledger`), so cash commission
debt automatically nets against online payout credit. The agency's balance is
always `sum(ledger.amount_iqd)` — never a stored, editable number.

## Ledger conventions

| | |
|---|---|
| **Sign** | positive = platform owes agency · negative = agency owes platform |
| **Currency** | `bigint` IQD (whole dinars, matching the rest of the schema) |
| **Append-only** | UPDATE/DELETE are blocked by a trigger, even for definer functions. Corrections are new compensating rows. |

Entry types:

| `entry_type` | When | Sign |
|---|---|---|
| `booking_credit` | An online payment succeeded | + (proportional share of `payout_iqd`) |
| `cash_commission_debit` | Agency confirmed cash received | − (proportional share of `commission_iqd`) |
| `refund_reversal` | Refund / cancellation | opposite of what it reverses |
| `payout` | `complete_payout()` — we transferred money to the agency | − |
| `adjustment` | `add_ledger_adjustment()` — manual admin correction | either |

**Proportionality with true-up:** every time a booking's paid amount changes,
`true_up_booking_ledger()` computes the exact target
(`round(payout_iqd × amount_paid / total)` for online, negative commission
equivalent for cash) and posts only the difference from what's already
ledgered. Deposits, remainders, partial refunds, and replayed webhooks all
converge on the same exact totals — no rounding drift, no double-posting.

## Financial snapshot on bookings

Amounts are **snapshotted at booking time** by the `fill_booking_amounts`
trigger and never recomputed from live prices: `unit_price_iqd`, `total_iqd`,
`commission_rate`, `commission_iqd`, `payout_iqd`. The rate resolves as
**package override → company rate → 0.05 default** (`resolve_commission_rate`).
Per-agency rates live in `companies.commission_rate`; a nullable
`packages.commission_rate` overrides it per trip.

`pay_status` lifecycle: `unpaid → partially_paid → paid`, plus `refunded` and
`failed`. `amount_paid_iqd` tracks money received net of refunds.

## Who may do what

| Actor | Can | Cannot |
|---|---|---|
| Client | create bookings; `initiate_payment` on own booking; read own bookings/payments | write any financial column; mark payments succeeded |
| Agency | read own bookings/payments/ledger/payouts/balance; `confirm_cash_received` on own cash bookings | touch amounts, rates, other agencies' rows, or the ledger directly |
| Admin | everything above + `refund_booking`, `create_payout`, `complete_payout`, `add_ledger_adjustment` | edit/delete ledger rows (nobody can) |
| Edge Function (service role) | `record_payment_success` / `record_payment_failure` | — |

All money mutations go through `security definer` functions; there is no RLS
path for direct writes to `payments`, `agency_ledger`, or `payouts`.

## Payment flows

### FIB (online, primary)

1. App calls Edge Function **`fib-create-payment`** with the user's JWT +
   `{ booking_id, amount_iqd, idempotency_key }`.
2. The function runs `initiate_payment()` *as the user* (ownership and amount
   checks apply), creates the FIB payment with server-held credentials, stores
   FIB's `paymentId` as `provider_reference`, and returns the QR code /
   readable code / app links for the client to pay with.
3. FIB calls **`fib-webhook`** when the payment settles. The webhook body is
   treated as a *hint only*: the function re-queries FIB's status API and only
   then calls `record_payment_success` / `record_payment_failure` (service
   role, idempotent). The app just watches its `payments` row (poll or
   realtime). **The Flutter client is never the source of truth.**
4. Local dev / missed webhook: the app can POST `{ payment_id }` to
   `fib-webhook` to force the same verified reconcile.

### Cash

Booking is created with `pay_method = 'cash'` and stays `unpaid`. The client
sees "pay at the agency office". When the money is handed over, the agency
taps **Confirm cash received** → `confirm_cash_received(booking_id)` records a
cash payment and posts the negative commission entry. Partial cash amounts are
supported (`p_amount_iqd`), and a double-tap is a no-op.

### Card

`CardPaymentProvider` is a stub behind the same interface (see below). Wire a
real gateway by adding one Edge Function pair like FIB's.

## Refunds & cancellation

- `refund_booking(booking_id, amount?)` — admin. Defaults to a full refund.
  Marks `payments` rows refunded newest-first, reduces `amount_paid_iqd`, and
  posts a proportional `refund_reversal`. A 25% refund reverses exactly 25% of
  the credit/debit.
- Setting a booking's `status` to `cancelled` (client, agency, or admin —
  existing flows untouched) triggers the same full reversal automatically.

## Payouts (admin, v1 manual)

```sql
select create_payout('<company_id>', 5000000, 'bank');   -- validates ≤ balance
select complete_payout('<payout_id>', 'BANK-REF-123');   -- posts −ledger entry
```

Pending payouts are counted as reserved, so two payouts can't both spend the
same balance. `complete_payout` is idempotent (unique ledger index per payout).

## Deploying

```bash
# 1. Database (SQL editor, or supabase db push if you use migrations)
#    run: supabase/patches_payments.sql

# 2. Edge functions
supabase functions deploy fib-create-payment
supabase functions deploy fib-webhook --no-verify-jwt   # FIB posts without a JWT

# 3. Secrets (never in the Flutter app)
supabase secrets set FIB_BASE_URL=https://fib.stage.fib.iq \
  FIB_CLIENT_ID=... FIB_CLIENT_SECRET=...
```

## Tests

`supabase/tests_payments.sql` — run in the SQL editor of a **dev** project
after the patch. It exercises snapshotting, online credit, cash debit +
netting, partial-payment proportionality, partial refund + cancel reversal,
payout limits/idempotency, and ledger immutability, then **rolls back**. All
assertions must pass (final notice: `ALL LEDGER TESTS PASSED`).

## Adding a new payment provider

1. **Dart**: implement `PaymentProvider` (`initiate()` → returns what the UI
   needs: redirect URL / QR / instructions). One new file.
2. **Edge Functions**: a `<provider>-create-payment` (calls
   `initiate_payment` as the user, talks to the gateway, stores
   `provider_reference`) and a `<provider>-webhook` (verifies with the gateway
   server-side, then `record_payment_success/-failure`). Copy the FIB pair.
3. **Nothing else changes** — ledger math, refunds, payouts, and RLS are
   method-agnostic (`payment_method` enum value + the online/cash split in
   `true_up_booking_ledger` are the only branch points).

## Relationship to the legacy `commissions` table

The pre-existing `commissions` table (and its `open_commission` trigger on
booking confirmation) still runs in parallel so the current admin/agency UI
keeps working. The ledger is the source of truth going forward; once the
Flutter wallet screens land, drop the old trigger:

```sql
-- after the wallet UI ships:
drop trigger if exists after_booking_confirmed on bookings;
```
