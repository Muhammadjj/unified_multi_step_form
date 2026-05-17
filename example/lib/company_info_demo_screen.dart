import 'package:flutter/material.dart';
import 'package:unified_multi_step_form/unified_multi_step_form.dart';

/// Simple example screen that demonstrates the package in the example app.
class CompanyInfoDemoScreen extends StatefulWidget {
  /// Creates the example screen.
  const CompanyInfoDemoScreen({super.key});

  @override
  State<CompanyInfoDemoScreen> createState() => _CompanyInfoDemoScreenState();
}

class _CompanyInfoDemoScreenState extends State<CompanyInfoDemoScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unified Multi Step Form')),
      body: UnifiedMultiStepForm(
        pages: [
          MultiStepFormPage(
            formKey: _step1Key,
            title: 'Company Info',
            builder: (_) => TextFormField(
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ),
          MultiStepFormPage(
            formKey: _step2Key,
            title: 'Review',
            builder: (_) => const Text('Review and submit your information.'),
          ),
        ],
        indicatorType: IndicatorType.dots,
        transitionType: TransitionType.slide,
        usePageView: true,
        onSubmit: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submitted successfully')),
          );
        },
      ),
    );
  }
}
