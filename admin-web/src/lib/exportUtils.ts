// admin-web/src/lib/exportUtils.ts

import * as XLSX from "xlsx";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

export interface AttendanceExportRow {
  studentNumber: string;
  studentName: string;
  subjectCode: string;
  sectionName: string;
  date: string;
  time: string;
  status: string;
}

export function exportAttendanceToExcel(data: AttendanceExportRow[], filename = "MontaScan_Attendance_Report.xlsx") {
  const worksheet = XLSX.utils.json_to_sheet(
    data.map((row) => ({
      "Student No.": row.studentNumber,
      "Student Name": row.studentName,
      "Subject Code": row.subjectCode,
      "Section": row.sectionName,
      "Date": row.date,
      "Time Recorded": row.time,
      "Status": row.status.toUpperCase(),
    }))
  );

  // Set column widths
  worksheet["!cols"] = [
    { wch: 15 },
    { wch: 25 },
    { wch: 15 },
    { wch: 12 },
    { wch: 14 },
    { wch: 14 },
    { wch: 12 },
  ];

  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Attendance Records");
  XLSX.writeFile(workbook, filename);
}

export function exportAttendanceToPDF(
  data: AttendanceExportRow[],
  summary: { total: number; present: number; late: number; absent: number; rate: string },
  title = "Colegio de Montalban - Attendance Management Report",
  filename = "MontaScan_Attendance_Report.pdf"
) {
  const doc = new jsPDF("p", "pt", "a4");

  // Document Header
  doc.setFont("helvetica", "bold");
  doc.setFontSize(18);
  doc.setTextColor(23, 37, 84); // Navy
  doc.text("COLEGIO DE MONTALBAN", 40, 50);

  doc.setFontSize(13);
  doc.setFont("helvetica", "normal");
  doc.setTextColor(37, 99, 235); // Primary Blue
  doc.text("MontaScan Attendance Management Report", 40, 68);

  doc.setFontSize(10);
  doc.setTextColor(100, 116, 139); // Text Secondary
  doc.text(`Generated on: ${new Date().toLocaleString()} • Official Academic Record`, 40, 84);

  // Summary Metrics Banner
  doc.setFillColor(248, 250, 252);
  doc.roundedRect(40, 95, 515, 45, 6, 6, "F");

  doc.setFont("helvetica", "bold");
  doc.setFontSize(10);
  doc.setTextColor(15, 23, 42);
  doc.text(`Total Records: ${summary.total}`, 55, 122);
  doc.text(`Present: ${summary.present}`, 160, 122);
  doc.text(`Late: ${summary.late}`, 250, 122);
  doc.text(`Absent: ${summary.absent}`, 330, 122);
  doc.text(`Attendance Rate: ${summary.rate}`, 420, 122);

  // Table Data
  const tableData = data.map((row) => [
    row.studentNumber,
    row.studentName,
    row.subjectCode,
    row.sectionName,
    row.date,
    row.time,
    row.status.toUpperCase(),
  ]);

  autoTable(doc, {
    startY: 155,
    head: [["Student No.", "Student Name", "Subject", "Section", "Date", "Time", "Status"]],
    body: tableData,
    theme: "striped",
    headStyles: {
      fillColor: [37, 99, 235],
      textColor: [255, 255, 255],
      fontStyle: "bold",
      fontSize: 9,
    },
    bodyStyles: {
      fontSize: 8.5,
      textColor: [15, 23, 42],
    },
    alternateRowStyles: {
      fillColor: [248, 250, 252],
    },
    margin: { left: 40, right: 40 },
  });

  doc.save(filename);
}
