import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unified_multi_step_form/unified_multi_step_form.dart';

class CompanyInfoDemoScreen extends StatefulWidget {
  const CompanyInfoDemoScreen({super.key});

  @override
  State<CompanyInfoDemoScreen> createState() => _CompanyInfoDemoScreenState();
}

class _CompanyInfoDemoScreenState extends State<CompanyInfoDemoScreen> {
  final GlobalKey<FormState> _step0Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2Key = GlobalKey<FormState>();

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

  bool canEdit = true;

  // Extra UI state
  bool acceptTerms = true;
  bool enableNotifications = false;
  String companyType = 'Private';
  XFile? pickedImage;
  final _controller = UnifiedMultiStepFormController();

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

  @override
  void initState() {
    super.initState();
    // Sample data for testing
    registeredNameController.text = 'ABC Corporation Ltd';
    cnicController.text = '12345-6789012-3';
    ntnController.text = '1234567-8';
    strnController.text = 'AB-123456';
    contactController.text = '+92-300-1234567';
    webAddressController.text = 'abc-corporation.com';
    ownerNameController.text = 'Muhammad Ahmad';
    emailController.text = 'contact@abc-corp.com';
    fiscalStartDateController.text = '2024-01-01';
    fiscalEndDateController.text = '2024-12-31';
    currencySymbolController.text = 'PKR';
    destinationProvinceController.text = 'Punjab';
    termsController.text =
        'All terms and conditions apply to this transaction as per our policy agreement.';

    // Example: register a couple async validators (simulate server checks)
    _controller.registerAsyncValidator(
      name: 'email',
      validator: (value) async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (value == null || value.isEmpty) return 'Email required';
        if (value.contains('blocked')) return 'Email blocked by server';
        return null;
      },
    );

    _controller.registerAsyncValidator(
      name: 'phone',
      validator: (value) async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (value == null || value.isEmpty) return 'Phone required';
        if (!value.startsWith('+')) return 'Phone must include country code';
        return null;
      },
    );
  }

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

  Future<void> _pickDate({required TextEditingController controller}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (file != null) setState(() => pickedImage = file);
  }

  Widget _field({
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _step0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Basic Information'),
        _field(
          controller: registeredNameController,
          label: 'Registered Name',
          hint: 'Register Name',
          keyboardType: TextInputType.name,
          readOnly: !canEdit,
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
        _field(
          controller: cnicController,
          label: 'CNIC',
          hint: 'XXXXX-XXXXXXX-X',
          keyboardType: TextInputType.number,
          readOnly: !canEdit,
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
        _field(
          controller: ntnController,
          label: 'NTN',
          hint: '1234567-8',
          keyboardType: TextInputType.number,
          readOnly: !canEdit,
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
        _field(
          controller: strnController,
          label: 'STRN',
          hint: 'AA-123456',
          readOnly: !canEdit,
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
        _field(
          controller: contactController,
          label: 'Contact Number',
          hint: '+92-300-1234567',
          keyboardType: TextInputType.phone,
          readOnly: !canEdit,
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
        _field(
          controller: webAddressController,
          label: 'Web Address',
          hint: 'example.com',
          keyboardType: TextInputType.url,
          readOnly: !canEdit,
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
        const SizedBox(height: 16),
        // Image picker card
        Text('Company Logo', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: canEdit ? _pickImage : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (pickedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(pickedImage!.path),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pickedImage == null
                        ? 'Tap to pick logo'
                        : pickedImage!.name,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Owner, Fiscal Year & Settings'),
        _field(
          controller: ownerNameController,
          label: 'Owner Name',
          hint: 'Enter owner name',
          readOnly: !canEdit,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please enter owner name'
              : null,
        ),
        const SizedBox(height: 16),
        _field(
          controller: emailController,
          label: 'Email Address',
          hint: 'example@domain.com',
          keyboardType: TextInputType.emailAddress,
          readOnly: !canEdit,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email address';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _field(
          controller: fiscalStartDateController,
          label: 'Fiscal Start Date',
          hint: 'Select start date',
          readOnly: true,
          onTap: canEdit
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
        // Checkbox + Switch + segmented choice
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                value: acceptTerms,
                onChanged: canEdit
                    ? (v) => setState(() => acceptTerms = v ?? false)
                    : null,
                title: const Text('Accept Terms'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SwitchListTile(
                value: enableNotifications,
                onChanged: canEdit
                    ? (v) => setState(() => enableNotifications = v)
                    : null,
                title: const Text('Enable Notifications'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Company Type',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(value: 'Private', label: Text('Private')),
            ButtonSegment<String>(value: 'Public', label: Text('Public')),
          ],
          selected: {companyType},
          onSelectionChanged: canEdit
              ? (selection) => setState(() => companyType = selection.first)
              : null,
        ),
        const SizedBox(height: 16),
        _field(
          controller: fiscalEndDateController,
          label: 'Fiscal End Date',
          hint: 'Select end date',
          readOnly: true,
          onTap: canEdit
              ? () => _pickDate(controller: fiscalEndDateController)
              : null,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please select fiscal end date'
              : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: currencySymbolController.text.isEmpty
              ? null
              : currencySymbolController.text,
          items: _currencyCodes
              .map((code) => DropdownMenuItem(value: code, child: Text(code)))
              .toList(),
          onChanged: canEdit
              ? (value) =>
                    setState(() => currencySymbolController.text = value ?? '')
              : null,
          decoration: InputDecoration(
            labelText: 'Currency Code',
            hintText: 'Select currency code',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please select currency code'
              : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: destinationProvinceController.text.isEmpty
              ? null
              : destinationProvinceController.text,
          items: _provinces
              .map(
                (province) =>
                    DropdownMenuItem(value: province, child: Text(province)),
              )
              .toList(),
          onChanged: canEdit
              ? (value) => setState(
                  () => destinationProvinceController.text = value ?? '',
                )
              : null,
          decoration: InputDecoration(
            labelText: 'Destination Province',
            hintText: 'Select province',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please select destination province'
              : null,
        ),
        const SizedBox(height: 16),
        _field(
          controller: termsController,
          label: 'Terms & Conditions',
          hint: 'Enter terms and conditions',
          maxLines: 4,
          readOnly: !canEdit,
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

  Widget _step2() {
    final summary = <String, String>{
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
      'AcceptedTerms': acceptTerms ? 'Yes' : 'No',
      'Notifications': enableNotifications ? 'Yes' : 'No',
      'CompanyType': companyType,
      'Logo': pickedImage?.name ?? 'Not selected',
    };

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
            children: summary.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Custom card preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              if (pickedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(pickedImage!.path),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.business),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registeredNameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(ownerNameController.text),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'This demo keeps the same flow: mounted pages, step validation, and final submit payload.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
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
      'AcceptedTerms': acceptTerms,
      'Notifications': enableNotifications,
      'CompanyType': companyType,
      'LogoPath': pickedImage?.path,
    };

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Submit'),
        content: SingleChildScrollView(
          child: Text(
            '${const JsonEncoder.withIndent('  ').convert({'note': 'Payload is generated from the multi-step form state.'})}\n\n${payload.toString()}',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Info Demo'),
        actions: [
          TextButton(
            onPressed: () => setState(() => canEdit = !canEdit),
            child: Text(
              canEdit ? 'Editing' : 'Locked',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: UnifiedMultiStepForm(
          controller: _controller,
          usePageView: true,
          transitionType: TransitionType.slide,
          indicatorType: IndicatorType.numbers,
          indicatorActiveColor: Colors.red,
          pages: [
            MultiStepFormPage(
              formKey: _step0Key,
              // title: '',
              builder: (_) => _step0(),
            ),
            MultiStepFormPage(
              formKey: _step1Key,
              // title: '',
              builder: (_) => _step1(),
            ),
            MultiStepFormPage(
              formKey: _step2Key,
              // title: 'Review & Submit',
              builder: (_) => _step2(),
            ),
          ],
          onSubmit: _submit,
        ),
      ),
    );
  }
}
