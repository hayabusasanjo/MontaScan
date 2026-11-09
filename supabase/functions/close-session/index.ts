// supabase/functions/close-session/index.ts
// Supabase Edge Function to close an attendance session and finalize records

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

    const { sessionId, autoFinalize = true } = await req.json();
    if (!sessionId) {
      return new Response(JSON.stringify({ error: "sessionId is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Close session
    const { data: closeData, error: closeError } = await supabase.rpc("close_attendance_session", {
      p_session_id: sessionId,
    });

    if (closeError) {
      return new Response(JSON.stringify({ error: closeError.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Finalize unrecorded students as absent if requested
    let finalizeData = null;
    if (autoFinalize) {
      const { data: finData, error: finError } = await supabase.rpc("finalize_attendance", {
        p_session_id: sessionId,
      });
      if (!finError) {
        finalizeData = finData;
      }
    }

    return new Response(
      JSON.stringify({
        session: closeData,
        finalization: finalizeData,
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
