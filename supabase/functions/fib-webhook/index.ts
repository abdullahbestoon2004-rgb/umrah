// Payment confirmation receiver — the ONLY path that marks payments succeeded.
//
// Two callers, one reconcile core:
//   1. FIB's statusCallbackUrl posts { id, status } when a payment settles.
//   2. The Flutter app may POST { payment_id } (with the user's JWT) to force
//      a re-check — useful when the webhook is delayed or unreachable in dev.
//
// In BOTH cases the body is only a hint: we look the payment up ourselves and
// ask FIB's API for the authoritative status before touching the database.
// All mutations go through record_payment_success/-failure (service role),
// which are idempotent, so replayed or duplicated callbacks are harmless.

import { createClient } from "jsr:@supabase/supabase-js@2";
import { fibPaymentStatus } from "../_shared/fib.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }
  try {
    const body = await req.json().catch(() => ({}));
    const service = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Resolve our payments row from whichever hint we got.
    let query = service
      .from("payments")
      .select("id, provider_reference, status")
      .eq("method", "fib");
    if (body.payment_id) {
      query = query.eq("id", body.payment_id);
    } else if (body.id) {
      query = query.eq("provider_reference", body.id);
    } else {
      return Response.json({ error: "missing payment reference" }, { status: 400 });
    }
    const { data: payment } = await query.maybeSingle();
    if (!payment?.provider_reference) {
      // Unknown reference — acknowledge so the gateway stops retrying,
      // but change nothing.
      return Response.json({ ok: true, matched: false }, { status: 200 });
    }
    if (payment.status !== "initiated") {
      return Response.json({ ok: true, status: payment.status }, { status: 200 });
    }

    // Authenticity: never trust the callback body — ask FIB directly.
    const status = await fibPaymentStatus(payment.provider_reference);

    if (status === "PAID") {
      const { error } = await service.rpc("record_payment_success", {
        p_payment_id: payment.id,
        p_provider_reference: payment.provider_reference,
      });
      if (error) throw error;
    } else if (status === "DECLINED") {
      const { error } = await service.rpc("record_payment_failure", {
        p_payment_id: payment.id,
        p_reason: "declined by FIB",
      });
      if (error) throw error;
    }
    // UNPAID → still pending, change nothing.

    return Response.json({ ok: true, status }, { status: 200 });
  } catch (e) {
    console.error("fib-webhook:", e);
    // Non-200 so FIB retries later.
    return Response.json({ error: "internal error" }, { status: 500 });
  }
});
