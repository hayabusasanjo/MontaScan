// mobile/lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Recovery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.success),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recovery Link Dispatched',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent password reset instructions to ${_emailController.text}. Please check your institutional inbox.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Back to Login'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Reset Institutional Password',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered Colegio de Montalban email address. A secure recovery link will be sent to your account.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Institutional Email',
                        hintText: 'student.number@cdm.edu.ph',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.isNotEmpty) {
                          setState(() => _submitted = true);
                        }
                      },
                      child: const Text('Send Recovery Link'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
