// Creates a FIB payment for a booking on behalf of the signed-in client.
//
// POST { booking_id: string, amount_iqd: number, idempotency_key: string }
// → { payment_id, fib: { readableCode, qrCode, validUntil, personalAppLink, … } }
//
// Flow: verify the caller's JWT → initiate_payment() runs AS THE USER (so all
// ownership/amount checks apply) → create the FIB payment with server-held
// credentials → stash FIB's paymentId as provider_reference. The payment stays
// 'initiated' until the fib-webhook function confirms it against FIB's API.

import { createClient } from "jsr:@supabase/supabase-js@2";
import { fibCreatePayment } from "../_shared/fib.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }
  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

    // Client scoped to the caller: RPC runs with their auth.uid().
    const asUser = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userErr } = await asUser.auth.getUser();
    if (userErr || !userData?.user) {
      return Response.json({ error: "unauthorized" }, { status: 401 });
    }

    const { booking_id, amount_iqd, idempotency_key } = await req.json();
    if (!booking_id || !amount_iqd || !idempotency_key) {
      return Response.json({ error: "missing fields" }, { status: 400 });
    }

    const { data: paymentId, error: initErr } = await asUser.rpc(
      "initiate_payment",
      {
        p_booking_id: booking_id,
        p_amount_iqd: amount_iqd,
        p_method: "fib",
        p_idempotency_key: idempotency_key,
      },
    );
    if (initErr) {
      return Response.json({ error: initErr.message }, { status: 400 });
    }

    // Service client for the provider_reference write (client has no
    // update path on payments — by design).
    const service = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Idempotent retry: if this payment already has a FIB reference, return it
    // instead of creating a second FIB payment.
    const { data: existing } = await service
      .from("payments")
      .select("provider_reference, status")
      .eq("id", paymentId)
      .single();
    if (existing?.status !== "initiated") {
      return Response.json(
        { payment_id: paymentId, status: existing?.status },
        { status: 200 },
      );
    }

    let fib;
    if (existing?.provider_reference) {
      fib = { paymentId: existing.provider_reference };
    } else {
      const callbackUrl = `${supabaseUrl}/functions/v1/fib-webhook`;
      fib = await fibCreatePayment(
        Number(amount_iqd),
        `Umrah booking ${booking_id}`,
        callbackUrl,
      );
      await service
        .from("payments")
        .update({ provider_reference: fib.paymentId })
        .eq("id", paymentId);
    }

    return Response.json({ payment_id: paymentId, fib }, { status: 200 });
  } catch (e) {
    console.error("fib-create-payment:", e);
    return Response.json({ error: "internal error" }, { status: 500 });
  }
});
