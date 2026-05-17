import 'dart:convert';

import 'package:flutter/material.dart';

/// A simple demo screen that keeps the same multi-step form concept:
/// - one shared [GlobalKey<FormState>]
/// - step-by-step navigation
/// - controllers preserve state across steps
/// - validators run on the current step before moving forward
class CompanyInfoMultiStepDemoScreen extends StatefulWidget {
  const CompanyInfoMultiStepDemoScreen({super.key});

  @override
  State<CompanyInfoMultiStepDemoScreen> createState() =>
      _CompanyInfoMultiStepDemoScreenState();
}

class _CompanyInfoMultiStepDemoScreenState
    extends State<CompanyInfoMultiStepDemoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController registeredNameController =
      TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController ntnController = TextEditingController();
  final TextEditingController strnController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController webAddressController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fiscalStartDateController =
      TextEditingController();
  final TextEditingController fiscalEndDateController = TextEditingController();
  final TextEditingController currencySymbolController =
      TextEditingController();
  final TextEditingController destinationProvinceController =
      TextEditingController();
  final TextEditingController termsController = TextEditingController();

  int currentStep = 0;
  bool isEditing = true;

  final List<String> _currencyCodes = const [
    'PKR',
    'USD',
    'AED',
    'SAR',
    'GBP',
    'EUR',
  ];

  final List<String> _provinces = const [
    'Punjab',
    'Sindh',
    'KPK',
    'Balochistan',
    'Islamabad',
    'Gilgit Baltistan',
    'Azad Kashmir',
  ];

  bool get _isLastStep => currentStep == 2;

  @override
  void dispose() {
    registeredNameController.dispose();
    cnicController.dispose();
    ntnController.dispose();
    strnController.dispose();
    contactController.dispose();
    webAddressController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    fiscalStartDateController.dispose();
    fiscalEndDateController.dispose();
    currencySymbolController.dispose();
    destinationProvinceController.dispose();
    termsController.dispose();
    super.dispose();
  }

  void _goNext() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_isLastStep) {
      _submit();
      return;
    }

    setState(() => currentStep += 1);
  }

  void _goPrevious() {
    if (currentStep == 0) return;
    setState(() => currentStep -= 1);
  }

  Future<void> _pickDate({required TextEditingController controller}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    final payload = <String, dynamic>{
      'CompanyName': registeredNameController.text.trim(),
      'CNIC': cnicController.text.trim(),
      'NTNNo': ntnController.text.trim(),
      'STNNo': strnController.text.trim(),
      'Phone': contactController.text.trim(),
      'WebAddress': webAddressController.text.trim(),
      'OwnerName': ownerNameController.text.trim(),
      'Email': emailController.text.trim(),
      'FiscalStartDateTime': fiscalStartDateController.text.trim(),
      'FiscalEndDateTime': fiscalEndDateController.text.trim(),
      'CurrencySymbol': currencySymbolController.text.trim(),
      'Province': destinationProvinceController.text.trim(),
      'TermsAndConditions': termsController.text.trim(),
    };

    final prettyPayload = JsonEncoder.withIndent('  ').convert(payload);

    debugPrint(prettyPayload);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Demo Submit'),
          content: SingleChildScrollView(
            child: Text(prettyPayload, style: const TextStyle(fontSize: 13)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: currentStep == index ? 28 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: currentStep == index ? Colors.blue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Basic Information'),
        _textField(
          controller: registeredNameController,
          label: 'Registered Name',
          hint: 'Register Name',
          keyboardType: TextInputType.name,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter registered name';
            }
            if (value.length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: cnicController,
          label: 'CNIC',
          hint: 'XXXXX-XXXXXXX-X',
          keyboardType: TextInputType.number,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter CNIC number';
            }
            if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value)) {
              return 'Use CNIC format XXXXX-XXXXXXX-X';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: ntnController,
          label: 'NTN',
          hint: '1234567-8',
          keyboardType: TextInputType.number,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter NTN number';
            }
            if (!RegExp(r'^\d{7}-\d$').hasMatch(value)) {
              return 'Use NTN format 1234567-8';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: strnController,
          label: 'STRN',
          hint: 'AA-123456',
          keyboardType: TextInputType.text,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter STRN number';
            }
            if (!RegExp(r'^[A-Z]{2}-\d{6}$').hasMatch(value)) {
              return 'Use STRN format AA-123456';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: contactController,
          label: 'Contact Number',
          hint: '+92-300-1234567',
          keyboardType: TextInputType.phone,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter contact number';
            }
            if (!RegExp(r'^\+92-\d{3}-\d{7}$').hasMatch(value)) {
              return 'Use phone format +92-XXX-XXXXXXX';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: webAddressController,
          label: 'Web Address',
          hint: 'example.com',
          keyboardType: TextInputType.url,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter web address';
            }
            final urlRegex = RegExp(r'^(https?:\/\/)?([\w-]+\.)+[\w-]+$');
            if (!urlRegex.hasMatch(value.trim())) {
              return 'Please enter a valid web address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Owner, Fiscal Year & Settings'),
        _textField(
          controller: ownerNameController,
          label: 'Owner Name',
          hint: 'Enter owner name',
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: emailController,
          label: 'Email Address',
          hint: 'example@domain.com',
          keyboardType: TextInputType.emailAddress,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email address';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: fiscalStartDateController,
          label: 'Fiscal Start Date',
          hint: 'Select start date',
          readOnly: true,
          onTap: isEditing
              ? () => _pickDate(controller: fiscalStartDateController)
              : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select fiscal start date';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: fiscalEndDateController,
          label: 'Fiscal End Date',
          hint: 'Select end date',
          readOnly: true,
          onTap: isEditing
              ? () => _pickDate(controller: fiscalEndDateController)
              : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select fiscal end date';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: currencySymbolController.text.isEmpty
              ? null
              : currencySymbolController.text,
          items: _currencyCodes
              .map((code) => DropdownMenuItem(value: code, child: Text(code)))
              .toList(),
          onChanged: isEditing
              ? (value) {
                  setState(() {
                    currencySymbolController.text = value ?? '';
                  });
                }
              : null,
          decoration: InputDecoration(
            labelText: 'Currency Code',
            hintText: 'Select currency code',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select currency code';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: destinationProvinceController.text.isEmpty
              ? null
              : destinationProvinceController.text,
          items: _provinces
              .map(
                (province) =>
                    DropdownMenuItem(value: province, child: Text(province)),
              )
              .toList(),
          onChanged: isEditing
              ? (value) {
                  setState(() {
                    destinationProvinceController.text = value ?? '';
                  });
                }
              : null,
          decoration: InputDecoration(
            labelText: 'Destination Province',
            hintText: 'Select province',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select destination province';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _textField(
          controller: termsController,
          label: 'Terms & Conditions',
          hint: 'Enter terms and conditions',
          maxLines: 4,
          readOnly: !isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter terms and conditions';
            }
            if (value.length < 10) {
              return 'Terms should be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final hasCompanyLogo = registeredNameController.text.isNotEmpty;
    final hasFbrLogo = ownerNameController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Review & Submit'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${registeredNameController.text}'),
              const SizedBox(height: 6),
              Text('Owner: ${ownerNameController.text}'),
              const SizedBox(height: 6),
              Text('Currency: ${currencySymbolController.text}'),
              const SizedBox(height: 6),
              Text('Province: ${destinationProvinceController.text}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: hasCompanyLogo ? Colors.green.shade50 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              hasCompanyLogo
                  ? 'Company Logo Ready'
                  : 'Company Logo Placeholder',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: hasFbrLogo ? Colors.blue.shade50 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              hasFbrLogo ? 'FBR Logo Ready' : 'FBR Logo Placeholder',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'This screen keeps the same idea as your original code: one form key, multi-step flow, and preserved controller state.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
      default:
        return _buildStep2();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Info Demo'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? 'Editing' : 'Locked',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SingleChildScrollView(
                    key: ValueKey<int>(currentStep),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStepContent(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goPrevious,
                          child: const Text('Previous'),
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _goNext,
                        child: Text(_isLastStep ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
