// NexaBank — 5-Step Transfer Flow UI
// Choose Account -> Choose Recipient -> Enter Amount -> Review -> Success
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../bloc/transfer_bloc.dart';
import '../data/transfer_repository.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferBloc, TransferState>(
      listenWhen: (_, curr) => curr is TransferSuccess || curr is TransferFailed,
      listener: (context, state) {
        if (state is TransferSuccess) {
          _showSuccessDialog(context, state.result);
        } else if (state is TransferFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.reason), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Send Money'),
            leading: state is! TransferSelectingAccount
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        context.read<TransferBloc>().add(const TransferReset()),
                  )
                : null,
          ),
          body: _buildStep(context, state),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, TransferState state) {
    return switch (state) {
      TransferSelectingAccount() => const _AccountStep(),
      TransferSelectingBeneficiary(:final beneficiaries, :final isLoading) =>
        _BeneficiaryStep(beneficiaries: beneficiaries, isLoading: isLoading),
      TransferEnteringAmount(:final beneficiary) =>
        _AmountStep(beneficiary: beneficiary),
      TransferReadyToSubmit(:final account, :final beneficiary, :final amount, :final reference) =>
        _ReviewStep(
            account: account,
            beneficiary: beneficiary,
            amount: amount,
            reference: reference),
      TransferInProgress() => const _LoadingStep(),
      TransferSuccess() || TransferFailed() =>
        const Center(child: Text('Done')),
      // TODO: Handle this case.
      TransferState() => throw UnimplementedError(),
    };
  }

  void _showSuccessDialog(BuildContext context, TransferResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: AppColors.successBackground, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('Transfer Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              result.rail == 'INSTANT'
                  ? 'Funds will arrive within 2 minutes'
                  : 'Funds will arrive within 24 hours',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text('Ref: ${result.transferId.substring(0, 8).toUpperCase()}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<TransferBloc>().add(const TransferReset());
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 1: choose which account to send from.
/// Reuses the already-loaded AccountBloc rather than re-fetching accounts.
class _AccountStep extends StatelessWidget {
  const _AccountStep();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is! AccountLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.accounts.isEmpty) {
          return const Center(child: Text('No accounts available'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Send from', style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.accounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final acc = state.accounts[i];
                  return _AccountTile(
                    account: acc,
                    onTap: () => context
                        .read<TransferBloc>()
                        .add(TransferAccountSelected(acc)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  const _AccountTile({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(account.accountNumber,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(account.availableBalance, currency: account.currency),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 2: choose the beneficiary, sourced from TransferRepository via the bloc.
class _BeneficiaryStep extends StatelessWidget {
  final List<Beneficiary> beneficiaries;
  final bool isLoading;
  const _BeneficiaryStep({required this.beneficiaries, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Send to', style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search beneficiaries',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : beneficiaries.isEmpty
                  ? const Center(child: Text('No beneficiaries yet'))
                  : ListView.builder(
                      itemCount: beneficiaries.length,
                      itemBuilder: (context, i) {
                        final b = beneficiaries[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(b.name[0],
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(b.name),
                          subtitle: Text('${b.bankName} · ${b.accountNumber}'),
                          onTap: () => context
                              .read<TransferBloc>()
                              .add(TransferBeneficiarySelected(b)),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _AmountStep extends StatefulWidget {
  final Beneficiary beneficiary;
  const _AmountStep({required this.beneficiary});

  @override
  State<_AmountStep> createState() => _AmountStepState();
}

class _AmountStepState extends State<_AmountStep> {
  final _controller = TextEditingController();
  final _referenceController = TextEditingController();
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sending to', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(widget.beneficiary.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(widget.beneficiary.bankName,
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 40),
          Center(
            child: Text(
              CurrencyFormatter.format(_amount),
              style: const TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (PHP)',
              prefixText: '₱ ',
            ),
            onChanged: (v) {
              setState(() => _amount = double.tryParse(v) ?? 0);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference (optional)',
              hintText: 'e.g. Rent July 2024',
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _amount > 0
                ? () {
                    context.read<TransferBloc>().add(TransferAmountSet(_amount));
                    if (_referenceController.text.isNotEmpty) {
                      context.read<TransferBloc>().add(
                          TransferReferenceSet(_referenceController.text));
                    }
                  }
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final Account account;
  final Beneficiary beneficiary;
  final double amount;
  final String? reference;
  const _ReviewStep({
    required this.account,
    required this.beneficiary,
    required this.amount,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Transfer', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          _ReviewRow('From', '${account.name} (${account.accountNumber})'),
          _ReviewRow('Amount', '${CurrencyFormatter.format(amount)} PHP'),
          _ReviewRow('To', beneficiary.name),
          _ReviewRow('Bank', beneficiary.bankName),
          _ReviewRow('Account', beneficiary.accountNumber),
          if (reference != null) _ReviewRow('Reference', reference!),
          _ReviewRow('Processing', amount < 1000 ? '⚡ Instant' : '🕐 24 hours'),
          const Spacer(),
          const Text(
            'By tapping Confirm, you authorise this payment.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                context.read<TransferBloc>().add(const TransferSubmitted()),
            child: const Text('Confirm Transfer'),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Processing transfer...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
}
