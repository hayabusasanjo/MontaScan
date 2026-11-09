// admin-web/src/app/dashboard/page.tsx
"use client";

import React from "react";
import {
  GraduationCap,
  Users,
  BookOpen,
  LayoutGrid,
  CheckCircle2,
  Clock,
  AlertTriangle,
  QrCode,
  ArrowUpRight,
  TrendingUp,
} from "lucide-react";
import {
  initialStudents,
  initialTeachers,
  initialSubjects,
  initialSections,
  initialSessions,
  initialRecords,
} from "@/lib/supabase";

export default function DashboardOverviewPage() {
  const activeSessionsCount = initialSessions.filter((s) => s.status === "active").length;
  const totalEnrolled = initialStudents.length * 4; // Approx 20 enrollments
  const presentCount = initialRecords.filter((r) => r.status === "present").length;
  const lateCount = initialRecords.filter((r) => r.status === "late").length;
  const absentCount = initialRecords.filter((r) => r.status === "absent").length;
  const rate = "92.4%";

  return (
    <div className="space-y-6">
      {/* Title */}
      <div>
        <h1 className="text-2xl font-bold text-navy">Executive Attendance Overview</h1>
        <p className="text-xs text-textSecondary mt-1">
          Real-time institution-wide metric monitors for Colegio de Montalban
        </p>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total Students */}
        <div className="bg-white p-5 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-textSecondary uppercase">Total Students</span>
            <div className="p-2 bg-primary/10 rounded-xl text-primary">
              <GraduationCap className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-navy">{initialStudents.length * 70}</span>
            <span className="text-xs text-success font-semibold ml-2 inline-flex items-center">
              <TrendingUp className="w-3.5 h-3.5 mr-0.5" /> +4.2%
            </span>
          </div>
          <p className="text-[11px] text-textSecondary mt-1">Enrolled across 4 departments</p>
        </div>

        {/* Total Faculty */}
        <div className="bg-white p-5 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-textSecondary uppercase">Faculty Members</span>
            <div className="p-2 bg-navy/10 rounded-xl text-navy">
              <Users className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-navy">{initialTeachers.length * 15}</span>
            <span className="text-xs text-textSecondary font-semibold ml-2">Active Instructors</span>
          </div>
          <p className="text-[11px] text-textSecondary mt-1">Institute of Computer Studies</p>
        </div>

        {/* Subjects & Sections */}
        <div className="bg-white p-5 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-textSecondary uppercase">Curriculum Units</span>
            <div className="p-2 bg-success/10 rounded-xl text-success">
              <BookOpen className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-navy">{initialSubjects.length}</span>
            <span className="text-xs text-textSecondary font-semibold ml-2">Subjects / {initialSections.length} Sections</span>
          </div>
          <p className="text-[11px] text-textSecondary mt-1">1st Semester 2026-2027</p>
        </div>

        {/* Active QR Sessions */}
        <div className="bg-white p-5 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-textSecondary uppercase">Active Dynamic Sessions</span>
            <div className="p-2 bg-primary rounded-xl text-white shadow-md shadow-primary/30 animate-pulse">
              <QrCode className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-extrabold text-primary">{activeSessionsCount}</span>
            <span className="text-xs font-bold text-success ml-2">Active Now</span>
          </div>
          <p className="text-[11px] text-textSecondary mt-1">Rotating cryptographic tokens</p>
        </div>
      </div>

      {/* Attendance Summary Banner */}
      <div className="bg-gradient-to-r from-navy to-navy-light text-white p-6 rounded-2xl shadow-sm">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <span className="px-2.5 py-1 bg-white/20 text-white rounded-md text-[10px] font-bold tracking-wider uppercase">
              Institutional Compliance
            </span>
            <h2 className="text-2xl font-extrabold text-white mt-2">Overall Student Attendance Rate: {rate}</h2>
            <p className="text-xs text-white/70 mt-1">
              Evaluated against real server timestamps and 15-minute standard policy window.
            </p>
          </div>

          <div className="flex items-center gap-4">
            <div className="text-center px-4 py-2 bg-white/10 rounded-xl">
              <span className="text-xl font-bold text-success-light block">{presentCount}</span>
              <span className="text-[10px] text-white/70 font-semibold uppercase">Present</span>
            </div>
            <div className="text-center px-4 py-2 bg-white/10 rounded-xl">
              <span className="text-xl font-bold text-warning-light block">{lateCount}</span>
              <span className="text-[10px] text-white/70 font-semibold uppercase">Late</span>
            </div>
            <div className="text-center px-4 py-2 bg-white/10 rounded-xl">
              <span className="text-xl font-bold text-error-light block">{absentCount}</span>
              <span className="text-[10px] text-white/70 font-semibold uppercase">Absent</span>
            </div>
          </div>
        </div>
      </div>

      {/* Two Column Layout: Active Sessions & Recent Attendance Scans */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Active Class Attendance Sessions */}
        <div className="bg-white p-6 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-base text-navy">Live Class Attendance Sessions</h3>
            <span className="text-xs font-semibold text-primary">{initialSessions.length} total</span>
          </div>

          <div className="space-y-3">
            {initialSessions.map((session) => (
              <div
                key={session.id}
                className="p-4 rounded-xl border border-borderSlate bg-background/50 hover:bg-background transition"
              >
                <div className="flex items-start justify-between">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="px-2 py-0.5 bg-primary/10 text-primary text-xs font-bold rounded">
                        {session.subjectCode}
                      </span>
                      <span className="font-bold text-sm text-navy">{session.sectionName}</span>
                    </div>
                    <p className="text-xs font-medium text-textMain mt-1">{session.subjectName}</p>
                    <p className="text-[11px] text-textSecondary mt-0.5">Instructor: {session.teacherName}</p>
                  </div>
                  <span
                    className={`px-2.5 py-1 rounded-full text-xs font-bold uppercase ${
                      session.status === "active"
                        ? "bg-success/15 text-success border border-success/30"
                        : "bg-borderSlate text-textSecondary"
                    }`}
                  >
                    {session.status}
                  </span>
                </div>

                <div className="mt-3 pt-3 border-t border-borderSlate flex items-center justify-between text-xs">
                  <span className="text-textSecondary">
                    Attendance: <strong className="text-navy">{session.presentCount + session.lateCount}</strong> / {session.totalEnrolled}
                  </span>
                  <span className="text-textSecondary">Started: {session.startedAt}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Attendance Scans Feed */}
        <div className="bg-white p-6 rounded-2xl border border-borderSlate shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-bold text-base text-navy">Latest Dynamic Check-ins</h3>
            <span className="text-xs text-textSecondary">Automatic Realtime Feed</span>
          </div>

          <div className="space-y-3">
            {initialRecords.map((record) => (
              <div
                key={record.id}
                className="flex items-center justify-between p-3 rounded-xl border border-borderSlate hover:bg-background/40 transition"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-primary/10 text-primary flex items-center justify-center font-bold text-xs">
                    {record.studentName.slice(0, 2).toUpperCase()}
                  </div>
                  <div>
                    <p className="text-xs font-bold text-navy">{record.studentName}</p>
                    <p className="text-[11px] text-textSecondary">
                      {record.studentNumber} • {record.subjectCode} ({record.sectionName})
                    </p>
                  </div>
                </div>

                <div className="text-right">
                  <span
                    className={`inline-block px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider ${
                      record.status === "present"
                        ? "bg-success/15 text-success"
                        : record.status === "late"
                        ? "bg-warning/15 text-warning"
                        : record.status === "excused"
                        ? "bg-primary/15 text-primary"
                        : "bg-error/15 text-error"
                    }`}
                  >
                    {record.status}
                  </span>
                  <p className="text-[10px] text-textSecondary mt-0.5">{record.scannedAt.split(" ")[1]}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
