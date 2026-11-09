// supabase/functions/scan-attendance/index.ts
// Supabase Edge Function to validate a student's dynamic QR scan and record attendance atomically

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

    const { sessionId, rawToken } = await req.json();
    if (!sessionId || !rawToken) {
      return new Response(JSON.stringify({ error: "sessionId and rawToken are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Call atomic stored procedure
    const { data, error } = await supabase.rpc("validate_and_record_attendance", {
      p_session_id: sessionId,
      p_raw_token: rawToken,
    });

    if (error) {
      // Map known business logic exceptions
      const errorMsg = error.message;
      let statusCode = 400;
      if (errorMsg.includes("UNAUTHORIZED_ROLE")) statusCode = 403;
      if (errorMsg.includes("SESSION_NOT_FOUND")) statusCode = 404;
      if (errorMsg.includes("SESSION_CLOSED")) statusCode = 410;
      if (errorMsg.includes("TOKEN_EXPIRED")) statusCode = 408;
      if (errorMsg.includes("NOT_ENROLLED")) statusCode = 403;
      if (errorMsg.includes("DUPLICATE_SCAN")) statusCode = 409;

      return new Response(JSON.stringify({ error: errorMsg }), {
        status: statusCode,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
