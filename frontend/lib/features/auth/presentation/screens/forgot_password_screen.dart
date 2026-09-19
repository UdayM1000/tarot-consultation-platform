import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/utils/validators.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_background.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_button.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: MysticBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.sacredPurple.withValues(alpha: 0.18),
                      ),
                      child: const Icon(Icons.lock_reset, color: AppColors.astralGold, size: 34),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: AppTypography.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your registered email address to receive password reset instructions',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  if (_submitted)
                    MysticCard(
                      padding: const EdgeInsets.all(24),
                      borderColor: AppColors.success,
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Reset Link Sent',
                            style: AppTypography.titleLarge.copyWith(color: AppColors.success),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If an account exists for ${_emailController.text}, you will receive an email with reset instructions shortly.',
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          MysticButton(
                            text: 'Back to Sign In',
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    )
                  else
                    MysticCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          MysticTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'your.email@domain.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 24),
                          MysticButton(
                            text: 'Send Reset Link',
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
