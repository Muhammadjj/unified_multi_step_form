import 'package:flutter/material.dart';

import 'company_info_demo_screen.dart';

// Example app entry point for the package example.
//
// Run this app from the example folder to see the package UI in action.

/// Launches the example app.
void main() {
  runApp(const UnifiedMultiStepFormExampleApp());
}

/// Root widget for the example application.
class UnifiedMultiStepFormExampleApp extends StatelessWidget {
  /// Creates the example app.
  const UnifiedMultiStepFormExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CompanyInfoDemoScreen(),
    );
  }
}
