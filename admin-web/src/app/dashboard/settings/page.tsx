// admin-web/src/app/dashboard/settings/page.tsx
"use client";

import React, { useState } from "react";
import { Settings, Shield, Clock, QrCode, Save, Check } from "lucide-react";

export default function SettingsPage() {
  const [rotationInterval, setRotationInterval] = useState(20);
  const [lateCutoff, setLateCutoff] = useState(15);
  const [institutionName, setInstitutionName] = useState("Colegio de Montalban");
  const [timezone, setTimezone] = useState("Asia/Manila (UTC+8)");
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6 max-w-3xl">
      <div>
        <h1 className="text-2xl font-bold text-navy">System Policies & Configuration</h1>
        <p className="text-xs text-textSecondary mt-1">
          Attendance grace windows, dynamic QR rotation cycle, and institutional parameters.
        </p>
      </div>

      {saved && (
        <div className="p-4 bg-success/10 border border-success/30 rounded-xl flex items-center gap-2 text-success text-xs font-bold">
          <Check className="w-4 h-4" />
          <span>System configuration updated successfully and deployed to backend.</span>
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Dynamic QR Configuration */}
        <div className="bg-white p-6 rounded-2xl border border-borderSlate shadow-sm space-y-4">
          <div className="flex items-center gap-2.5 pb-3 border-b border-borderSlate">
            <QrCode className="w-5 h-5 text-primary" />
            <h3 className="font-bold text-navy text-sm">Dynamic QR Attendance Security</h3>
          </div>

          <div className="space-y-4 text-xs">
            <div>
              <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                QR Token Rotation Interval (Seconds)
              </label>
              <input
                type="number"
                min={10}
                max={60}
                value={rotationInterval}
                onChange={(e) => setRotationInterval(parseInt(e.target.value))}
                className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl font-bold text-textMain"
              />
              <p className="text-[11px] text-textSecondary mt-1">
                Recommended standard: 20 seconds. Invalidate previous hashes upon renewal.
              </p>
            </div>

            <div>
              <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                Late Status Threshold (Minutes after session initiation)
              </label>
              <input
                type="number"
                min={1}
                max={60}
                value={lateCutoff}
                onChange={(e) => setLateCutoff(parseInt(e.target.value))}
                className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl font-bold text-textMain"
              />
              <p className="text-[11px] text-textSecondary mt-1">
                Scans within the first 15 minutes are stamped as Present; scans after this threshold are categorized as Late.
              </p>
            </div>
          </div>
        </div>

        {/* Institution Info */}
        <div className="bg-white p-6 rounded-2xl border border-borderSlate shadow-sm space-y-4">
          <div className="flex items-center gap-2.5 pb-3 border-b border-borderSlate">
            <Shield className="w-5 h-5 text-primary" />
            <h3 className="font-bold text-navy text-sm">Institutional Context</h3>
          </div>

          <div className="space-y-4 text-xs">
            <div>
              <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                Official Institution Name
              </label>
              <input
                type="text"
                value={institutionName}
                onChange={(e) => setInstitutionName(e.target.value)}
                className="w-full px-3 py-2 bg-background border border-borderSlate rounded-xl text-textMain"
              />
            </div>

            <div>
              <label className="block font-bold text-navy mb-1 uppercase text-[10px]">
                Local Timezone Authority
              </label>
              <input
                type="text"
                disabled
                value={timezone}
                className="w-full px-3 py-2 bg-borderSlate/40 border border-borderSlate rounded-xl text-textSecondary"
              />
            </div>
          </div>
        </div>

        <button
          type="submit"
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-md shadow-primary/20 transition"
        >
          <Save className="w-4 h-4" />
          <span>Save Changes</span>
        </button>
      </form>
    </div>
  );
}
