// admin-web/src/app/dashboard/teachers/page.tsx
"use client";

import React, { useState } from "react";
import { Plus, Search, Edit, Trash2, BookOpen, X, Check } from "lucide-react";
import { initialTeachers, MockTeacher } from "@/lib/supabase";

export default function TeacherManagementPage() {
  const [teachers, setTeachers] = useState<MockTeacher[]>(initialTeachers);
  const [search, setSearch] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTeacher, setEditingTeacher] = useState<MockTeacher | null>(null);

  const [formData, setFormData] = useState({
    employeeNumber: "",
    fullName: "",
    email: "",
    department: "Institute of Computer Studies",
    assignedSubjects: [] as string[],
  });

  const filteredTeachers = teachers.filter((t) => {
    if (search.trim()) {
      const q = search.toLowerCase();
      return (
        t.fullName.toLowerCase().includes(q) ||
        t.employeeNumber.toLowerCase().includes(q) ||
        t.email.toLowerCase().includes(q) ||
        t.department.toLowerCase().includes(q)
      );
    }
    return true;
  });

  const handleOpenModal = (teacher?: MockTeacher) => {
    if (teacher) {
      setEditingTeacher(teacher);
      setFormData({
        employeeNumber: teacher.employeeNumber,
        fullName: teacher.fullName,
        email: teacher.email,
        department: teacher.department,
        assignedSubjects: teacher.assignedSubjects,
      });
    } else {
      setEditingTeacher(null);
      setFormData({
        employeeNumber: `EMP-2020-00${teachers.length + 1}`,
        fullName: "",
        email: "",
        department: "Institute of Computer Studies",
        assignedSubjects: ["IT312 (App Dev)"],
      });
    }
    setIsModalOpen(true);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingTeacher) {
      setTeachers(
        teachers.map((t) =>
          t.id === editingTeacher.id ? { ...t, ...formData } : t
        )
      );
    } else {
      const newTeacher: MockTeacher = {
        id: `teacher-${Date.now()}`,
        ...formData,
      };
      setTeachers([...teachers, newTeacher]);
    }
    setIsModalOpen(false);
  };

  const handleDelete = (id: string) => {
    if (confirm("Remove this faculty member from the system?")) {
      setTeachers(teachers.filter((t) => t.id !== id));
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Teacher Management</h1>
          <p className="text-xs text-textSecondary mt-1">
            Faculty accounts, employee identifiers, and assigned subject offerings.
          </p>
        </div>
        <button
          onClick={() => handleOpenModal()}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Add Faculty Member</span>
        </button>
      </div>

      {/* Search */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-textSecondary absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search faculty by name, employee ID, or department..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-xs bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Faculty Name</th>
                <th className="px-6 py-3.5">Employee ID</th>
                <th className="px-6 py-3.5">Department</th>
                <th className="px-6 py-3.5">Assigned Teaching Subjects</th>
                <th className="px-6 py-3.5">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {filteredTeachers.map((teacher) => (
                <tr key={teacher.id} className="hover:bg-background/50 transition">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-navy/10 text-navy flex items-center justify-center font-bold text-xs">
                        {teacher.fullName[0]}
                      </div>
                      <div>
                        <p className="font-bold text-navy">{teacher.fullName}</p>
                        <p className="text-[11px] text-textSecondary">{teacher.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-mono font-bold text-navy">
                    {teacher.employeeNumber}
                  </td>
                  <td className="px-6 py-4">{teacher.department}</td>
                  <td className="px-6 py-4">
                    <div className="flex flex-wrap gap-1.5">
                      {teacher.assignedSubjects.map((sub, idx) => (
                        <span
                          key={idx}
                          className="px-2 py-0.5 bg-primary/10 text-primary rounded-md text-[11px] font-semibold"
                        >
                          {sub}
                        </span>
                      ))}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleOpenModal(teacher)}
                        className="p-1.5 text-textSecondary hover:text-primary hover:bg-primary/10 rounded-lg transition"
                        title="Edit Teacher"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(teacher.id)}
                        className="p-1.5 text-textSecondary hover:text-error hover:bg-error/10 rounded-lg transition"
                        title="Delete Teacher"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <h3 className="font-bold text-navy text-base">
                {editingTeacher ? "Edit Faculty Profile" : "Register Faculty Member"}
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
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Full Name</label>
                <input
                  type="text"
                  required
                  value={formData.fullName}
                  onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                  placeholder="e.g. Engr. Maria Santos"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Employee Number</label>
                <input
                  type="text"
                  required
                  value={formData.employeeNumber}
                  onChange={(e) => setFormData({ ...formData, employeeNumber: e.target.value })}
                  placeholder="EMP-2018-0042"
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
                  placeholder="prof.santos@cdm.edu.ph"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Academic Department</label>
                <input
                  type="text"
                  required
                  value={formData.department}
                  onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl focus:outline-none focus:border-primary text-textMain"
                />
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
                  Save Faculty
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
