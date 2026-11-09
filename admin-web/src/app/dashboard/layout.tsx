// admin-web/src/app/dashboard/layout.tsx
"use client";

import React, { useState } from "react";
import Link from "next/navigation";
import { usePathname, useRouter } from "next/navigation";
import {
  QrCode,
  LayoutDashboard,
  Users,
  GraduationCap,
  BookOpen,
  Calendar,
  UserCheck,
  ClipboardList,
  FileBarChart,
  ShieldCheck,
  Settings,
  LogOut,
  Menu,
  X,
  Bell,
  Search,
} from "lucide-react";

const navigationItems = [
  { name: "Overview", href: "/dashboard", icon: LayoutDashboard },
  { name: "Student Management", href: "/dashboard/students", icon: GraduationCap },
  { name: "Teacher Management", href: "/dashboard/teachers", icon: Users },
  { name: "Subjects & Sections", href: "/dashboard/academics", icon: BookOpen },
  { name: "Class Schedules", href: "/dashboard/schedules", icon: Calendar },
  { name: "Enrollments", href: "/dashboard/enrollments", icon: UserCheck },
  { name: "Attendance Sessions", href: "/dashboard/attendance", icon: ClipboardList },
  { name: "Attendance Reports", href: "/dashboard/reports", icon: FileBarChart },
  { name: "Audit Logs", href: "/dashboard/audit-logs", icon: ShieldCheck },
  { name: "System Settings", href: "/dashboard/settings", icon: Settings },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    router.push("/login");
  };

  return (
    <div className="min-h-screen bg-background flex flex-col md:flex-row">
      {/* Mobile Header */}
      <div className="md:hidden bg-navy text-white px-4 py-3 flex items-center justify-between border-b border-navy-light">
        <div className="flex items-center gap-2.5">
          <div className="p-1.5 bg-primary rounded-lg">
            <QrCode className="w-5 h-5 text-white" />
          </div>
          <span className="font-bold text-base tracking-wide">MontaScan Admin</span>
        </div>
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="p-2 text-white/80 hover:text-white"
        >
          {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Sidebar Navigation */}
      <aside
        className={`fixed md:sticky top-0 left-0 z-40 h-screen w-64 bg-navy text-white flex flex-col justify-between transition-transform duration-200 ease-in-out md:translate-x-0 ${
          mobileMenuOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div>
          {/* Logo Brand */}
          <div className="p-6 border-b border-white/10 hidden md:block">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-primary rounded-xl shadow-md shadow-primary/30">
                <QrCode className="w-6 h-6 text-white" />
              </div>
              <div>
                <h2 className="font-extrabold text-lg text-white leading-tight">MontaScan</h2>
                <p className="text-xs text-white/60 font-medium">Colegio de Montalban</p>
              </div>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="p-4 space-y-1 overflow-y-auto max-h-[calc(100vh-170px)]">
            <p className="px-3 py-2 text-[10px] font-bold uppercase tracking-wider text-white/40">
              Institutional Admin
            </p>
            {navigationItems.map((item) => {
              const Icon = item.icon;
              const isActive = pathname === item.href;
              return (
                <a
                  key={item.href}
                  href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs font-semibold transition ${
                    isActive
                      ? "bg-primary text-white shadow-md shadow-primary/20"
                      : "text-white/70 hover:bg-white/10 hover:text-white"
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? "text-white" : "text-white/60"}`} />
                  <span>{item.name}</span>
                </a>
              );
            })}
          </nav>
        </div>

        {/* User Footer Card */}
        <div className="p-4 border-t border-white/10">
          <div className="flex items-center justify-between p-2.5 rounded-xl bg-white/5">
            <div className="flex items-center gap-2.5 overflow-hidden">
              <div className="w-8 h-8 rounded-lg bg-primary/20 text-primary flex items-center justify-center font-bold text-xs flex-shrink-0">
                RM
              </div>
              <div className="truncate">
                <p className="text-xs font-bold text-white truncate">Dr. Roberto Mendoza</p>
                <p className="text-[10px] text-white/50 truncate">Administrator</p>
              </div>
            </div>
            <button
              onClick={handleLogout}
              title="Sign Out"
              className="p-1.5 text-white/60 hover:text-error hover:bg-white/10 rounded-lg transition"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Navbar */}
        <header className="h-16 bg-white border-b border-borderSlate px-6 flex items-center justify-between sticky top-0 z-20">
          <div className="flex items-center gap-4">
            <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 bg-background border border-borderSlate rounded-xl w-64 md:w-80">
              <Search className="w-4 h-4 text-textSecondary" />
              <input
                type="text"
                placeholder="Search records, students, subjects..."
                className="bg-transparent border-none text-xs focus:outline-none w-full text-textMain"
              />
            </div>
          </div>

          <div className="flex items-center gap-3">
            <span className="hidden sm:inline-block px-3 py-1 bg-primary/10 text-primary text-xs font-semibold rounded-full">
              Academic Term 1 • 2026-2027
            </span>
            <button className="p-2 text-textSecondary hover:text-textMain hover:bg-background rounded-lg border border-borderSlate relative">
              <Bell className="w-4 h-4" />
              <span className="w-2 h-2 bg-error rounded-full absolute top-1.5 right-1.5" />
            </button>
          </div>
        </header>

        {/* Dynamic Page Content */}
        <main className="flex-1 p-6 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
