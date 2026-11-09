// admin-web/src/app/dashboard/schedules/page.tsx
"use client";

import React, { useState } from "react";
import { Plus, Calendar, Clock, MapPin, Trash2, X } from "lucide-react";

interface ScheduleItem {
  id: string;
  subjectCode: string;
  subjectName: string;
  sectionName: string;
  teacherName: string;
  dayOfWeek: string;
  startTime: string;
  endTime: string;
  room: string;
}

const initialScheduleList: ScheduleItem[] = [
  { id: "1", subjectCode: "IT312", subjectName: "App Development", sectionName: "BSIT 3-A", teacherName: "Engr. Maria Santos", dayOfWeek: "Monday", startTime: "08:00 AM", endTime: "11:00 AM", room: "ComLab 3" },
  { id: "2", subjectCode: "IT311", subjectName: "Systems Integration", sectionName: "BSIT 3-A", teacherName: "Engr. Maria Santos", dayOfWeek: "Wednesday", startTime: "01:00 PM", endTime: "04:00 PM", room: "ComLab 1" },
  { id: "3", subjectCode: "IT313", subjectName: "Information Assurance", sectionName: "BSIT 3-A", teacherName: "Prof. Carlos Reyes", dayOfWeek: "Friday", startTime: "09:00 AM", endTime: "12:00 PM", room: "Room 304" },
  { id: "4", subjectCode: "IT314", subjectName: "Web Systems 2", sectionName: "BSIT 3-B", teacherName: "Prof. Carlos Reyes", dayOfWeek: "Tuesday", startTime: "10:00 AM", endTime: "01:00 PM", room: "ComLab 2" },
];

export default function SchedulesPage() {
  const [schedules, setSchedules] = useState<ScheduleItem[]>(initialScheduleList);
  const [dayFilter, setDayFilter] = useState("All");
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [formData, setFormData] = useState({
    subjectCode: "IT312",
    subjectName: "Application Development and Emerging Technologies",
    sectionName: "BSIT 3-A",
    teacherName: "Engr. Maria Santos",
    dayOfWeek: "Monday",
    startTime: "08:00 AM",
    endTime: "11:00 AM",
    room: "ComLab 3",
  });

  const filtered = schedules.filter((s) => (dayFilter === "All" ? true : s.dayOfWeek === dayFilter));

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSchedules([...schedules, { id: `sched-${Date.now()}`, ...formData }]);
    setIsModalOpen(false);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-navy">Class Schedules Timetable</h1>
          <p className="text-xs text-textSecondary mt-1">
            Master room allocation, day of week, and course class periods.
          </p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Add Timetable Schedule</span>
        </button>
      </div>

      {/* Filter by Day */}
      <div className="flex gap-2 overflow-x-auto pb-1">
        {["All", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"].map((day) => (
          <button
            key={day}
            onClick={() => setDayFilter(day)}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition ${
              dayFilter === day
                ? "bg-navy text-white"
                : "bg-white text-textSecondary border border-borderSlate hover:bg-background"
            }`}
          >
            {day}
          </button>
        ))}
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filtered.map((item) => (
          <div key={item.id} className="bg-white p-5 rounded-2xl border border-borderSlate shadow-sm">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <span className="px-2 py-0.5 bg-primary/10 text-primary text-xs font-bold rounded">
                    {item.subjectCode}
                  </span>
                  <span className="font-bold text-navy text-sm">{item.sectionName}</span>
                </div>
                <h3 className="font-bold text-sm text-textMain mt-1.5">{item.subjectName}</h3>
                <p className="text-xs text-textSecondary mt-0.5">Faculty: {item.teacherName}</p>
              </div>

              <span className="px-2.5 py-1 bg-borderSlate text-navy rounded-lg text-xs font-bold">
                {item.dayOfWeek}
              </span>
            </div>

            <div className="mt-4 pt-3 border-t border-borderSlate flex items-center justify-between text-xs text-textSecondary">
              <div className="flex items-center gap-1.5">
                <Clock className="w-3.5 h-3.5 text-primary" />
                <span>{item.startTime} - {item.endTime}</span>
              </div>
              <div className="flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-navy" />
                <span className="font-bold text-textMain">{item.room}</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-navy/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl border border-borderSlate shadow-xl max-w-md w-full p-6 text-xs">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-borderSlate">
              <h3 className="font-bold text-navy text-base">Add Class Schedule</h3>
              <button onClick={() => setIsModalOpen(false)} className="p-1 text-textSecondary">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={handleSave} className="space-y-3">
              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Subject Offering</label>
                <select
                  value={formData.subjectCode}
                  onChange={(e) => setFormData({ ...formData, subjectCode: e.target.value })}
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                >
                  <option value="IT311">IT311 - Systems Integration</option>
                  <option value="IT312">IT312 - App Development</option>
                  <option value="IT313">IT313 - Info Assurance</option>
                  <option value="IT314">IT314 - Web Systems 2</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Section</label>
                  <select
                    value={formData.sectionName}
                    onChange={(e) => setFormData({ ...formData, sectionName: e.target.value })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                  >
                    <option value="BSIT 3-A">BSIT 3-A</option>
                    <option value="BSIT 3-B">BSIT 3-B</option>
                  </select>
                </div>
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Day of Week</label>
                  <select
                    value={formData.dayOfWeek}
                    onChange={(e) => setFormData({ ...formData, dayOfWeek: e.target.value })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                  >
                    <option value="Monday">Monday</option>
                    <option value="Tuesday">Tuesday</option>
                    <option value="Wednesday">Wednesday</option>
                    <option value="Thursday">Thursday</option>
                    <option value="Friday">Friday</option>
                    <option value="Saturday">Saturday</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Start Time</label>
                  <input
                    type="text"
                    value={formData.startTime}
                    onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                  />
                </div>
                <div>
                  <label className="block font-bold text-navy mb-1 uppercase text-[10px]">End Time</label>
                  <input
                    type="text"
                    value={formData.endTime}
                    onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
                    className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                  />
                </div>
              </div>

              <div>
                <label className="block font-bold text-navy mb-1 uppercase text-[10px]">Room / Laboratory</label>
                <input
                  type="text"
                  value={formData.room}
                  onChange={(e) => setFormData({ ...formData, room: e.target.value })}
                  placeholder="e.g. ComLab 3"
                  className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl"
                />
              </div>

              <div className="flex justify-end gap-2 pt-4 border-t border-borderSlate">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-borderSlate rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary text-white rounded-xl font-bold"
                >
                  Save Schedule
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
