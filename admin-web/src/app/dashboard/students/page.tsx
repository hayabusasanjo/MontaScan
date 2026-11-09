// admin-web/src/app/dashboard/students/page.tsx
"use client";

import React, { useState } from "react";
import { Plus, Search, Filter, Edit, Trash2, User, Check, X } from "lucide-react";
import { initialStudents, MockStudent } from "@/lib/supabase";

export default function StudentManagementPage() {
  const [students, setStudents] = useState<MockStudent[]>(initialStudents);
  const [search, setSearch] = useState("");
  const [sectionFilter, setSectionFilter] = useState("All");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingStudent, setEditingStudent] = useState<MockStudent | null>(null);

  // Form states
  const [formData, setFormData] = useState({
    studentNumber: "",
    fullName: "",
    email: "",
    sectionName: "BSIT 3-A",
    yearLevel: 3,
  });

  const filteredStudents = students.filter((s) => {
    if (sectionFilter !== "All" && s.sectionName !== sectionFilter) return false;
    if (search.trim()) {
      const q = search.toLowerCase();
      return (
        s.fullName.toLowerCase().includes(q) ||
        s.studentNumber.toLowerCase().includes(q) ||
        s.email.toLowerCase().includes(q)
      );
    }
    return true;
  });

  const handleOpenModal = (student?: MockStudent) => {
    if (student) {
      setEditingStudent(student);
      setFormData({
        studentNumber: student.studentNumber,
        fullName: student.fullName,
        email: student.email,
        sectionName: student.sectionName,
        yearLevel: student.yearLevel,
      });
    } else {
      setEditingStudent(null);
      setFormData({
        studentNumber: `2024-0010${students.length + 1}`,
        fullName: "",
        email: "",
        sectionName: "BSIT 3-A",
        yearLevel: 3,
      });
    }
    setIsModalOpen(true);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingStudent) {
      setStudents(
        students.map((s) =>
          s.id === editingStudent.id ? { ...s, ...formData } : s
        )
      );
    } else {
      const newStudent: MockStudent = {
        id: `student-${Date.now()}`,
        ...formData,
      };
      setStudents([...students, newStudent]);
    }
    setIsModalOpen(false);
  };

  const handleDelete = (id: string) => {
    if (confirm("Are you sure you want to remove this student record?")) {
      setStudents(students.filter((s) => s.id !== id));
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Student Management</h1>
          <p className="text-xs text-textSecondary mt-1">
            Maintain official student roster, section placements, and profile credentials.
          </p>
        </div>
        <button
          onClick={() => handleOpenModal()}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Register New Student</span>
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex flex-col md:flex-row gap-3 items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-textSecondary absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by name, student ID, or email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-xs bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
          />
        </div>

        <div className="flex items-center gap-2 w-full md:w-auto">
          <Filter className="w-4 h-4 text-textSecondary" />
          <span className="text-xs text-textSecondary font-medium">Section:</span>
          <select
            value={sectionFilter}
            onChange={(e) => setSectionFilter(e.target.value)}
            className="text-xs bg-background border border-borderSlate rounded-xl px-3 py-2 text-textMain focus:outline-none"
          >
            <option value="All">All Sections</option>
            <option value="BSIT 3-A">BSIT 3-A</option>
            <option value="BSIT 3-B">BSIT 3-B</option>
            <option value="BSIT 2-A">BSIT 2-A</option>
            <option value="BSCS 3-A">BSCS 3-A</option>
          </select>
        </div>
      </div>

      {/* Students Data Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Student</th>
                <th className="px-6 py-3.5">Student Number</th>
                <th className="px-6 py-3.5">Section</th>
                <th className="px-6 py-3.5">Year Level</th>
                <th className="px-6 py-3.5">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {filteredStudents.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-textSecondary">
                    No students match the current criteria.
                  </td>
                </tr>
              ) : (
                filteredStudents.map((student) => (
                  <tr key={student.id} className="hover:bg-background/50 transition">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-primary/10 text-primary flex items-center justify-center font-bold text-xs">
                          {student.fullName[0]}
                        </div>
                        <div>
                          <p className="font-bold text-navy">{student.fullName}</p>
                          <p className="text-[11px] text-textSecondary">{student.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 font-mono font-bold text-primary">
                      {student.studentNumber}
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 bg-borderSlate rounded-md text-xs font-semibold text-navy">
                        {student.sectionName}
                      </span>
                    </td>
                    <td className="px-6 py-4">{student.yearLevel}rd Year</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleOpenModal(student)}
                          className="p-1.5 text-textSecondary hover:text-primary hover:bg-primary/10 rounded-lg transition"
                          title="Edit Student"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(student.id)}
                          className="p-1.5 text-textSecondary hover:text-error hover:bg-error/10 rounded-lg transition"
                          title="Delete Student"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add / Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <h3 className="font-bold text-navy text-base">
                {editingStudent ? "Edit Student Details" : "Register New Student"}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 text-textSecondary hover:text-textMain rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSave} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Student Full Name</label>
                <input
                  type="text"
                  required
                  value={formData.fullName}
                  onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                  placeholder="e.g. Juan Alvarez"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Student Number</label>
                <input
                  type="text"
                  required
                  value={formData.studentNumber}
                  onChange={(e) => setFormData({ ...formData, studentNumber: e.target.value })}
                  placeholder="2024-00101"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Institutional Email</label>
                <input
                  type="email"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="student.alvarez@cdm.edu.ph"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Section</label>
                  <select
                    value={formData.sectionName}
                    onChange={(e) => setFormData({ ...formData, sectionName: e.target.value })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none text-textMain"
                  >
                    <option value="BSIT 3-A">BSIT 3-A</option>
                    <option value="BSIT 3-B">BSIT 3-B</option>
                    <option value="BSIT 2-A">BSIT 2-A</option>
                    <option value="BSCS 3-A">BSCS 3-A</option>
                  </select>
                </div>
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Year Level</label>
                  <select
                    value={formData.yearLevel}
                    onChange={(e) => setFormData({ ...formData, yearLevel: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none text-textMain"
                  >
                    <option value={1}>1st Year</option>
                    <option value={2}>2nd Year</option>
                    <option value={3}>3rd Year</option>
                    <option value={4}>4th Year</option>
                  </select>
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 pt-4 border-t border-borderSlate">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-borderSlate rounded-xl text-textSecondary font-semibold hover:bg-background"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary hover:bg-primary-hover text-white rounded-xl font-bold shadow-md shadow-primary/20"
                >
                  Save Student
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
