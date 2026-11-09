// mobile/lib/screens/student/student_qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/colors.dart';
import '../../providers/attendance_provider.dart';

class StudentQrScannerScreen extends ConsumerStatefulWidget {
  const StudentQrScannerScreen({super.key});

  @override
  ConsumerState<StudentQrScannerScreen> createState() => _StudentQrScannerScreenState();
}

class _StudentQrScannerScreenState extends ConsumerState<StudentQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final raw = barcode.rawValue!;
        _processScannedToken(raw);
        break;
      }
    }
  }

  void _processScannedToken(String rawPayload) async {
    setState(() => _isProcessing = true);

    await ref.read(studentScanProvider.notifier).submitScan(rawPayload);
    final scanState = ref.read(studentScanProvider);

    setState(() => _isProcessing = false);

    if (scanState.isSuccess && scanState.recordedRecord != null) {
      if (mounted) {
        context.push('/attendance-success', extra: scanState.recordedRecord);
      }
    } else if (scanState.errorMessage != null) {
      if (mounted) {
        _showErrorDialog(scanState.errorMessage!);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Scan Unsuccessful', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(studentScanProvider.notifier).reset();
              Navigator.pop(ctx);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Manual Session Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the session code or demo token if camera is unavailable:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _manualInputController,
              decoration: const InputDecoration(
                hintText: 'e.g. 88888888-8888-8888-8888-888888888801:token',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _manualInputController.text.trim();
              Navigator.pop(ctx);
              if (text.isNotEmpty) {
                _processScannedToken(text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Attendance QR', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scanning Reticle Frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 240,
                      height: 2,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction & manual option
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Point your camera at the rotating QR code on your professor\'s screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  onPressed: _showManualEntryDialog,
                  icon: const Icon(Icons.keyboard_outlined, size: 18),
                  label: const Text('Input Code Manually / Testing', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    SizedBox(height: 16),
                    Text(
                      'Validating attendance with server...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
