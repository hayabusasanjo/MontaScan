// admin-web/src/app/dashboard/audit-logs/page.tsx
"use client";

import React, { useState } from "react";
import { ShieldCheck, Search, Filter, Clock, UserCheck } from "lucide-react";
import { initialAuditLogs, MockAuditLog } from "@/lib/supabase";

export default function AuditLogsPage() {
  const [logs] = useState<MockAuditLog[]>(initialAuditLogs);
  const [search, setSearch] = useState("");

  const filtered = logs.filter((log) => {
    if (search.trim()) {
      const q = search.toLowerCase();
      return (
        log.actorName.toLowerCase().includes(q) ||
        log.action.toLowerCase().includes(q) ||
        log.reason.toLowerCase().includes(q)
      );
    }
    return true;
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-navy">System Audit Trail</h1>
        <p className="text-xs text-textSecondary mt-1">
          Cryptographically consistent and immutable audit log for manual corrections and administrative actions.
        </p>
      </div>

      {/* Search */}
      <div className="bg-white p-4 rounded-2xl border border-borderSlate shadow-sm flex items-center justify-between">
        <div className="relative w-full md:w-80">
          <Search className="w-4 h-4 text-textSecondary absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search audit actions, actors, reasons..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-xs bg-background border border-borderSlate rounded-xl focus:outline-none"
          />
        </div>
      </div>

      {/* Table */}
      <div className="bg-white border border-borderSlate rounded-2xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-background border-b border-borderSlate text-textSecondary uppercase font-bold tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Timestamp</th>
                <th className="px-6 py-3.5">Actor</th>
                <th className="px-6 py-3.5">Action Event</th>
                <th className="px-6 py-3.5">Entity</th>
                <th className="px-6 py-3.5">Mandatory Justification / Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderSlate font-medium text-textMain">
              {filtered.map((log) => (
                <tr key={log.id} className="hover:bg-background/50 transition">
                  <td className="px-6 py-4 text-textSecondary font-mono">{log.timestamp}</td>
                  <td className="px-6 py-4 font-bold text-navy">{log.actorName}</td>
                  <td className="px-6 py-4">
                    <span className="px-2.5 py-1 bg-navy/10 text-navy rounded-md font-bold text-[11px]">
                      {log.action}
                    </span>
                  </td>
                  <td className="px-6 py-4 font-mono text-[11px] text-textSecondary">{log.entityType}</td>
                  <td className="px-6 py-4 text-textMain font-medium">{log.reason}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
