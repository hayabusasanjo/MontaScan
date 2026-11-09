// admin-web/src/app/dashboard/attendance/page.tsx
"use client";

import React, { useState } from "react";
import {
  ClipboardList,
  Search,
  CheckCircle2,
  Clock,
  AlertTriangle,
  Edit3,
  Eye,
  X,
  ShieldCheck,
} from "lucide-react";
import { initialSessions, initialRecords, MockAttendanceSession, MockAttendanceRecord } from "@/lib/supabase";

export default function AttendanceSessionsPage() {
  const [sessions, setSessions] = useState<MockAttendanceSession[]>(initialSessions);
  const [records, setRecords] = useState<MockAttendanceRecord[]>(initialRecords);
  const [selectedSession, setSelectedSession] = useState<MockAttendanceSession | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");

  // Correction state
  const [correctingRecord, setCorrectingRecord] = useState<MockAttendanceRecord | null>(null);
  const [newStatus, setNewStatus] = useState<"present" | "late" | "absent" | "excused">("present");
  const [correctionReason, setCorrectionReason] = useState("");

  const handleOpenCorrection = (rec: MockAttendanceRecord) => {
    setCorrectingRecord(rec);
    setNewStatus(rec.status);
    setCorrectionReason("");
  };

  const handleSaveCorrection = (e: React.FormEvent) => {
    e.preventDefault();
    if (!correctingRecord) return;

    setRecords(
      records.map((r) =>
        r.id === correctingRecord.id ? { ...r, status: newStatus } : r
      )
    );
    setCorrectingRecord(null);
  };

  const displayedRecords = records.filter((r) => {
    if (selectedSession && r.sessionId !== selectedSession.id) return false;
    if (statusFilter !== "All" && r.status !== statusFilter.toLowerCase()) return false;
    if (search.trim()) {
      const q = search.toLowerCase();
      return r.studentName.toLowerCase().includes(q) || r.studentNumber.includes(q);
    }
    return true;
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Attendance Session Monitor</h1>
          <p className="text-xs text-textSecondary mt-1">
            Realtime roll call sessions, student check-in records, and administrative status audits.
          </p>
        </div>
      </div>

      {/* Sessions Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {sessions.map((sess) => {
          const isSelected = selectedSession?.id === sess.id;
          return (
            <div
              key={sess.id}
              onClick={() => setSelectedSession(isSelected ? null : sess)}
              className={`p-5 rounded-2xl border cursor-pointer transition ${
                isSelected
                  ? "bg-primary/5 border-primary shadow-md"
                  : "bg-white border-borderSlate hover:border-primary/50 shadow-sm"
              }`}
            >
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="px-2 py-0.5 bg-primary/10 text-primary text-xs font-bold rounded">
                      {sess.subjectCode}
                    </span>
                    <span className="font-bold text-navy text-sm">{sess.sectionName}</span>
                  </div>
                  <h3 className="font-bold text-sm text-textMain mt-1.5">{sess.subjectName}</h3>
                  <p className="text-xs text-textSecondary mt-0.5">Teacher: {sess.teacherName}</p>
                </div>
                <span
                  className={`px-2.5 py-1 rounded-full text-xs font-bold uppercase ${
                    sess.status === "active"
                      ? "bg-success/15 text-success border border-success/30"
                      : "bg-borderSlate text-textSecondary"
                  }`}
                >
                  {sess.status}
                </span>
              </div>

              <div className="mt-4 pt-3 border-t border-borderSlate flex items-center justify-between text-xs">
                <span className="text-textSecondary">
                  Date: <strong className="text-navy">{sess.sessionDate}</strong>
                </span>
                <span className="text-primary font-bold">
                  {isSelected ? "Filter Applied (Click to Clear)" : "View Attendees →"}
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* Attendees Table Filter */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-textSecondary absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search attendees by student name or ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-xs bg-background border border-borderSlate rounded-xl focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-textSecondary font-medium">Status Filter:</span>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="text-xs bg-background border border-borderSlate rounded-xl px-3 py-2"
          >
            <option value="All">All Statuses</option>
            <option value="Present">Present</option>
            <option value="Late">Late</option>
            <option value="Absent">Absent</option>
            <option value="Excused">Excused</option>
          </select>
        </div>
      </div>

      {/* Records Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Student</th>
                <th className="px-6 py-3.5">Student No.</th>
                <th className="px-6 py-3.5">Subject</th>
                <th className="px-6 py-3.5">Section</th>
                <th className="px-6 py-3.5">Server Timestamp</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5">Audit & Correction</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {displayedRecords.map((r) => (
                <tr key={r.id} className="hover:bg-background/50 transition">
                  <td className="px-6 py-4 font-bold text-navy">{r.studentName}</td>
                  <td className="px-6 py-4 font-mono font-bold text-primary">{r.studentNumber}</td>
                  <td className="px-6 py-4 font-bold">{r.subjectCode}</td>
                  <td className="px-6 py-4">{r.sectionName}</td>
                  <td className="px-6 py-4 text-textSecondary">{r.scannedAt}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-block px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider ${
                        r.status === "present"
                          ? "bg-success/15 text-success"
                          : r.status === "late"
                          ? "bg-warning/15 text-warning"
                          : r.status === "excused"
                          ? "bg-primary/15 text-primary"
                          : "bg-error/15 text-error"
                      }`}
                    >
                      {r.status}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => handleOpenCorrection(r)}
                      className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-background hover:bg-borderSlate/60 border border-borderSlate rounded-lg text-xs font-semibold text-navy transition"
                    >
                      <Edit3 className="w-3.5 h-3.5 text-primary" />
                      <span>Correct Status</span>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Authorized Correction Modal */}
      {correctingRecord && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6 text-xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <div className="flex items-center gap-2">
                <ShieldCheck className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-navy text-base">Authorized Attendance Correction</h3>
              </div>
              <button onClick={() => setCorrectingRecord(null)} className="p-1 text-textSecondary">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveCorrection} className="space-y-4">
              <div>
                <p className="font-bold text-navy text-sm">{correctingRecord.studentName}</p>
                <p className="text-textSecondary text-xs">
                  {correctingRecord.studentNumber} • {correctingRecord.subjectCode} ({correctingRecord.sectionName})
                </p>
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                  Updated Attendance Status
                </label>
                <select
                  value={newStatus}
                  onChange={(e) => setNewStatus(e.target.value as any)}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl font-bold"
                >
                  <option value="present">PRESENT</option>
                  <option value="late">LATE</option>
                  <option value="absent">ABSENT</option>
                  <option value="excused">EXCUSED</option>
                </select>
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                  Auditable Reason / Justification (Mandatory)
                </label>
                <textarea
                  required
                  rows={3}
                  value={correctionReason}
                  onChange={(e) => setCorrectionReason(e.target.value)}
                  placeholder="e.g. Validated clinic medical slip; approved official school event exemption."
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>

              <div className="flex justify-end gap-2 pt-4 border-t border-borderSlate">
                <button
                  type="button"
                  onClick={() => setCorrectingRecord(null)}
                  className="px-4 py-2 border border-borderSlate rounded-xl font-semibold text-textSecondary"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary hover:bg-primary-hover text-white rounded-xl font-bold shadow-md shadow-primary/20"
                >
                  Confirm & Audit Log
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
