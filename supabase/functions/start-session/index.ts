// supabase/functions/start-session/index.ts
// Supabase Edge Function to initiate an attendance session and generate initial dynamic QR token

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { subjectAssignmentId, validitySeconds = 20 } = await req.json();
    if (!subjectAssignmentId) {
      return new Response(JSON.stringify({ error: "subjectAssignmentId is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Generate 256-bit cryptographically secure random token
    const randomBytes = new Uint8Array(32);
    crypto.getRandomValues(randomBytes);
    const rawToken = Array.from(randomBytes)
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    // 2. Compute SHA-256 hash of the token
    const tokenBuffer = new TextEncoder().encode(rawToken);
    const hashBuffer = await crypto.subtle.digest("SHA-256", tokenBuffer);
    const tokenHash = Array.from(new Uint8Array(hashBuffer))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");

    // 3. Invoke atomic RPC function
    const { data, error } = await supabase.rpc("create_attendance_session", {
      p_subject_assignment_id: subjectAssignmentId,
      p_initial_token_hash: tokenHash,
      p_validity_seconds: validitySeconds,
    });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Return the session ID and the raw token for client QR rendering
    return new Response(
      JSON.stringify({
        sessionId: data.session_id,
        rawToken: rawToken,
        expiresAt: data.expires_at,
        validitySeconds: validitySeconds,
        status: data.status,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
