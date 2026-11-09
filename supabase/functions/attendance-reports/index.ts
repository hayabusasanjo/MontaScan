// supabase/functions/attendance-reports/index.ts
// Supabase Edge Function to generate aggregated attendance reporting data

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

    const url = new URL(req.url);
    const startDate = url.searchParams.get("startDate");
    const endDate = url.searchParams.get("endDate");
    const sectionId = url.searchParams.get("sectionId");
    const subjectId = url.searchParams.get("subjectId");

    let query = supabase
      .from("attendance_records")
      .select(`
        id,
        scanned_at,
        status,
        attendance_sessions!inner (
          id,
          session_date,
          subject_assignments!inner (
            id,
            sections!inner ( id, section_name ),
            subjects!inner ( id, subject_code, subject_name ),
            teachers!inner ( id, profiles ( full_name ) )
          )
        ),
        students!inner (
          id,
          student_number,
          profiles!inner ( full_name, email )
        )
      `);

    if (startDate) {
      query = query.gte("attendance_sessions.session_date", startDate);
    }
    if (endDate) {
      query = query.lte("attendance_sessions.session_date", endDate);
    }
    if (sectionId) {
      query = query.eq("attendance_sessions.subject_assignments.section_id", sectionId);
    }
    if (subjectId) {
      query = query.eq("attendance_sessions.subject_assignments.subject_id", subjectId);
    }

    const { data, error } = await query;
    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Aggregate summary statistics
    let presentCount = 0;
    let lateCount = 0;
    let absentCount = 0;
    let excusedCount = 0;

    data?.forEach((row: any) => {
      if (row.status === "present") presentCount++;
      else if (row.status === "late") lateCount++;
      else if (row.status === "absent") absentCount++;
      else if (row.status === "excused") excusedCount++;
    });

    const total = data?.length || 0;
    const rate = total > 0 ? (((presentCount + lateCount) / total) * 100).toFixed(1) : "0.0";

    return new Response(
      JSON.stringify({
        summary: {
          totalRecords: total,
          present: presentCount,
          late: lateCount,
          absent: absentCount,
          excused: excusedCount,
          attendanceRate: `${rate}%`,
        },
        records: data,
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
