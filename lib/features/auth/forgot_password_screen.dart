import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/glass_input.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/shopeasy_header.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _mobileController = TextEditingController(text: '9876543210');
  final _otpController = TextEditingController(text: '1234');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1: Enter mobile, 2: OTP & New Password, 3: Success
  bool _obscureNewPass = true;
  int _resendCountdown = 30;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendCountdown = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
        return true;
      }
      return false;
    });
  }

  Future<void> _handleSendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordResetOtp(mobile);
    if (success && mounted) {
      setState(() => _step = 2);
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo OTP "1234" sent to registered mobile'),
          backgroundColor: AppColors.primaryOrange,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    final otp = _otpController.text.trim();
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .verifyOtpAndResetPassword(_mobileController.text.trim(), otp, newPass);

    if (success && mounted) {
      setState(() => _step = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Backdrop
          Positioned.fill(
            child: Image.asset(
              'assets/images/warehouse_backdrop.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.warmBackgroundGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button
                      Row(
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: ShopEasyHeader(
                              rightAction: HeaderRightAction.none,
                              isInGlassCard: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Password Recovery',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _step == 1
                            ? 'Enter registered mobile number to receive verification code'
                            : _step == 2
                            ? 'Verify OTP and set a new secure password'
                            : 'Password successfully updated!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Glass Panel Content
                      GlassPanel(
                        borderRadius: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_step == 1) ...[
                              GlassInput(
                                controller: _mobileController,
                                label: 'Registered Mobile Number',
                                hintText: 'Enter 10-digit number',
                                keyboardType: TextInputType.phone,
                                showCountryCode: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                prefixIcon: const Icon(
                                  Icons.phone_android_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                text: 'Send Verification Code',
                                showArrow: true,
                                isLoading: authState.isLoading,
                                onPressed: _handleSendOtp,
                              ),
                            ] else if (_step == 2) ...[
                              GlassInput(
                                controller: _otpController,
                                label: 'Verification Code (OTP)',
                                hintText: 'Enter 4-digit OTP (1234)',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                prefixIcon: const Icon(
                                  Icons.security_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _resendCountdown == 0
                                      ? _handleSendOtp
                                      : null,
                                  child: Text(
                                    _resendCountdown == 0
                                        ? 'Resend OTP'
                                        : 'Resend in ${_resendCountdown}s',
                                    style: TextStyle(
                                      color: _resendCountdown == 0
                                          ? AppColors.primaryOrange
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GlassInput(
                                controller: _newPasswordController,
                                label: 'New Password',
                                hintText: 'Enter new password',
                                obscureText: _obscureNewPass,
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () => _obscureNewPass = !_obscureNewPass,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),
                              GlassInput(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hintText: 'Re-enter new password',
                                obscureText: _obscureNewPass,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                text: 'Reset Password',
                                showArrow: true,
                                isLoading: authState.isLoading,
                                onPressed: _handleResetPassword,
                              ),
                            ] else ...[
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCFCE7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF16A34A),
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Password Reset Successful!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your password has been securely updated. You can now login with your new credentials.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    PrimaryButton(
                                      text: 'Back to Login',
                                      showArrow: true,
                                      onPressed: () => context.go('/login'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
