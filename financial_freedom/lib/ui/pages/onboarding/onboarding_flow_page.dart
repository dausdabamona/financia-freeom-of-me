import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_freedom/core/di/injection.dart';
import 'package:financial_freedom/ui/bloc/onboarding/onboarding.dart';
import 'package:financial_freedom/ui/pages/onboarding/account_setup_page.dart';
import 'package:financial_freedom/ui/pages/onboarding/baseline_setup_page.dart';
import 'package:financial_freedom/ui/pages/onboarding/asset_liability_page.dart';
import 'package:financial_freedom/ui/pages/onboarding/time_freedom_page.dart';

/// Onboarding Flow Page - Main Stepper Coordinator
///
/// Guides user through 4 steps of reality entry:
/// 1. Accounts - Where do you store money?
/// 2. Baseline - What are your monthly survival costs?
/// 3. Assets & Liabilities - What do you own and owe?
/// 4. Time - How do you spend your time?
///
/// Philosophy: "Melihat realita dengan jujur, bukan mengisi form"
class OnboardingFlowPage extends StatelessWidget {
  const OnboardingFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (context) => getIt<OnboardingBloc>(),
        ),
        BlocProvider<AccountSetupBloc>(
          create: (context) => getIt<AccountSetupBloc>()..add(const LoadAccountsEvent()),
        ),
        BlocProvider<BaselineBloc>(
          create: (context) => getIt<BaselineBloc>()..add(const LoadBaselineEvent()),
        ),
        BlocProvider<AssetLiabilityBloc>(
          create: (context) => getIt<AssetLiabilityBloc>()
            ..add(const LoadAssetsEvent())
            ..add(const LoadLiabilitiesEvent()),
        ),
        BlocProvider<TimeFreedomBloc>(
          create: (context) => getIt<TimeFreedomBloc>()..add(const LoadTimeProfileEvent()),
        ),
      ],
      child: const _OnboardingFlowView(),
    );
  }
}

class _OnboardingFlowView extends StatelessWidget {
  const _OnboardingFlowView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.currentStep == OnboardingStep.completed) {
          // Navigate back to home with refresh
          Navigator.of(context).pop(true); // Return true to indicate completion
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kenali Realitamu'),
            centerTitle: true,
            leading: state.currentStep == OnboardingStep.accounts
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  )
                : null,
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              // Stepper indicator
              _StepperIndicator(currentStep: state.currentStep),

              // Step content
              Expanded(
                child: _buildStepContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, OnboardingState state) {
    switch (state.currentStep) {
      case OnboardingStep.accounts:
        return AccountSetupPage(
          onContinue: () {
            context.read<OnboardingBloc>().add(const NextStepEvent());
          },
        );

      case OnboardingStep.baseline:
        return BaselineSetupPage(
          onContinue: () {
            context.read<OnboardingBloc>().add(const NextStepEvent());
          },
          onBack: () {
            context.read<OnboardingBloc>().add(const PreviousStepEvent());
          },
        );

      case OnboardingStep.assetsLiabilities:
        return AssetLiabilityPage(
          onContinue: () {
            context.read<OnboardingBloc>().add(const NextStepEvent());
          },
          onBack: () {
            context.read<OnboardingBloc>().add(const PreviousStepEvent());
          },
        );

      case OnboardingStep.timeFreedom:
        return TimeFreedomPage(
          onComplete: () {
            context.read<OnboardingBloc>().add(const CompleteOnboardingEvent());
          },
          onBack: () {
            context.read<OnboardingBloc>().add(const PreviousStepEvent());
          },
        );

      case OnboardingStep.completed:
        return const _CompletionView();
    }
  }
}

/// Stepper indicator showing progress
class _StepperIndicator extends StatelessWidget {
  final OnboardingStep currentStep;

  const _StepperIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: [
              _StepDot(
                step: 1,
                label: 'Akun',
                icon: Icons.account_balance_wallet,
                isActive: currentStep == OnboardingStep.accounts,
                isCompleted: _isStepCompleted(OnboardingStep.accounts),
              ),
              _StepConnector(
                isCompleted: _isStepCompleted(OnboardingStep.accounts),
              ),
              _StepDot(
                step: 2,
                label: 'Baseline',
                icon: Icons.receipt_long,
                isActive: currentStep == OnboardingStep.baseline,
                isCompleted: _isStepCompleted(OnboardingStep.baseline),
              ),
              _StepConnector(
                isCompleted: _isStepCompleted(OnboardingStep.baseline),
              ),
              _StepDot(
                step: 3,
                label: 'Aset',
                icon: Icons.balance,
                isActive: currentStep == OnboardingStep.assetsLiabilities,
                isCompleted: _isStepCompleted(OnboardingStep.assetsLiabilities),
              ),
              _StepConnector(
                isCompleted: _isStepCompleted(OnboardingStep.assetsLiabilities),
              ),
              _StepDot(
                step: 4,
                label: 'Waktu',
                icon: Icons.access_time,
                isActive: currentStep == OnboardingStep.timeFreedom,
                isCompleted: _isStepCompleted(OnboardingStep.timeFreedom),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isStepCompleted(OnboardingStep step) {
    final currentIndex = currentStep.index;
    final stepIndex = step.index;
    return stepIndex < currentIndex;
  }
}

/// Single step dot
class _StepDot extends StatelessWidget {
  final int step;
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.step,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : isCompleted
            ? Colors.green
            : Colors.grey;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive || isCompleted ? color : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.grey,
                      size: 18,
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}

/// Connector between steps
class _StepConnector extends StatelessWidget {
  final bool isCompleted;

  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: 20,
      color: isCompleted ? Colors.green : Colors.grey.shade300,
    );
  }
}

/// Completion view shown briefly during snapshot generation
class _CompletionView extends StatelessWidget {
  const _CompletionView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Menyusun Kompas Finansialmu...',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sebentar ya, kami sedang menghitung realita keuanganmu '
              'dan menyiapkan langkah kecil pertamamu.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
