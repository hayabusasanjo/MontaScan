// admin-web/src/app/dashboard/reports/page.tsx
"use client";

import React, { useState } from "react";
import {
  FileBarChart,
  Download,
  FileSpreadsheet,
  FileText,
  Calendar,
  Filter,
  CheckCircle2,
  Clock,
  AlertTriangle,
} from "lucide-react";
import { initialRecords } from "@/lib/supabase";
import { exportAttendanceToExcel, exportAttendanceToPDF, AttendanceExportRow } from "@/lib/exportUtils";

export default function AttendanceReportsPage() {
  const [dateRange, setDateRange] = useState("daily"); // daily | weekly | monthly
  const [selectedSubject, setSelectedSubject] = useState("All");
  const [selectedSection, setSelectedSection] = useState("All");

  const rawData: AttendanceExportRow[] = initialRecords.map((r) => ({
    studentNumber: r.studentNumber,
    studentName: r.studentName,
    subjectCode: r.subjectCode,
    sectionName: r.sectionName,
    date: r.scannedAt.split(" ")[0],
    time: r.scannedAt.split(" ")[1],
    status: r.status,
  }));

  const filteredData = rawData.filter((row) => {
    if (selectedSubject !== "All" && row.subjectCode !== selectedSubject) return false;
    if (selectedSection !== "All" && row.sectionName !== selectedSection) return false;
    return true;
  });

  const total = filteredData.length;
  const present = filteredData.filter((r) => r.status === "present").length;
  const late = filteredData.filter((r) => r.status === "late").length;
  const absent = filteredData.filter((r) => r.status === "absent").length;
  const excused = filteredData.filter((r) => r.status === "excused").length;
  const rate = total > 0 ? `${(((present + late) / total) * 100).toFixed(1)}%` : "0.0%";

  const summary = { total, present, late, absent, rate };

  const handleExcelExport = () => {
    exportAttendanceToExcel(filteredData, `MontaScan_${dateRange.toUpperCase()}_Report.xlsx`);
  };

  const handlePdfExport = () => {
    exportAttendanceToPDF(
      filteredData,
      summary,
      `Colegio de Montalban - ${dateRange.toUpperCase()} Attendance Report`,
      `MontaScan_${dateRange.toUpperCase()}_Report.pdf`
    );
  };

  return (
    <div className="space-y-6">
      {/* Title & Export Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Attendance Reports & Exports</h1>
          <p className="text-xs text-textSecondary mt-1">
            Aggregate historical attendance records and export institutional reports.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleExcelExport}
            className="inline-flex items-center gap-2 px-3.5 py-2.5 bg-success hover:bg-success/90 text-white text-xs font-bold rounded-xl shadow-sm transition"
          >
            <FileSpreadsheet className="w-4 h-4" />
            <span>Export Excel (.xlsx)</span>
          </button>
          <button
            onClick={handlePdfExport}
            className="inline-flex items-center gap-2 px-3.5 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition"
          >
            <FileText className="w-4 h-4" />
            <span>Export Official PDF</span>
          </button>
        </div>
      </div>

      {/* Filter Ribbon */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex flex-wrap gap-4 items-center justify-between">
        {/* Date Mode Pills */}
        <div className="flex gap-1.5 p-1 bg-background border border-borderSlate rounded-xl">
          {["daily", "weekly", "monthly"].map((mode) => (
            <button
              key={mode}
              onClick={() => setDateRange(mode)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition ${
                dateRange === mode ? "bg-navy text-white shadow-sm" : "text-textSecondary hover:text-textMain"
              }`}
            >
              {mode} Report
            </button>
          ))}
        </div>

        {/* Subject & Section Filters */}
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="text-xs text-textSecondary font-medium">Subject:</span>
            <select
              value={selectedSubject}
              onChange={(e) => setSelectedSubject(e.target.value)}
              className="text-xs bg-background border border-borderSlate rounded-xl px-3 py-1.5"
            >
              <option value="All">All Subjects</option>
              <option value="IT311">IT311</option>
              <option value="IT312">IT312</option>
              <option value="IT313">IT313</option>
            </select>
          </div>

          <div className="flex items-center gap-1.5">
            <span className="text-xs text-textSecondary font-medium">Section:</span>
            <select
              value={selectedSection}
              onChange={(e) => setSelectedSection(e.target.value)}
              className="text-xs bg-background border border-borderSlate rounded-xl px-3 py-1.5"
            >
              <option value="All">All Sections</option>
              <option value="BSIT 3-A">BSIT 3-A</option>
              <option value="BSIT 3-B">BSIT 3-B</option>
            </select>
          </div>
        </div>
      </div>

      {/* Summary KPI Strip */}
      <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
        <div className="bg-white p-4 rounded-2xl border border-borderSlate">
          <span className="text-[10px] font-bold text-textSecondary uppercase">Total Records</span>
          <p className="text-xl font-extrabold text-navy mt-1">{total}</p>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-borderSlate">
          <span className="text-[10px] font-bold text-success uppercase">Present</span>
          <p className="text-xl font-extrabold text-success mt-1">{present}</p>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-borderSlate">
          <span className="text-[10px] font-bold text-warning uppercase">Late</span>
          <p className="text-xl font-extrabold text-warning mt-1">{late}</p>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-borderSlate">
          <span className="text-[10px] font-bold text-error uppercase">Absent</span>
          <p className="text-xl font-extrabold text-error mt-1">{absent}</p>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-borderSlate col-span-2 sm:col-span-1">
          <span className="text-[10px] font-bold text-primary uppercase">Attendance Rate</span>
          <p className="text-xl font-extrabold text-primary mt-1">{rate}</p>
        </div>
      </div>

      {/* Report Data Preview Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 border-b border-borderSlate flex items-center justify-between">
          <span className="text-xs font-bold text-navy">Report Records Preview ({filteredData.length})</span>
          <span className="text-[11px] text-textSecondary">
            Included in PDF & Excel generation
          </span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Student Number</th>
                <th className="px-6 py-3.5">Student Name</th>
                <th className="px-6 py-3.5">Subject</th>
                <th className="px-6 py-3.5">Section</th>
                <th className="px-6 py-3.5">Date</th>
                <th className="px-6 py-3.5">Time</th>
                <th className="px-6 py-3.5">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {filteredData.map((row, idx) => (
                <tr key={idx} className="hover:bg-background/50 transition">
                  <td className="px-6 py-4 font-mono font-bold text-primary">{row.studentNumber}</td>
                  <td className="px-6 py-4 font-bold text-navy">{row.studentName}</td>
                  <td className="px-6 py-4 font-bold">{row.subjectCode}</td>
                  <td className="px-6 py-4">{row.sectionName}</td>
                  <td className="px-6 py-4 text-textSecondary">{row.date}</td>
                  <td className="px-6 py-4 text-textSecondary">{row.time}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-block px-2.5 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider ${
                        row.status === "present"
                          ? "bg-success/15 text-success"
                          : row.status === "late"
                          ? "bg-warning/15 text-warning"
                          : row.status === "excused"
                          ? "bg-primary/15 text-primary"
                          : "bg-error/15 text-error"
                      }`}
                    >
                      {row.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
