import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/distributor_provider.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/glass_input.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/shopeasy_header.dart';

import '../../core/utils/responsive.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  int _currentStep = 1;

  // Step 1 Controllers
  final _businessNameController = TextEditingController(
    text: 'Ramesh Distributors',
  );
  final _ownerNameController = TextEditingController(text: 'Ramesh Kumar');
  final _mobileController = TextEditingController(text: '9876543210');
  final _gstController = TextEditingController(text: '22AABCD1234F1ZS');
  final _addressController = TextEditingController(
    text: '123 Market Road, Civil Lines, Azamgarh, UP - 276001',
  );
  String _selectedBusinessType = 'Wholesaler / Distributor';

  // Step 2 Document Uploads
  final Map<String, String?> _documents = {
    'GST Certificate': 'gst_certificate_ramesh.pdf',
    'PAN Card': 'pan_card_ramesh.jpg',
    'Trade License / FSSAI': 'trade_license_2026.pdf',
    'Bank Cancelled Cheque': null,
  };

  // Step 3 Confirmation state
  String? _referenceId;
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_businessNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Business Name')),
        );
        return;
      }
      if (_ownerNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Authorized Person Name')),
        );
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Business Address')),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_documents['GST Certificate'] == null ||
          _documents['PAN Card'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload both GST Certificate and PAN Card'),
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and declarations')),
      );
      return;
    }

    final res = await ref
        .read(authProvider.notifier)
        .registerDistributor(
          businessName: _businessNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          gstNumber: _gstController.text.trim(),
          businessType: _selectedBusinessType,
          address: _addressController.text.trim(),
          uploadedDocs: _documents.values.whereType<String>().toList(),
        );

    if (res != null && mounted) {
      setState(() {
        _referenceId = res['referenceId'] as String;
      });
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
            child: Container(color: Colors.black.withOpacity(0.18)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: 12,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Header
                      ShopEasyHeader(
                        rightAction: HeaderRightAction.moreMenu,
                        onMenuTap: () => context.pop(),
                      ),
                      const SizedBox(height: 16),

                      // Registration Glass Card
                      GlassPanel(
                        borderRadius: context.isSmallPhone ? 24 : 30,
                        blurSigma: 18,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.isVerySmallPhone ? 14 : 18,
                          vertical: context.vSpace(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distributor Registration',
                              style: TextStyle(
                                fontSize: context.sp(
                                  context.isSmallPhone ? 20 : 22,
                                ),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Step Indicator (1 - Business Details, 2 - Documents, 3 - Approval)
                            _buildStepIndicator(),
                            const SizedBox(height: 22),

                            if (_referenceId != null) ...[
                              _buildSuccessView(),
                            ] else if (_currentStep == 1) ...[
                              _buildStep1BusinessInfo(),
                            ] else if (_currentStep == 2) ...[
                              _buildStep2Documents(),
                            ] else ...[
                              _buildStep3Review(authState.isLoading),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepItem(
          1,
          'Business\nDetails',
          _currentStep >= 1,
          _currentStep == 1,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            color: _currentStep > 1
                ? AppColors.primaryOrange
                : Colors.white.withOpacity(0.6),
          ),
        ),
        _buildStepItem(2, 'Documents', _currentStep >= 2, _currentStep == 2),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            color: _currentStep > 2
                ? AppColors.primaryOrange
                : Colors.white.withOpacity(0.6),
          ),
        ),
        _buildStepItem(3, 'Approval', _currentStep >= 3, _currentStep == 3),
      ],
    );
  }

  Widget _buildStepItem(
    int step,
    String label,
    bool isCompletedOrActive,
    bool isActive,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
                ? AppColors.buttonGradient
                : (isCompletedOrActive
                      ? const LinearGradient(
                          colors: [Color(0xFFFF9E40), Color(0xFFFF6D00)],
                        )
                      : null),
            color: isCompletedOrActive ? null : Colors.white.withOpacity(0.35),
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isCompletedOrActive
                    ? Colors.white
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1BusinessInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),

        GlassInput(
          controller: _businessNameController,
          label: 'Business Name',
          hintText: 'Enter business name',
          prefixIcon: const Icon(
            Icons.storefront_rounded,
            color: Color(0xFF475569),
            size: 20,
          ),
        ),
        const SizedBox(height: 12),

        GlassInput(
          controller: _ownerNameController,
          label: 'Authorized Contact Person',
          hintText: 'Enter owner or partner name',
          prefixIcon: const Icon(
            Icons.person_rounded,
            color: Color(0xFF475569),
            size: 20,
          ),
        ),
        const SizedBox(height: 12),

        GlassInput(
          controller: _gstController,
          label: 'GST Number',
          hintText: 'e.g. 22AABCD1234F1ZS',
          prefixIcon: const Icon(
            Icons.verified_outlined,
            color: Color(0xFF475569),
            size: 20,
          ),
        ),
        const SizedBox(height: 12),

        // Business Type Dropdown
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Business Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.65),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business_center_outlined,
                color: Color(0xFF475569),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBusinessType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                    items:
                        [
                              'Wholesaler / Distributor',
                              'Super Stockist',
                              'Direct Manufacturer Partner',
                              'C&F Agent',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBusinessType = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        GlassInput(
          controller: _addressController,
          label: 'Address',
          hintText: 'Full warehouse address, city & pin code',
          maxLines: 2,
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF475569),
            size: 20,
          ),
        ),
        const SizedBox(height: 22),

        PrimaryButton(text: 'Next', showArrow: true, onPressed: _nextStep),
      ],
    );
  }

  Widget _buildStep2Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Uploads',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Upload PDF, JPG, or PNG files (Max 5MB each) for identity & business verification.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),

        ..._documents.keys.map((docName) {
          final isUploaded = _documents[docName] != null;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUploaded
                    ? const Color(0xFF16A34A).withOpacity(0.5)
                    : Colors.white.withOpacity(0.6),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded
                      ? Icons.check_circle_rounded
                      : Icons.upload_file_rounded,
                  color: isUploaded
                      ? const Color(0xFF16A34A)
                      : AppColors.primaryOrange,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        isUploaded
                            ? _documents[docName]!
                            : 'Required • Not uploaded yet',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isUploaded
                              ? const Color(0xFF15803D)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (isUploaded) {
                        _documents[docName] = null;
                      } else {
                        _documents[docName] =
                            '${docName.toLowerCase().replaceAll(' ', '_')}.pdf';
                      }
                    });
                  },
                  child: Text(
                    isUploaded ? 'Replace' : 'Upload',
                    style: TextStyle(
                      color: isUploaded
                          ? const Color(0xFF64748B)
                          : AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Next',
                showArrow: true,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Review(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Approval',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.65)),
          ),
          child: Column(
            children: [
              _buildReviewRow('Business Name', _businessNameController.text),
              const Divider(height: 14),
              _buildReviewRow('Contact Person', _ownerNameController.text),
              const Divider(height: 14),
              _buildReviewRow('Mobile', _mobileController.text),
              const Divider(height: 14),
              _buildReviewRow('GST Number', _gstController.text),
              const Divider(height: 14),
              _buildReviewRow('Business Type', _selectedBusinessType),
              const Divider(height: 14),
              _buildReviewRow('Address', _addressController.text),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Checkbox(
              value: _agreedToTerms,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
            ),
            const Expanded(
              child: Text(
                'I certify that all details & uploaded documents are authentic and abide by ShopEasy partner guidelines.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Submit Application',
                showArrow: true,
                isLoading: isLoading,
                onPressed: _submitRegistration,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: Color(0xFF16A34A),
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Application Submitted!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Text(
            'Ref ID: $_referenceId',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF92400E),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your distributor application has been registered into the ShopEasy logistics network. Our local territory manager will review your documents within 24-48 business hours.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Proceed to Dashboard',
          showArrow: true,
          onPressed: () => context.go('/dashboard'),
        ),
      ],
    );
  }
}
