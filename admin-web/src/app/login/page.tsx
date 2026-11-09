// admin-web/src/app/login/page.tsx
"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { QrCode, Lock, Mail, ShieldAlert, ArrowRight } from "lucide-react";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("admin@cdm.edu.ph");
  const [password, setPassword] = useState("admin123");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    // Simulate authentication check
    setTimeout(() => {
      if (email === "admin@cdm.edu.ph") {
        router.push("/dashboard");
      } else {
        setError("Invalid administrative credentials. Use admin@cdm.edu.ph");
        setLoading(false);
      }
    }, 600);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4 py-12">
      <div className="w-full max-w-md">
        {/* Logo and Brand */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-primary text-white shadow-lg shadow-primary/25 mb-4">
            <QrCode className="w-8 h-8" />
          </div>
          <h1 className="text-2xl font-bold text-navy">MontaScan Admin Portal</h1>
          <p className="text-sm text-textSecondary font-medium mt-1">Colegio de Montalban</p>
          <span className="inline-block mt-2 px-3 py-1 bg-primary/10 text-primary text-xs font-semibold rounded-full">
            Institutional Management Console
          </span>
        </div>

        {/* Card */}
        <div className="bg-white border border-borderSlate rounded-2xl shadow-sm p-8">
          {error && (
            <div className="mb-6 p-4 rounded-xl bg-error/10 border border-error/20 flex items-center gap-3 text-error text-sm font-medium">
              <ShieldAlert className="w-5 h-5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-xs font-semibold text-textMain uppercase tracking-wider mb-2">
                Administrator Email
              </label>
              <div className="relative">
                <Mail className="w-5 h-5 text-textSecondary absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  placeholder="admin@cdm.edu.ph"
                  className="w-full pl-11 pr-4 py-2.5 bg-background border border-borderSlate rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-textMain uppercase tracking-wider mb-2">
                Password
              </label>
              <div className="relative">
                <Lock className="w-5 h-5 text-textSecondary absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  placeholder="••••••••"
                  className="w-full pl-11 pr-4 py-2.5 bg-background border border-borderSlate rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-primary hover:bg-primary-hover text-white font-semibold text-sm rounded-xl shadow-md shadow-primary/20 flex items-center justify-center gap-2 transition disabled:opacity-50"
            >
              {loading ? (
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <span>Sign In to Dashboard</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          {/* Demo account preset helper */}
          <div className="mt-6 pt-6 border-t border-borderSlate">
            <p className="text-xs text-textSecondary mb-2 font-medium">Demo Administrator Credentials:</p>
            <button
              type="button"
              onClick={() => {
                setEmail("admin@cdm.edu.ph");
                setPassword("admin123");
              }}
              className="w-full py-2 px-3 bg-background hover:bg-borderSlate/50 border border-borderSlate rounded-lg text-xs font-semibold text-navy text-left flex items-center justify-between transition"
            >
              <span>admin@cdm.edu.ph</span>
              <span className="text-primary font-bold">Auto Fill</span>
            </button>
          </div>
        </div>

        <p className="text-center text-xs text-textSecondary mt-8">
          Colegio de Montalban • Academic Information Technology Center
        </p>
      </div>
    </div>
  );
}
