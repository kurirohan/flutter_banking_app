// NexaBank — Firestore Test Screen
import 'package:flutter/material.dart';
import '../../accounts/data/account_repository.dart';
import '../data/firestore_repository.dart';
import '../viewmodels/firestore_test_view_model.dart';

class FirestoreTestScreen extends StatefulWidget {
  final FirestoreRepository repository;
  const FirestoreTestScreen({super.key, required this.repository});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  late final FirestoreTestViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = FirestoreTestViewModel(repository: widget.repository);
    viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore CRUD Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.reloadAccounts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: viewModel.reloadAccounts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatus(),
                const SizedBox(height: 16),
                _buildAccountsHeader(),
                const SizedBox(height: 12),
                ..._buildAccountCards(),
                const SizedBox(height: 24),
                _buildTransactionsHeader(),
                if (viewModel.selectedAccount == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                        'Select or create an account to manage transactions.'),
                  )
                else
                  ..._buildTransactionSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatus() {
    if (viewModel.errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (viewModel.isLoading) {
      return const Center(child: LinearProgressIndicator());
    }
    return const SizedBox.shrink();
  }

  Widget _buildAccountsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Accounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Account'),
          onPressed: () => _showAccountForm(context),
        ),
      ],
    );
  }

  List<Widget> _buildAccountCards() {
    if (viewModel.accounts.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child:
              Text('No accounts found. Create one to start testing Firestore.'),
        ),
      ];
    }

    return viewModel.accounts.map((account) {
      final selected = viewModel.selectedAccount?.id == account.id;
      return Card(
        color: selected ? Colors.blue.shade50 : null,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          selected: selected,
          title: Text(account.name),
          subtitle: Text(
              '${account.accountNumber} • ${account.currency} • ${account.type}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit account',
                onPressed: () => _showAccountForm(context, account: account),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete account',
                onPressed: () => _confirmDeleteAccount(account),
              ),
            ],
          ),
          onTap: () => viewModel.selectAccount(account),
        ),
      );
    }).toList();
  }

  Widget _buildTransactionsHeader() {
    final accountName = viewModel.selectedAccount?.name ?? 'Account';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transactions for $accountName',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
              onPressed: viewModel.selectedAccount == null
                  ? null
                  : () => _showTransactionForm(context,
                      accountId: viewModel.selectedAccount!.id),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  List<Widget> _buildTransactionSection() {
    if (viewModel.transactions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
              'No transactions exist for this account. Add one to test create behavior.'),
        ),
      ];
    }

    return viewModel.transactions.map((transaction) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(transaction.description),
          subtitle: Text(
              '${transaction.currency} ${transaction.amount.toStringAsFixed(2)} • ${transaction.category} • ${transaction.type}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit transaction',
                onPressed: () => _showTransactionForm(
                  context,
                  accountId: viewModel.selectedAccount!.id,
                  transaction: transaction,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete transaction',
                onPressed: () => _confirmDeleteTransaction(transaction),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showAccountForm(BuildContext context,
      {Account? account}) async {
    final nameController = TextEditingController(text: account?.name ?? '');
    final numberController =
        TextEditingController(text: account?.accountNumber ?? '');
    final balanceController =
        TextEditingController(text: account?.balance.toString() ?? '0');
    final availableBalanceController = TextEditingController(
        text: account?.availableBalance.toString() ?? '0');
    final currencyController =
        TextEditingController(text: account?.currency ?? 'PHP');
    String type = account?.type ?? 'current';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(account == null ? 'Create Account' : 'Update Account'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: numberController,
                    decoration:
                        const InputDecoration(labelText: 'Account Number')),
                TextField(
                    controller: balanceController,
                    decoration: const InputDecoration(labelText: 'Balance'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: availableBalanceController,
                    decoration:
                        const InputDecoration(labelText: 'Available Balance'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: currencyController,
                    decoration: const InputDecoration(labelText: 'Currency')),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'current', child: Text('Current')),
                    DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  ],
                  decoration: const InputDecoration(labelText: 'Type'),
                  onChanged: (value) {
                    if (value != null) type = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final created = Account(
                  id: account?.id ?? '',
                  name: nameController.text.trim(),
                  accountNumber: numberController.text.trim(),
                  balance: double.tryParse(balanceController.text.trim()) ?? 0,
                  availableBalance:
                      double.tryParse(availableBalanceController.text.trim()) ??
                          0,
                  currency: currencyController.text.trim(),
                  type: type,
                );

                if (account == null) {
                  viewModel.createAccount(created);
                } else {
                  viewModel.updateAccount(created);
                }

                Navigator.pop(context);
              },
              child: Text(account == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTransactionForm(
    BuildContext context, {
    required String accountId,
    Transaction? transaction,
  }) async {
    final descriptionController =
        TextEditingController(text: transaction?.description ?? '');
    final amountController =
        TextEditingController(text: transaction?.amount.toString() ?? '0');
    final merchantController =
        TextEditingController(text: transaction?.merchantName ?? '');
    final categoryController =
        TextEditingController(text: transaction?.category ?? 'Other');
    final currencyController =
        TextEditingController(text: transaction?.currency ?? 'PHP');
    String type = transaction?.type ?? 'DEBIT';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(transaction == null
              ? 'Create Transaction'
              : 'Update Transaction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description')),
                TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number),
                TextField(
                    controller: merchantController,
                    decoration: const InputDecoration(labelText: 'Merchant')),
                TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category')),
                TextField(
                    controller: currencyController,
                    decoration: const InputDecoration(labelText: 'Currency')),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'DEBIT', child: Text('DEBIT')),
                    DropdownMenuItem(value: 'CREDIT', child: Text('CREDIT')),
                  ],
                  decoration: const InputDecoration(labelText: 'Type'),
                  onChanged: (value) {
                    if (value != null) type = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final created = Transaction(
                  id: transaction?.id ?? '',
                  type: type,
                  amount: double.tryParse(amountController.text.trim()) ?? 0,
                  currency: currencyController.text.trim(),
                  bookingDate: DateTime.now(),
                  description: descriptionController.text.trim(),
                  merchantName: merchantController.text.trim().isEmpty
                      ? null
                      : merchantController.text.trim(),
                  category: categoryController.text.trim().isEmpty
                      ? 'Other'
                      : categoryController.text.trim(),
                );
                if (transaction == null) {
                  viewModel.createTransaction(accountId, created);
                } else {
                  viewModel.updateTransaction(accountId, created);
                }
                Navigator.pop(context);
              },
              child: Text(transaction == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(Account account) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Text('Delete account "${account.name}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        );
      },
    );
    if (remove == true) {
      await viewModel.deleteAccount(account.id);
    }
  }

  Future<void> _confirmDeleteTransaction(Transaction transaction) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text('Delete transaction "${transaction.description}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        );
      },
    );
    if (remove == true && viewModel.selectedAccount != null) {
      await viewModel.deleteTransaction(
          viewModel.selectedAccount!.id, transaction.id);
    }
  }
}
