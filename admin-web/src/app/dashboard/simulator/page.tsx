// admin-web/src/app/dashboard/simulator/page.tsx
"use client";

import React, { useState, useEffect, useRef } from "react";
import QRCode from "qrcode";
import {
  QrCode,
  Smartphone,
  Tv,
  Users,
  CheckCircle2,
  Clock,
  AlertTriangle,
  RotateCcw,
  Check,
  X,
  Play,
  Square,
  Sparkles,
  ShieldCheck,
  Edit3,
} from "lucide-react";

interface Attendee {
  id: string;
  studentNumber: string;
  name: string;
  section: string;
  time: string;
  status: "present" | "late";
}

interface StudentOption {
  id: string;
  name: string;
  studentNumber: string;
  section: string;
  isEnrolled: boolean;
}

const studentsList: StudentOption[] = [
  { id: "1", name: "Juan Alvarez", studentNumber: "2024-00101", section: "BSIT 3-A", isEnrolled: true },
  { id: "2", name: "Beatrice Bernardo", studentNumber: "2024-00102", section: "BSIT 3-A", isEnrolled: true },
  { id: "3", name: "Christian Cruz", studentNumber: "2024-00103", section: "BSIT 3-A", isEnrolled: true },
  { id: "4", name: "Diana Dela Rosa", studentNumber: "2024-00104", section: "BSIT 3-A", isEnrolled: true },
  { id: "5", name: "Ethan Espinosa", studentNumber: "2024-00105", section: "BSIT 3-B", isEnrolled: false },
];

export default function DynamicQrSimulatorPage() {
  // Session State
  const [isSessionActive, setIsSessionActive] = useState(true);
  const [sessionId] = useState("sess-cdm-it312-" + Date.now().toString().slice(-4));
  const [countdown, setCountdown] = useState(20);
  const [tokenCounter, setTokenCounter] = useState(1);
  const [currentToken, setCurrentToken] = useState("token-init-" + Math.random().toString(36).substring(2, 10));
  const [qrDataUrl, setQrDataUrl] = useState("");
  const [tokenHash, setTokenHash] = useState("");

  // Attendees list
  const [attendees, setAttendees] = useState<Attendee[]>([
    { id: "rec-1", studentNumber: "2024-00098", name: "Gabriel Navarro", section: "BSIT 3-A", time: "08:01:14 AM", status: "present" },
    { id: "rec-2", studentNumber: "2024-00099", name: "Hannah Mendoza", section: "BSIT 3-A", time: "08:02:40 AM", status: "present" },
  ]);

  // Student Scan Simulator State
  const [selectedStudent, setSelectedStudent] = useState<StudentOption>(studentsList[0]);
  const [scanStatus, setScanStatus] = useState<"idle" | "scanning" | "success" | "error">("idle");
  const [scanMessage, setScanMessage] = useState("");
  const [lastScannedRecord, setLastScannedRecord] = useState<Attendee | null>(null);

  // Audio Beep generator using Web Audio API
  const playSound = (isSuccess: boolean) => {
    try {
      const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.connect(gain);
      gain.connect(audioCtx.destination);

      if (isSuccess) {
        osc.frequency.setValueAtTime(587.33, audioCtx.currentTime); // D5
        osc.frequency.setValueAtTime(880, audioCtx.currentTime + 0.1); // A5
        gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.35);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.35);
      } else {
        osc.frequency.setValueAtTime(220, audioCtx.currentTime);
        osc.frequency.setValueAtTime(160, audioCtx.currentTime + 0.15);
        gain.gain.setValueAtTime(0.2, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.4);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.4);
      }
    } catch {
      // AudioContext not allowed or not supported in environment
    }
  };

  // Generate QR code whenever token changes
  useEffect(() => {
    if (!isSessionActive) {
      setQrDataUrl("");
      return;
    }

    const payload = JSON.stringify({
      v: 1,
      sid: sessionId,
      t: currentToken,
      ts: Date.now(),
    });

    // Compute simple mock SHA-256 preview
    const hashPreview = "sha256_" + Math.random().toString(36).substring(2, 12);
    setTokenHash(hashPreview);

    QRCode.toDataURL(payload, {
      width: 280,
      margin: 2,
      color: {
        dark: "#172554", // Navy
        light: "#FFFFFF",
      },
    }).then(setQrDataUrl);
  }, [currentToken, isSessionActive, sessionId]);

  // 20-second countdown rotation loop
  useEffect(() => {
    if (!isSessionActive) return;

    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          // Rotate token
          setCurrentToken("token-rot-" + Math.random().toString(36).substring(2, 10));
          setTokenCounter((c) => c + 1);
          return 20;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isSessionActive]);

  // Student Scan Action Handler
  const handleStudentScan = () => {
    if (!isSessionActive) {
      playSound(false);
      setScanStatus("error");
      setScanMessage("SESSION_CLOSED: The instructor has closed this attendance roll call.");
      return;
    }

    setScanStatus("scanning");

    setTimeout(() => {
      // 1. Enrollment check
      if (!selectedStudent.isEnrolled) {
        playSound(false);
        setScanStatus("error");
        setScanMessage(`NOT_ENROLLED: ${selectedStudent.name} (${selectedStudent.studentNumber}) is not enrolled in BSIT 3-A: IT312.`);
        return;
      }

      // 2. Duplicate check
      const alreadyCheckedIn = attendees.some((a) => a.studentNumber === selectedStudent.studentNumber);
      if (alreadyCheckedIn) {
        playSound(false);
        setScanStatus("error");
        setScanMessage(`DUPLICATE_SCAN: Attendance for ${selectedStudent.name} has already been registered for today's session.`);
        return;
      }

      // 3. Success check-in!
      playSound(true);
      const newRecord: Attendee = {
        id: `rec-${Date.now()}`,
        studentNumber: selectedStudent.studentNumber,
        name: selectedStudent.name,
        section: selectedStudent.section,
        time: new Date().toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", second: "2-digit" }),
        status: "present",
      };

      setAttendees((prev) => [newRecord, ...prev]);
      setLastScannedRecord(newRecord);
      setScanStatus("success");
      setScanMessage("Attendance verified and registered atomically in PostgreSQL!");
    }, 450);
  };

  const totalEnrolled = 35;
  const currentTotal = attendees.length;
  const progressPercent = Math.round((currentTotal / totalEnrolled) * 100);

  return (
    <div className="space-y-6">
      {/* Title */}
      <div>
        <div className="flex items-center gap-2">
          <span className="px-2.5 py-0.5 bg-primary/10 text-primary text-xs font-bold rounded-md uppercase">
            Interactive Classroom Lab
          </span>
          <span className="text-xs text-success font-semibold flex items-center gap-1">
            <span className="w-2 h-2 rounded-full bg-success animate-ping" /> Live Realtime Simulation
          </span>
        </div>
        <h1 className="text-2xl font-bold text-navy mt-1">Dynamic QR Attendance & Scanner Simulator</h1>
        <p className="text-xs text-textSecondary mt-0.5">
          Experience the live 20-second dynamic QR token rotation (Teacher screen) side-by-side with student check-in submissions.
        </p>
      </div>

      {/* Split Classroom View: Teacher (Left) & Student (Right) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* ======================================================== */}
        {/* TEACHER SCREEN (Left: 7 Cols)                            */}
        {/* ======================================================== */}
        <div className="lg:col-span-7 bg-white rounded-2xl border border-borderSlate shadow-sm overflow-hidden">
          {/* Header */}
          <div className="p-4 bg-navy text-white flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <Tv className="w-5 h-5 text-primary" />
              <div>
                <p className="font-bold text-sm tracking-wide">Teacher Classroom Projector Display</p>
                <p className="text-[11px] text-white/60">IT312 • BSIT 3-A • Engr. Maria Santos</p>
              </div>
            </div>

            <button
              onClick={() => setIsSessionActive(!isSessionActive)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition ${
                isSessionActive
                  ? "bg-error text-white hover:bg-error/90"
                  : "bg-success text-white hover:bg-success/90"
              }`}
            >
              {isSessionActive ? (
                <>
                  <Square className="w-3.5 h-3.5" /> End Roll Call
                </>
              ) : (
                <>
                  <Play className="w-3.5 h-3.5" /> Start New Roll Call
                </>
              )}
            </button>
          </div>

          <div className="p-6">
            {isSessionActive ? (
              <div className="flex flex-col md:flex-row items-center gap-8 justify-center">
                {/* QR Code Container */}
                <div className="flex flex-col items-center">
                  <div className="p-3 bg-white border-2 border-navy/20 rounded-2xl shadow-md relative">
                    {qrDataUrl ? (
                      <img src={qrDataUrl} alt="Classroom Dynamic QR" className="w-56 h-56 rounded-xl" />
                    ) : (
                      <div className="w-56 h-56 flex items-center justify-center text-xs text-textSecondary">
                        Generating QR...
                      </div>
                    )}
                    <div className="absolute -bottom-2 -right-2 px-2 py-0.5 bg-primary text-white text-[10px] font-bold rounded shadow">
                      #{tokenCounter}
                    </div>
                  </div>

                  <p className="text-[11px] text-textSecondary font-mono mt-2">
                    Hash: <span className="font-bold text-navy">{tokenHash}</span>
                  </p>
                </div>

                {/* 20-Second Dynamic Countdown Ring */}
                <div className="flex flex-col items-center justify-center">
                  <div className="relative w-28 h-28 flex items-center justify-center">
                    <svg className="w-full h-full transform -rotate-90">
                      <circle
                        cx="56"
                        cy="56"
                        r="46"
                        stroke="#E2E8F0"
                        strokeWidth="8"
                        fill="transparent"
                      />
                      <circle
                        cx="56"
                        cy="56"
                        r="46"
                        stroke={countdown <= 5 ? "#DC2626" : "#2563EB"}
                        strokeWidth="8"
                        strokeDasharray={289}
                        strokeDashoffset={289 - (289 * countdown) / 20}
                        strokeLinecap="round"
                        fill="transparent"
                        className="transition-all duration-1000 ease-linear"
                      />
                    </svg>
                    <div className="absolute flex flex-col items-center">
                      <span className={`text-3xl font-extrabold ${countdown <= 5 ? "text-error" : "text-navy"}`}>
                        {countdown}s
                      </span>
                      <span className="text-[9px] uppercase font-bold text-textSecondary tracking-wider">
                        Valid
                      </span>
                    </div>
                  </div>

                  <div className="mt-3 text-center">
                    <p className="text-xs font-bold text-navy">Dynamic Token Rotation</p>
                    <p className="text-[11px] text-textSecondary">Rotates every 20s to stop screenshots</p>
                  </div>
                </div>
              </div>
            ) : (
              <div className="py-12 text-center">
                <div className="w-14 h-14 rounded-2xl bg-borderSlate flex items-center justify-center mx-auto text-textSecondary mb-3">
                  <Square className="w-6 h-6" />
                </div>
                <h3 className="font-bold text-base text-navy">Attendance Session Closed</h3>
                <p className="text-xs text-textSecondary mt-1">
                  Click "Start New Roll Call" to begin rotating dynamic QR tokens.
                </p>
              </div>
            )}

            {/* Attendance Progress Bar */}
            <div className="mt-6 pt-6 border-t border-borderSlate">
              <div className="flex items-center justify-between text-xs mb-2">
                <span className="font-bold text-navy">
                  Class Check-in Progress: {currentTotal} / {totalEnrolled} Enrolled Students
                </span>
                <span className="font-extrabold text-primary">{progressPercent}%</span>
              </div>
              <div className="w-full h-2.5 bg-background border border-borderSlate rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-primary to-success transition-all duration-500 rounded-full"
                  style={{ width: `${progressPercent}%` }}
                />
              </div>
            </div>

            {/* Live Attendee Stream */}
            <div className="mt-6">
              <div className="flex items-center justify-between mb-3">
                <h4 className="font-bold text-xs text-navy uppercase tracking-wider">
                  Live Attendance Check-ins ({attendees.length})
                </h4>
                <span className="text-[11px] text-success font-bold flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5" /> Instant PostgreSQL Sync
                </span>
              </div>

              <div className="border border-borderSlate rounded-xl overflow-hidden max-h-48 overflow-y-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-background text-textSecondary text-[10px] font-bold uppercase tracking-wider">
                    <tr>
                      <th className="px-4 py-2">Student</th>
                      <th className="px-4 py-2">Student ID</th>
                      <th className="px-4 py-2">Time</th>
                      <th className="px-4 py-2">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-borderSlate font-medium">
                    {attendees.map((a) => (
                      <tr key={a.id} className="hover:bg-background/50">
                        <td className="px-4 py-2.5 font-bold text-navy">{a.name}</td>
                        <td className="px-4 py-2.5 font-mono text-primary font-bold">{a.studentNumber}</td>
                        <td className="px-4 py-2.5 text-textSecondary">{a.time}</td>
                        <td className="px-4 py-2.5">
                          <span className="px-2 py-0.5 bg-success/15 text-success rounded-full text-[10px] font-bold uppercase">
                            {a.status}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        {/* ======================================================== */}
        {/* STUDENT SMARTPHONE SIMULATOR (Right: 5 Cols)             */}
        {/* ======================================================== */}
        <div className="lg:col-span-5 bg-white rounded-3xl border-4 border-navy/90 shadow-2xl p-4 overflow-hidden relative">
          {/* Phone Top Notch */}
          <div className="w-28 h-4 bg-navy rounded-b-xl mx-auto -mt-4 mb-4" />

          {/* Phone Header */}
          <div className="flex items-center justify-between pb-3 border-b border-borderSlate mb-4">
            <div className="flex items-center gap-2">
              <div className="p-1.5 bg-primary rounded-lg text-white">
                <Smartphone className="w-4 h-4" />
              </div>
              <div>
                <p className="font-extrabold text-xs text-navy leading-tight">MontaScan Mobile</p>
                <p className="text-[10px] text-textSecondary">Student Scanner Client</p>
              </div>
            </div>
            <span className="px-2 py-0.5 bg-primary/10 text-primary text-[10px] font-bold rounded-md">
              Colegio de Montalban
            </span>
          </div>

          {/* Student Profile Switcher */}
          <div className="p-3 bg-background border border-borderSlate rounded-xl mb-4">
            <label className="block text-[10px] font-bold text-textSecondary uppercase tracking-wider mb-1">
              Test As Student:
            </label>
            <select
              value={selectedStudent.id}
              onChange={(e) => {
                const s = studentsList.find((x) => x.id === e.target.value);
                if (s) {
                  setSelectedStudent(s);
                  setScanStatus("idle");
                  setScanMessage("");
                }
              }}
              className="w-full text-xs font-bold bg-white border border-borderSlate rounded-lg px-2.5 py-2 text-navy focus:outline-none focus:border-primary"
            >
              {studentsList.map((st) => (
                <option key={st.id} value={st.id}>
                  {st.name} ({st.studentNumber}) {st.isEnrolled ? "• BSIT 3-A" : "• (NOT ENROLLED)"}
                </option>
              ))}
            </select>
          </div>

          {/* Camera Viewfinder Simulation */}
          <div className="aspect-square bg-slate-900 rounded-2xl relative flex flex-col items-center justify-center p-4 overflow-hidden mb-4 border-2 border-navy">
            {/* Camera Reticle */}
            <div className="w-44 h-44 border-2 border-primary/60 rounded-2xl relative flex items-center justify-center">
              <div className="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-primary" />
              <div className="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-primary" />
              <div className="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-primary" />
              <div className="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-primary" />

              {/* Animated Laser Scanning Line */}
              <div className="w-full h-0.5 bg-primary shadow-lg shadow-primary animate-pulse" />

              <span className="absolute bottom-2 text-[10px] text-white/70 font-medium">
                Aim at Instructor QR Code
              </span>
            </div>

            {/* Scan Trigger Button */}
            <button
              onClick={handleStudentScan}
              disabled={scanStatus === "scanning"}
              className="mt-4 px-6 py-2.5 bg-primary hover:bg-primary-hover text-white text-xs font-bold rounded-xl shadow-lg shadow-primary/30 flex items-center gap-2 transition active:scale-95 disabled:opacity-50"
            >
              {scanStatus === "scanning" ? (
                <>
                  <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  <span>Validating with Server...</span>
                </>
              ) : (
                <>
                  <QrCode className="w-4 h-4" />
                  <span>Scan Classroom QR Now</span>
                </>
              )}
            </button>
          </div>

          {/* Scan Feedback Result Card */}
          {scanStatus === "success" && lastScannedRecord && (
            <div className="p-3.5 bg-success/10 border border-success/30 rounded-xl space-y-1.5 animate-fadeIn">
              <div className="flex items-center gap-2 text-success font-bold text-xs">
                <CheckCircle2 className="w-4 h-4" />
                <span>Attendance Recorded!</span>
              </div>
              <p className="text-xs text-navy font-extrabold">{lastScannedRecord.name}</p>
              <div className="text-[11px] text-textSecondary flex items-center justify-between">
                <span>{lastScannedRecord.studentNumber} • {lastScannedRecord.section}</span>
                <span className="font-bold text-navy">{lastScannedRecord.time}</span>
              </div>
            </div>
          )}

          {scanStatus === "error" && (
            <div className="p-3.5 bg-error/10 border border-error/30 rounded-xl space-y-1 animate-fadeIn">
              <div className="flex items-center gap-2 text-error font-bold text-xs">
                <AlertTriangle className="w-4 h-4 flex-shrink-0" />
                <span>Check-in Rejected</span>
              </div>
              <p className="text-[11px] text-error font-medium">{scanMessage}</p>
            </div>
          )}

          {scanStatus === "idle" && (
            <p className="text-center text-[11px] text-textSecondary py-2">
              Select a student and press <strong>"Scan Classroom QR Now"</strong> to simulate check-in.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
