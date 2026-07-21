// Delivers a freshly-inserted `notifications` row to the user's devices via
// Firebase Cloud Messaging (HTTP v1).
//
// Invoked by the `push_on_notification` trigger, never by the app directly.
//
// Secrets (never in the Flutter app):
//   supabase secrets set FCM_SERVICE_ACCOUNT='<the service-account JSON>'
// The service account comes from the Firebase console:
//   Project settings → Service accounts → Generate new private key.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface PushPayload {
  user_id: string;
  type: string;
  arg: string | null;
  booking_id: string | null;
  notification_id: string;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id: string;
}

function serviceAccount(): ServiceAccount {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT is not set");
  return JSON.parse(raw) as ServiceAccount;
}

// ── Google OAuth: sign a JWT with the service account, exchange for a token ──

function base64url(input: Uint8Array | string): string {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : input;
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function pemToPkcs8(pem: string): Uint8Array {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  return Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
}

async function accessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${
    base64url(JSON.stringify(claim))
  }`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToPkcs8(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64url(new Uint8Array(signature))}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    throw new Error(`Google auth failed: ${res.status} ${await res.text()}`);
  }
  return (await res.json()).access_token as string;
}

// ── Message copy ────────────────────────────────────────────────────────────
// Kept short and language-neutral-ish; the app itself renders the fully
// localised version in the notification list once opened.

function messageFor(type: string, arg: string | null): {
  title: string;
  body: string;
} {
  switch (type) {
    case "bookingConfirmed":
      return {
        title: "Booking confirmed",
        body: arg ? `Your trip "${arg}" is confirmed.` : "Your trip is confirmed.",
      };
    case "bookingCancelled":
      return {
        title: "Booking cancelled",
        body: arg ? `Your trip "${arg}" was cancelled.` : "Your trip was cancelled.",
      };
    case "bookingRequested":
      return {
        title: "Booking requested",
        body: arg ? `Request sent for "${arg}".` : "Your request was sent.",
      };
    case "tripReminder":
      return {
        title: "Trip reminder",
        body: arg ? `"${arg}" departs soon.` : "Your trip departs soon.",
      };
    case "documentsUploaded":
      return {
        title: "Documents uploaded",
        body: arg ? `New documents for "${arg}".` : "New traveller documents.",
      };
    default:
      return { title: "Tawaf", body: arg ?? "You have a new notification." };
  }
}

Deno.serve(async (req) => {
  try {
    const payload = (await req.json()) as PushPayload;
    if (!payload?.user_id) {
      return new Response("user_id is required", { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: tokens, error } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", payload.user_id);
    if (error) throw error;
    if (!tokens?.length) {
      return Response.json({ sent: 0, reason: "no registered devices" });
    }

    const account = serviceAccount();
    const token = await accessToken(account);
    const { title, body } = messageFor(payload.type, payload.arg);

    const endpoint =
      `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`;

    let sent = 0;
    const stale: string[] = [];

    await Promise.all(
      tokens.map(async ({ token: deviceToken }) => {
        const res = await fetch(endpoint, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: deviceToken,
              notification: { title, body },
              // The app reads these to refresh state and deep-link on tap.
              data: {
                type: payload.type,
                booking_id: payload.booking_id ?? "",
                notification_id: payload.notification_id,
              },
              android: { priority: "high" },
              apns: {
                payload: { aps: { sound: "default", badge: 1 } },
              },
            },
          }),
        });
        if (res.ok) {
          sent++;
          return;
        }
        // A token that FCM no longer recognises should not be retried forever.
        if (res.status === 404 || res.status === 400) stale.push(deviceToken);
      }),
    );

    if (stale.length) {
      await supabase.from("device_tokens").delete().in("token", stale);
    }

    return Response.json({ sent, pruned: stale.length });
  } catch (err) {
    console.error("send-push failed", err);
    return new Response(String(err), { status: 500 });
  }
});
