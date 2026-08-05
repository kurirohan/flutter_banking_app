// PayMaye — 5-Step Transfer Flow UI
// Choose Account -> Choose Recipient -> Enter Amount -> Review -> Success
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../accounts/bloc/account_bloc.dart';
import '../../accounts/data/account_repository.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
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
          // Apply the transfer to local account state: debit the balance
          // and splice the new transaction into history. This is the seam
          // a real backend would replace later — swap this dispatch for a
          // response-driven refresh and nothing else here has to change.
          context.read<AccountBloc>().add(AccountTransferApplied(
                accountId: state.account.id,
                amount: state.amount,
                transaction: Transaction(
                  id: state.result.transferId,
                  type: 'DEBIT',
                  amount: state.amount,
                  currency: state.account.currency,
                  bookingDate: DateTime.now(),
                  description: 'Transfer to ${state.beneficiary.name}',
                  merchantName: state.beneficiary.name,
                  category: 'Transfer',
                ),
              ));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sent ${CurrencyFormatter.format(state.amount, currency: state.account.currency)} to ${state.beneficiary.name}',
              ),
              backgroundColor: AppColors.success,
            ),
          );

          _showSuccessDialog(context, state);
        } else if (state is TransferFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.reason), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('Send Money'),
            leading: state is! TransferSelectingAccount
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
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
      // Catch-all: TransferState isn't sealed, so the analyzer can't prove
      // the cases above are exhaustive on their own. This keeps the UI safe
      // if a new state is ever added without a matching case here.
      _ => const SizedBox(),
    };
  }

  void _showSuccessDialog(BuildContext context, TransferSuccess state) {
    final result = state.result;
    final reference = result.transferId.substring(0, 8).toUpperCase();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                  color: AppColors.successBackground, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Transfer successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              result.rail == 'INSTANT'
                  ? 'Funds will arrive within 2 minutes'
                  : 'Funds will arrive within 24 hours',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.fog,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Column(
                children: [
                  _ReceiptRow('Amount', CurrencyFormatter.format(state.amount, currency: state.account.currency)),
                  _ReceiptRow('From', state.account.name),
                  _ReceiptRow('To', state.beneficiary.name),
                  if (state.reference != null) _ReceiptRow('Note', state.reference!),
                  _ReceiptRow('Reference', reference, isLast: true),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransferBloc>().add(const TransferReset());
                context.go('/accounts');
              },
              child: const Text('View transaction history'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransferBloc>().add(const TransferReset());
              },
              child: const Text('Send another transfer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _ReceiptRow(this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink),
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
          return const Center(child: CircularProgressIndicator(color: AppColors.violet));
        }
        if (state.accounts.isEmpty) {
          return const Center(child: Text('No accounts available'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text('Send from', style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: state.accounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.fog,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.violet),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(account.accountNumber,
                        style: const TextStyle(color: AppColors.inkFaint, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(account.availableBalance, currency: account.currency),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
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
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text('Send to', style: Theme.of(context).textTheme.titleLarge),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search beneficiaries',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.violet))
              : beneficiaries.isEmpty
                  ? const Center(child: Text('No beneficiaries yet'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: beneficiaries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final b = beneficiaries[i];
                        final pair = AppColors.pastelPalette[i % AppColors.pastelPalette.length];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            onTap: () => context
                                .read<TransferBloc>()
                                .add(TransferBeneficiarySelected(b)),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: pair[0],
                                    child: Text(b.name[0],
                                        style: TextStyle(
                                            color: pair[1], fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(b.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700, color: AppColors.ink)),
                                        const SizedBox(height: 2),
                                        Text('${b.bankName} · ${b.accountNumber}',
                                            style: const TextStyle(
                                                color: AppColors.inkFaint, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
                                ],
                              ),
                            ),
                          ),
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sending to', style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 4),
          Text(widget.beneficiary.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
          Text(widget.beneficiary.bankName,
              style: const TextStyle(color: AppColors.inkFaint)),
          const SizedBox(height: AppSpacing.huge),
          Center(
            child: Text(
              CurrencyFormatter.format(_amount),
              style: const TextStyle(
                  fontSize: 46, fontWeight: FontWeight.w800, letterSpacing: -1, color: AppColors.ink),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: 'Amount (PHP)',
              prefixText: '₱ ',
            ),
            onChanged: (v) {
              setState(() => _amount = double.tryParse(v) ?? 0);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review transfer', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              children: [
                _ReviewRow('From', '${account.name} (${account.accountNumber})'),
                _ReviewRow('Amount', '${CurrencyFormatter.format(amount)} PHP'),
                _ReviewRow('To', beneficiary.name),
                _ReviewRow('Bank', beneficiary.bankName),
                _ReviewRow('Account', beneficiary.accountNumber),
                if (reference != null) _ReviewRow('Reference', reference!),
                _ReviewRow('Processing', amount < 1000 ? '⚡ Instant' : '🕐 24 hours', isLast: true),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'By tapping Confirm, you authorise this payment.',
            style: TextStyle(color: AppColors.inkFaint, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () =>
                context.read<TransferBloc>().add(const TransferSubmitted()),
            child: const Text('Confirm transfer'),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _ReviewRow(this.label, this.value, {this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
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
            CircularProgressIndicator(color: AppColors.violet),
            SizedBox(height: AppSpacing.xxl),
            Text('Processing transfer...',
                style: TextStyle(fontSize: 16, color: AppColors.inkMuted)),
          ],
        ),
      );
}
