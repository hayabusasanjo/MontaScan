/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#2563EB",
          hover: "#1D4ED8",
          light: "#DBEAFE",
        },
        navy: {
          DEFAULT: "#172554",
          light: "#1E3A8A",
        },
        surface: "#FFFFFF",
        background: "#F8FAFC",
        success: {
          DEFAULT: "#16A34A",
          light: "#DCFCE7",
        },
        warning: {
          DEFAULT: "#F59E0B",
          light: "#FEF3C7",
        },
        error: {
          DEFAULT: "#DC2626",
          light: "#FEE2E2",
        },
        textMain: "#0F172A",
        textSecondary: "#64748B",
        borderSlate: "#E2E8F0",
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
      },
    },
  },
  plugins: [],
};
