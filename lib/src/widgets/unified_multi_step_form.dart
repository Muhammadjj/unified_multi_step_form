import 'package:flutter/material.dart';
import 'package:unified_multi_step_form/src/controllers/unified_multi_step_form_controller.dart';
import 'package:unified_multi_step_form/src/models/multi_step_form_page.dart';

/// Step indicator styles supported by [UnifiedMultiStepForm].
enum IndicatorType { dots, numbers, linear }

/// Page transition styles supported when [UnifiedMultiStepForm.usePageView] is enabled.
enum TransitionType { none, slide, fade, vertical }

/// A reusable multi-step form shell that keeps step state stable and supports
/// step validation, optional controller-driven navigation, and flexible page indicators.
class UnifiedMultiStepForm extends StatefulWidget {
  /// Creates a multi-step form shell.
  const UnifiedMultiStepForm({
    super.key,
    required this.pages,
    this.controller,
    this.onSubmit,
    this.onStepChanged,
    this.initialStep = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.indicatorActiveColor,
    this.indicatorInactiveColor,
    this.nextButtonText = 'Next',
    this.previousButtonText = 'Previous',
    this.submitButtonText = 'Submit',
    this.indicatorType = IndicatorType.dots,
    this.usePageView = false,
    this.transitionType = TransitionType.none,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  /// The form pages to display in sequence.
  final List<MultiStepFormPage> pages;

  /// Optional controller for programmatic navigation and validation helpers.
  final UnifiedMultiStepFormController? controller;

  /// Called after the final step has been validated successfully.
  final VoidCallback? onSubmit;

  /// Called whenever the active step changes.
  final ValueChanged<int>? onStepChanged;

  /// Initial step index.
  final int initialStep;

  /// Padding applied around each step body.
  final EdgeInsetsGeometry padding;

  /// Active indicator color.
  final Color? indicatorActiveColor;

  /// Inactive indicator color.
  final Color? indicatorInactiveColor;

  /// Indicator style.
  final IndicatorType indicatorType;

  /// Whether to use [PageView] instead of [IndexedStack].
  final bool usePageView;

  /// Transition style used in [PageView] mode.
  final TransitionType transitionType;

  /// Transition duration used in [PageView] mode.
  final Duration transitionDuration;

  /// Text for the next button.
  final String nextButtonText;

  /// Text for the previous button.
  final String previousButtonText;

  /// Text for the submit button.
  final String submitButtonText;

  @override
  State<UnifiedMultiStepForm> createState() => _UnifiedMultiStepFormState();
}

class _UnifiedMultiStepFormState extends State<UnifiedMultiStepForm> {
  late final UnifiedMultiStepFormController _controller;
  late final VoidCallback _controllerListener;
  late int _currentStep;
  PageController? _pageController;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        UnifiedMultiStepFormController(initialStep: widget.initialStep);
    _controller.attachStepCount(widget.pages.length);
    _currentStep = _controller.currentStep;

    if (widget.usePageView) {
      _pageController = PageController(initialPage: _currentStep);
      _page = _currentStep.toDouble();
      if (widget.transitionType == TransitionType.fade) {
        _pageController!.addListener(() {
          if (!mounted) return;
          setState(
            () => _page =
                _pageController!.page ??
                _pageController!.initialPage.toDouble(),
          );
        });
      }
    }

    _controllerListener = () {
      if (!mounted) return;
      if (_currentStep != _controller.currentStep) {
        setState(() => _currentStep = _controller.currentStep);
        if (_pageController != null) {
          _pageController!.animateToPage(
            _controller.currentStep,
            duration: widget.transitionDuration,
            curve: Curves.easeInOut,
          );
        }
      }
    };
    _controller.addListener(_controllerListener);
  }

  @override
  void didUpdateWidget(covariant UnifiedMultiStepForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.attachStepCount(widget.pages.length);
    _currentStep = _controller.currentStep;
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _pageController?.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool get _isLastStep => _currentStep >= widget.pages.length - 1;

  bool _validateCurrentStep() {
    return widget.pages[_currentStep].formKey.currentState?.validate() ?? false;
  }

  bool _validateAllSteps() {
    for (final page in widget.pages) {
      final isValid = page.formKey.currentState?.validate() ?? false;
      if (!isValid) {
        return false;
      }
    }
    return true;
  }

  Future<void> _goNext() async {
    if (!_validateCurrentStep()) return;

    final ok = await _controller.validateStepAsync(_currentStep);
    if (!ok) return;

    if (_isLastStep) {
      await _submitIfValid();
      return;
    }

    _controller.next();
    widget.onStepChanged?.call(_controller.currentStep);
  }

  void _goPrevious() {
    if (_controller.isFirstStep) return;
    _controller.previous();
    widget.onStepChanged?.call(_controller.currentStep);
  }

  Future<void> _submitIfValid() async {
    if (!_validateAllSteps()) return;
    final ok = await _controller.validateAllAsync();
    if (!ok) return;
    widget.onSubmit?.call();
  }

  Widget _buildIndicator(BuildContext context) {
    final activeColor =
        widget.indicatorActiveColor ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = widget.indicatorInactiveColor ?? Colors.grey.shade300;
    switch (widget.indicatorType) {
      case IndicatorType.numbers:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pages.length, (index) {
            final active = _currentStep == index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(color: active ? Colors.white : Colors.black87),
              ),
            );
          }),
        );
      case IndicatorType.linear:
        final progress = (widget.pages.isEmpty)
            ? 0.0
            : (_currentStep + 1) / widget.pages.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: LinearProgressIndicator(
            value: progress,
            color: activeColor,
            backgroundColor: inactiveColor,
          ),
        );
      case IndicatorType.dots:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: _currentStep == index ? 28 : 10,
              height: 8,
              decoration: BoxDecoration(
                color: _currentStep == index ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildPage(BuildContext context, MultiStepFormPage page) {
    return Form(
      key: page.formKey,
      child: SingleChildScrollView(
        padding: widget.padding,
        child: page.title == null
            ? page.builder(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      page.title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  page.builder(context),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const SizedBox.shrink();
    }

    final pages = widget.pages
        .map((page) => _buildPage(context, page))
        .toList(growable: false);

    Widget pagesWidget;
    if (widget.usePageView) {
      final scrollDirection = widget.transitionType == TransitionType.vertical
          ? Axis.vertical
          : Axis.horizontal;
      pagesWidget = PageView.builder(
        controller: _pageController,
        scrollDirection: scrollDirection,
        onPageChanged: (i) => _controller.goTo(i),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final child = pages[index];
          if (widget.transitionType == TransitionType.fade) {
            final opacity = 1.0 - (_page - index).abs().clamp(0.0, 1.0);
            return Opacity(opacity: opacity, child: child);
          }
          return child;
        },
      );
    } else {
      pagesWidget = IndexedStack(index: _currentStep, children: pages);
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Step ${_currentStep + 1} of ${widget.pages.length}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        _buildIndicator(context),
        const SizedBox(height: 16),
        Expanded(child: pagesWidget),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!_controller.isFirstStep)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goPrevious,
                    child: Text(widget.previousButtonText),
                  ),
                ),
              if (!_controller.isFirstStep) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLastStep ? _submitIfValid : _goNext,
                  child: Text(
                    _isLastStep
                        ? widget.submitButtonText
                        : widget.nextButtonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
