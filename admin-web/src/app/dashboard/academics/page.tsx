// admin-web/src/app/dashboard/academics/page.tsx
"use client";

import React, { useState } from "react";
import { Plus, BookOpen, Layers, Edit, Trash2, X } from "lucide-react";
import { initialSubjects, initialSections, MockSubject, MockSection } from "@/lib/supabase";

export default function AcademicsPage() {
  const [activeTab, setActiveTab] = useState<"subjects" | "sections">("subjects");
  const [subjects, setSubjects] = useState<MockSubject[]>(initialSubjects);
  const [sections, setSections] = useState<MockSection[]>(initialSections);

  // Modal states
  const [isSubjectModal, setIsSubjectModal] = useState(false);
  const [isSectionModal, setIsSectionModal] = useState(false);

  const [subjectForm, setSubjectForm] = useState({ code: "", name: "", units: 3, description: "" });
  const [sectionForm, setSectionForm] = useState({ name: "", yearLevel: 3, studentCount: 0 });

  const handleSaveSubject = (e: React.FormEvent) => {
    e.preventDefault();
    setSubjects([...subjects, { id: `subj-${Date.now()}`, ...subjectForm }]);
    setIsSubjectModal(false);
    setSubjectForm({ code: "", name: "", units: 3, description: "" });
  };

  const handleSaveSection = (e: React.FormEvent) => {
    e.preventDefault();
    setSections([...sections, { id: `sec-${Date.now()}`, ...sectionForm }]);
    setIsSectionModal(false);
    setSectionForm({ name: "", yearLevel: 3, studentCount: 0 });
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Curricular Structure</h1>
          <p className="text-xs text-textSecondary mt-1">
            Course curriculum units, credit units, and student cohort sections.
          </p>
        </div>

        <button
          onClick={() => (activeTab === "subjects" ? setIsSubjectModal(true) : setIsSectionModal(true))}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>{activeTab === "subjects" ? "Add Subject Offering" : "Create New Section"}</span>
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-borderSlate">
        <button
          onClick={() => setActiveTab("subjects")}
          className={`flex items-center gap-2 px-5 py-3 text-xs font-bold border-b-2 transition ${
            activeTab === "subjects"
              ? "border-primary text-primary"
              : "border-transparent text-textSecondary hover:text-textMain"
          }`}
        >
          <BookOpen className="w-4 h-4" />
          <span>Subjects ({subjects.length})</span>
        </button>
        <button
          onClick={() => setActiveTab("sections")}
          className={`flex items-center gap-2 px-5 py-3 text-xs font-bold border-b-2 transition ${
            activeTab === "sections"
              ? "border-primary text-primary"
              : "border-transparent text-textSecondary hover:text-textMain"
          }`}
        >
          <Layers className="w-4 h-4" />
          <span>Sections ({sections.length})</span>
        </button>
      </div>

      {/* Tab Content */}
      {activeTab === "subjects" ? (
        <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
                <tr>
                  <th className="px-6 py-3.5">Subject Code</th>
                  <th className="px-6 py-3.5">Subject Description / Title</th>
                  <th className="px-6 py-3.5">Units</th>
                  <th className="px-6 py-3.5">Syllabus Overview</th>
                  <th className="px-6 py-3.5">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-borderSlate font-medium text-textMain">
                {subjects.map((sub) => (
                  <tr key={sub.id} className="hover:bg-background/50 transition">
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 bg-primary/10 text-primary rounded-md font-bold text-xs">
                        {sub.code}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-bold text-navy">{sub.name}</td>
                    <td className="px-6 py-4">{sub.units} Credits</td>
                    <td className="px-6 py-4 text-textSecondary">{sub.description}</td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => setSubjects(subjects.filter((s) => s.id !== sub.id))}
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
      ) : (
        <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
                <tr>
                  <th className="px-6 py-3.5">Section Name</th>
                  <th className="px-6 py-3.5">Year Level</th>
                  <th className="px-6 py-3.5">Enrolled Student Count</th>
                  <th className="px-6 py-3.5">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-borderSlate font-medium text-textMain">
                {sections.map((sec) => (
                  <tr key={sec.id} className="hover:bg-background/50 transition">
                    <td className="px-6 py-4 font-bold text-navy text-sm">{sec.name}</td>
                    <td className="px-6 py-4">{sec.yearLevel}rd Year</td>
                    <td className="px-6 py-4 font-bold text-primary">{sec.studentCount} Students</td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => setSections(sections.filter((s) => s.id !== sec.id))}
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
      )}

      {/* Subject Modal */}
      {isSubjectModal && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <h3 className="font-bold text-navy text-base">Add Subject Offering</h3>
              <button onClick={() => setIsSubjectModal(false)} className="p-1 text-textSecondary hover:text-textMain">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleSaveSubject} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Subject Code</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. IT315"
                  value={subjectForm.code}
                  onChange={(e) => setSubjectForm({ ...subjectForm, code: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Subject Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Cloud Architecture and Services"
                  value={subjectForm.name}
                  onChange={(e) => setSubjectForm({ ...subjectForm, name: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Credit Units</label>
                <input
                  type="number"
                  min={1}
                  max={6}
                  required
                  value={subjectForm.units}
                  onChange={(e) => setSubjectForm({ ...subjectForm, units: parseInt(e.target.value) })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Description</label>
                <textarea
                  rows={2}
                  value={subjectForm.description}
                  onChange={(e) => setSubjectForm({ ...subjectForm, description: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-borderSlate">
                <button
                  type="button"
                  onClick={() => setIsSubjectModal(false)}
                  className="px-4 py-2 border border-borderSlate rounded-xl text-textSecondary font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary hover:bg-primary-hover text-white rounded-xl font-bold shadow-md shadow-primary/20"
                >
                  Save Subject
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Section Modal */}
      {isSectionModal && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <h3 className="font-bold text-navy text-base">Create Section</h3>
              <button onClick={() => setIsSectionModal(false)} className="p-1 text-textSecondary hover:text-textMain">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleSaveSection} className="space-y-4 text-xs">
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Section Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. BSIT 3-C"
                  value={sectionForm.name}
                  onChange={(e) => setSectionForm({ ...sectionForm, name: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Year Level</label>
                <select
                  value={sectionForm.yearLevel}
                  onChange={(e) => setSectionForm({ ...sectionForm, yearLevel: parseInt(e.target.value) })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                >
                  <option value={1}>1st Year</option>
                  <option value={2}>2nd Year</option>
                  <option value={3}>3rd Year</option>
                  <option value={4}>4th Year</option>
                </select>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t border-borderSlate">
                <button
                  type="button"
                  onClick={() => setIsSectionModal(false)}
                  className="px-4 py-2 border border-borderSlate rounded-xl text-textSecondary font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary hover:bg-primary-hover text-white rounded-xl font-bold shadow-md shadow-primary/20"
                >
                  Save Section
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
