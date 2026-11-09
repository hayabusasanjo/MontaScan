// mobile/lib/screens/teacher/teacher_correction_dialog.dart

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/attendance_record_model.dart';

class TeacherCorrectionDialog extends StatefulWidget {
  final AttendanceRecord record;
  final Function(String newStatus, String reason) onConfirm;

  const TeacherCorrectionDialog({
    super.key,
    required this.record,
    required this.onConfirm,
  });

  @override
  State<TeacherCorrectionDialog> createState() => _TeacherCorrectionDialogState();
}

class _TeacherCorrectionDialogState extends State<TeacherCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedStatus;
  final _reasonController = TextEditingController();

  final List<String> _statuses = ['present', 'late', 'absent', 'excused'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.record.status.toLowerCase();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Correct Attendance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student: ${widget.record.studentName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy),
              ),
              Text(
                'Student No: ${widget.record.studentNumber}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              const Text(
                'New Attendance Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Justification / Reason (Mandatory)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., Camera lens issue; approved medical pass; verified physical presence.',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'An auditable reason is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onConfirm(_selectedStatus, _reasonController.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Save Correction'),
        ),
      ],
    );
  }
}
