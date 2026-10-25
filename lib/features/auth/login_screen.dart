import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/glass_input.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/shopeasy_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController(text: '9876543210');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(mobile, password);

    if (mounted) {
      if (success) {
        context.go('/dashboard');
      } else {
        final err = ref.read(authProvider).errorMessage ?? 'Login failed. Please check credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final codes = ['+91 (India)', '+971 (UAE)', '+65 (Singapore)', '+1 (US/Canada)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Country Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ...codes.map((c) {
                  final code = c.split(' ')[0];
                  return ListTile(
                    title: Text(c),
                    trailing: _selectedCountryCode == code
                        ? const Icon(Icons.check, color: AppColors.primaryOrange)
                        : null,
                    onTap: () {
                      setState(() => _selectedCountryCode = code);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isSmall = context.isSmallPhone;
    final isVerySmall = context.isVerySmallPhone;
    final hPad = context.horizontalPadding;
    final vGap = context.vSpace;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Clean Background Warehouse Illustration & Warm Sunset Sky (No ghost text)
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

          // Subtle warm sunset ambient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.12),
                    const Color(0xFFEA580C).withOpacity(0.20),
                  ],
                ),
              ),
            ),
          ),

          // Main Responsive Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Header & Brand Area
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isSmall ? 8 : 12),
                                const ShopEasyHeader(
                                  rightAction: HeaderRightAction.slogan,
                                  isInGlassCard: false,
                                ),
                                SizedBox(height: vGap(isSmall ? 18 : 26)),
                                Text(
                                  'Distributor Login',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 23 : 26),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Connect  •  Supply  •  Grow',
                                  style: TextStyle(
                                    fontSize: context.sp(isSmall ? 12.5 : 14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.92),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: vGap(isSmall ? 12 : 18)),
                              ],
                            ),

                            // Translucent Glassmorphic Login Panel
                            GlassPanel(
                              borderRadius: isSmall ? 24 : 30,
                              blurSigma: 16,
                              padding: EdgeInsets.fromLTRB(
                                isVerySmall ? 14 : (isSmall ? 16 : 20),
                                isSmall ? 18 : 24,
                                isVerySmall ? 14 : (isSmall ? 16 : 20),
                                isSmall ? 16 : 20,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Mobile Number Field
                                    GlassInput(
                                      controller: _mobileController,
                                      hintText: 'Enter mobile number',
                                      keyboardType: TextInputType.phone,
                                      showCountryCode: true,
                                      countryCode: _selectedCountryCode,
                                      onCountryCodeTap: _showCountryCodePicker,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      prefixIcon: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE8D6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.phone_android_rounded,
                                          color: AppColors.primaryOrange,
                                          size: 17,
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter mobile number';
                                        }
                                        if (val.trim().length != 10) {
                                          return 'Enter a valid 10-digit number';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: vGap(isSmall ? 10 : 14)),

                                    // Password Field
                                    GlassInput(
                                      controller: _passwordController,
                                      hintText: 'Enter password',
                                      obscureText: _obscurePassword,
                                      prefixIcon: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE8D6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.primaryOrange,
                                          size: 17,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please enter password';
                                        }
                                        if (val.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: vGap(isSmall ? 14 : 20)),

                                    // Login Button with Arrow
                                    PrimaryButton(
                                      text: 'Login',
                                      height: isSmall ? 48 : 54,
                                      showArrow: true,
                                      isLoading: authState.isLoading,
                                      onPressed: _handleLogin,
                                    ),
                                    SizedBox(height: vGap(isSmall ? 10 : 14)),

                                    // Forgot Password Action
                                    TextButton(
                                      onPressed: () => context.push('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFFD9480F),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontSize: context.sp(isSmall ? 12.5 : 13.5),
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFC2410C),
                                        ),
                                      ),
                                    ),

                                    // OR Divider
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: vGap(isSmall ? 2 : 4)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.white.withOpacity(0.55),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              'OR',
                                              style: TextStyle(
                                                fontSize: context.sp(isSmall ? 11 : 12),
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF475569).withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.white.withOpacity(0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: vGap(isSmall ? 8 : 12)),

                                    // Register Here Action
                                    OutlinedGlassButton(
                                      height: isSmall ? 44 : 48,
                                      onPressed: () => context.push('/register'),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEDD5),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Icon(
                                                  Icons.person_add_alt_1_rounded,
                                                  color: AppColors.primaryOrange,
                                                  size: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'New Distributor? ',
                                                style: TextStyle(
                                                  fontSize: context.sp(isSmall ? 12 : 13.5),
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF334155),
                                                ),
                                              ),
                                              Text(
                                                'Register Here →',
                                                style: TextStyle(
                                                  fontSize: context.sp(isSmall ? 12 : 13.5),
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFFC2410C),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: vGap(isSmall ? 12 : 16)),

                                    // Secure & Trusted Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.verified_user_rounded,
                                          size: 15,
                                          color: Color(0xFFD97706),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Secure & Trusted',
                                          style: TextStyle(
                                            fontSize: context.sp(isSmall ? 11 : 12),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF334155).withOpacity(0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: vGap(isSmall ? 14 : 22)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
