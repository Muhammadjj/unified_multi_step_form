import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_multi_step_form/unified_multi_step_form.dart';

void main() {
  testWidgets('keeps step state and navigates with validation', (tester) async {
    final step0Key = GlobalKey<FormState>();
    final step1Key = GlobalKey<FormState>();
    final step0Controller = TextEditingController();
    final step1Controller = TextEditingController();
    var submitted = false;

    addTearDown(() {
      step0Controller.dispose();
      step1Controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnifiedMultiStepForm(
            pages: [
              MultiStepFormPage(
                formKey: step0Key,
                title: 'Step One',
                builder: (_) => Column(
                  children: [
                    TextFormField(
                      controller: step0Controller,
                      decoration: const InputDecoration(labelText: 'Field 1'),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              MultiStepFormPage(
                formKey: step1Key,
                title: 'Step Two',
                builder: (_) => Column(
                  children: [
                    TextFormField(
                      controller: step1Controller,
                      decoration: const InputDecoration(labelText: 'Field 2'),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ],
            onSubmit: () => submitted = true,
          ),
        ),
      ),
    );

    expect(find.text('Step 1 of 2'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'hello');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(step0Controller.text, 'hello');

    await tester.enterText(find.byType(TextFormField).last, 'world');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  test('controller tracks steps and validates registered fields', () {
    final controller = UnifiedMultiStepFormController(initialStep: 1);
    final first = TextEditingController(text: 'abc');
    final second = TextEditingController(text: '');

    addTearDown(() {
      first.dispose();
      second.dispose();
    });

    controller.attachStepCount(3);
    controller.registerField(
      name: 'first',
      controller: first,
      stepIndex: 0,
      validator: (value) =>
          value == null || value.length < 3 ? 'too short' : null,
    );
    controller.registerField(
      name: 'second',
      controller: second,
      stepIndex: 1,
      validator: (value) => value == null || value.isEmpty ? 'required' : null,
    );

    expect(controller.currentStep, 1);
    expect(controller.isFirstStep, isFalse);
    expect(controller.isLastStep, isFalse);

    controller.previous();
    expect(controller.currentStep, 0);

    expect(controller.validateStep(0), isTrue);
    expect(controller.validateStep(1), isFalse);
    expect(controller.validateAll(), isFalse);

    second.text = 'filled';
    expect(controller.validateAll(), isTrue);
    expect(controller.getValue('first'), 'abc');
    expect(controller.getValues(), containsPair('second', 'filled'));
  });

  test('controller runs async validators', () async {
    final controller = UnifiedMultiStepFormController();
    final email = TextEditingController(text: 'blocked@example.com');

    addTearDown(email.dispose);

    controller.registerField(name: 'email', controller: email, stepIndex: 0);
    controller.registerAsyncValidator(
      name: 'email',
      validator: (value) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        if (value != null && value.contains('blocked')) {
          return 'Email blocked';
        }
        return null;
      },
    );

    expect(await controller.validateStepAsync(0), isFalse);

    email.text = 'ok@example.com';
    expect(await controller.validateAllAsync(), isTrue);
  });

  testWidgets('renders linear indicator and page view mode', (tester) async {
    final step0Key = GlobalKey<FormState>();
    final step1Key = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnifiedMultiStepForm(
            usePageView: true,
            indicatorType: IndicatorType.linear,
            pages: [
              MultiStepFormPage(
                formKey: step0Key,
                builder: (_) => const SizedBox(height: 40, child: Text('A')),
              ),
              MultiStepFormPage(
                formKey: step1Key,
                builder: (_) => const SizedBox(height: 40, child: Text('B')),
              ),
            ],
            onSubmit: () {},
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });
}
