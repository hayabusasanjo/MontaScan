// admin-web/src/app/dashboard/enrollments/page.tsx
"use client";

import React, { useState } from "react";
import { UserCheck, Search, Plus, Trash2, CheckCircle2 } from "lucide-react";
import { initialStudents, initialSubjects } from "@/lib/supabase";

interface EnrollmentItem {
  id: string;
  studentNumber: string;
  studentName: string;
  subjectCode: string;
  subjectName: string;
  sectionName: string;
  enrolledDate: string;
}

const initialEnrollmentList: EnrollmentItem[] = [
  { id: "1", studentNumber: "2024-00101", studentName: "Juan Alvarez", subjectCode: "IT312", subjectName: "App Development", sectionName: "BSIT 3-A", enrolledDate: "2026-11-01" },
  { id: "2", studentNumber: "2024-00101", studentName: "Juan Alvarez", subjectCode: "IT311", subjectName: "Systems Integration", sectionName: "BSIT 3-A", enrolledDate: "2026-11-01" },
  { id: "3", studentNumber: "2024-00102", studentName: "Beatrice Bernardo", subjectCode: "IT312", subjectName: "App Development", sectionName: "BSIT 3-A", enrolledDate: "2026-11-01" },
  { id: "4", studentNumber: "2024-00103", studentName: "Christian Cruz", subjectCode: "IT312", subjectName: "App Development", sectionName: "BSIT 3-A", enrolledDate: "2026-11-01" },
  { id: "5", studentNumber: "2024-00104", studentName: "Diana Dela Rosa", subjectCode: "IT312", subjectName: "App Development", sectionName: "BSIT 3-A", enrolledDate: "2026-11-01" },
  { id: "6", studentNumber: "2024-00105", studentName: "Ethan Espinosa", subjectCode: "IT314", subjectName: "Web Systems 2", sectionName: "BSIT 3-B", enrolledDate: "2026-11-01" },
];

export default function EnrollmentsPage() {
  const [enrollments, setEnrollments] = useState<EnrollmentItem[]>(initialEnrollmentList);
  const [search, setSearch] = useState("");
  const [subjectFilter, setSubjectFilter] = useState("All");

  const filtered = enrollments.filter((e) => {
    if (subjectFilter !== "All" && e.subjectCode !== subjectFilter) return false;
    if (search.trim()) {
      const q = search.toLowerCase();
      return e.studentName.toLowerCase().includes(q) || e.studentNumber.includes(q);
    }
    return true;
  });

  const handleDelete = (id: string) => {
    if (confirm("Revoke this subject enrollment?")) {
      setEnrollments(enrollments.filter((e) => e.id !== id));
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Enrollment Roster Management</h1>
          <p className="text-xs text-textSecondary mt-1">
            Authorizes student QR scan eligibility for specific class offerings.
          </p>
        </div>
      </div>

      {/* Filter and Search */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-textSecondary absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search enrolled students..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-xs bg-background border border-borderSlate rounded-xl focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-textSecondary font-medium">Filter Subject:</span>
          <select
            value={subjectFilter}
            onChange={(e) => setSubjectFilter(e.target.value)}
            className="text-xs bg-background border border-borderSlate rounded-xl px-3 py-2"
          >
            <option value="All">All Subjects</option>
            <option value="IT311">IT311</option>
            <option value="IT312">IT312</option>
            <option value="IT314">IT314</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Student</th>
                <th className="px-6 py-3.5">Student ID</th>
                <th className="px-6 py-3.5">Enrolled Subject</th>
                <th className="px-6 py-3.5">Section</th>
                <th className="px-6 py-3.5">Date Enrolled</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {filtered.map((item) => (
                <tr key={item.id} className="hover:bg-background/50 transition">
                  <td className="px-6 py-4 font-bold text-navy">{item.studentName}</td>
                  <td className="px-6 py-4 font-mono font-bold text-primary">{item.studentNumber}</td>
                  <td className="px-6 py-4">
                    <span className="font-bold text-navy">{item.subjectCode}</span> - {item.subjectName}
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-0.5 bg-borderSlate rounded text-[11px] font-bold">
                      {item.sectionName}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-textSecondary">{item.enrolledDate}</td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center gap-1 text-success font-bold text-[11px]">
                      <CheckCircle2 className="w-3.5 h-3.5" /> Enrolled
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={() => handleDelete(item.id)}
                      className="p-1.5 text-textSecondary hover:text-error hover:bg-error/10 rounded-lg transition"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
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
