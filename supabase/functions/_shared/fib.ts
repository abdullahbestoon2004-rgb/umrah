// Shared FIB (First Iraqi Bank) online-payment client for Edge Functions.
// Credentials live in Edge Function secrets — NEVER in the Flutter app:
//   supabase secrets set FIB_BASE_URL=https://fib.stage.fib.iq \
//     FIB_CLIENT_ID=... FIB_CLIENT_SECRET=...
// (production base URL: https://fib.prod.fib.iq)

const FIB_BASE_URL = Deno.env.get("FIB_BASE_URL") ?? "https://fib.stage.fib.iq";
const FIB_CLIENT_ID = Deno.env.get("FIB_CLIENT_ID") ?? "";
const FIB_CLIENT_SECRET = Deno.env.get("FIB_CLIENT_SECRET") ?? "";

async function fibToken(): Promise<string> {
  const res = await fetch(
    `${FIB_BASE_URL}/auth/realms/fib-online-shop/protocol/openid-connect/token`,
    {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        client_id: FIB_CLIENT_ID,
        client_secret: FIB_CLIENT_SECRET,
      }),
    },
  );
  if (!res.ok) throw new Error(`FIB auth failed: ${res.status}`);
  const json = await res.json();
  return json.access_token as string;
}

export interface FibCreatedPayment {
  paymentId: string;
  readableCode: string;
  qrCode: string; // data URI
  validUntil: string;
  personalAppLink: string;
  businessAppLink: string;
  corporateAppLink: string;
}

export async function fibCreatePayment(
  amountIqd: number,
  description: string,
  callbackUrl: string,
): Promise<FibCreatedPayment> {
  const token = await fibToken();
  const res = await fetch(`${FIB_BASE_URL}/protected/v1/payments`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      monetaryValue: { amount: String(amountIqd), currency: "IQD" },
      statusCallbackUrl: callbackUrl,
      description,
    }),
  });
  if (!res.ok) throw new Error(`FIB create payment failed: ${res.status}`);
  return await res.json();
}

// The ONLY trusted way to learn a payment's outcome: ask FIB directly.
// Webhook bodies are treated as hints, never as truth.
export async function fibPaymentStatus(
  fibPaymentId: string,
): Promise<"PAID" | "UNPAID" | "DECLINED"> {
  const token = await fibToken();
  const res = await fetch(
    `${FIB_BASE_URL}/protected/v1/payments/${fibPaymentId}/status`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  if (!res.ok) throw new Error(`FIB status check failed: ${res.status}`);
  const json = await res.json();
  return json.status;
}
