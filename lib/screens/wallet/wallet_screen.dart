import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../database/hive_database.dart';
import '../../widgets/app_drawer.dart';
import 'package:flutter/services.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Wallet Management Screen
// ============================================================

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Wallets & Accounts')),
      body: Consumer2<WalletProvider, SettingsProvider>(
        builder: (context, provider, settings, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final wallets = provider.wallets;

          return Column(
            children: [
              // Total Balance
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Net Worth',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatCurrency(
                            provider.totalBalance,
                            symbol: settings.currency,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final w = wallets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: isDark ? AppColors.darkCard : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.divider,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          w.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text('Active'),
                        trailing: Text(
                          AppUtils.formatCurrency(
                            w.balance,
                            symbol: settings.currency,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => _showAddDialog(context, wallet: w),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {WalletModel? wallet}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddWalletSheet(wallet: wallet),
    );
  }
}

// ============================================================
// Add/Edit Bottom Sheet
// ============================================================

class _AddWalletSheet extends StatefulWidget {
  final WalletModel? wallet;

  const _AddWalletSheet({this.wallet});

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      _nameCtrl.text = widget.wallet!.name;
      
      // Look for an existing Initial Balance transaction to pre-fill the textbox
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final db = HiveDatabase();
        final allTx = db.getAllTransactions();
        final initialTx = allTx.where((t) => t.walletId == widget.wallet!.id && t.note == 'Initial Balance' && t.type == 'income').firstOrNull;
        
        if (initialTx != null) {
          _balanceCtrl.text = initialTx.amount.toString();
        } else {
          _balanceCtrl.text = '0.0';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) {
        AppUtils.showSnackBar(context, 'Enter a name', isError: true);
        return;
      }

    final walletProvider = context.read<WalletProvider>();
    final txProvider = context.read<TransactionProvider>();

    final balance =
        double.tryParse(_balanceCtrl.text.replaceAll(',', '')) ?? 0.0;
        
    if (widget.wallet == null) {
      // Adding a new wallet
      final w = WalletModel(
        id: HiveDatabase.generateId(),
        name: name,
        icon: 'credit_card', // Simplified for demo
        balance: 0.0, // New wallets start with 0 balance, transactions adjust it
      );
      await walletProvider.addWallet(w);

      if (balance > 0) {
        // Automatically create an 'Initial Balance' transaction
        final tx = TransactionModel(
          id: HiveDatabase.generateId(),
          type: 'income',
          amount: balance,
          categoryId: 'cat_salary', // Using a default income category ID
          walletId: w.id,
          note: 'Initial Balance',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await txProvider.addTransaction(tx);
      }
    } else {
      // Editing an existing wallet
      final w = WalletModel(
        id: widget.wallet!.id,
        name: name,
        icon: widget.wallet!.icon,
        balance: widget.wallet!.balance, // Keep current balance strictly
      );
      await walletProvider.updateWallet(w);

      // Handle Initial Balance updates
      final db = HiveDatabase();
      final allTx = db.getAllTransactions();
      final oldInitialTx = allTx.where((t) => t.walletId == w.id && t.note == 'Initial Balance' && t.type == 'income').firstOrNull;

      if (oldInitialTx != null) {
        if (balance == 0) {
           await txProvider.deleteTransaction(oldInitialTx);
        } else if (oldInitialTx.amount != balance) {
           final newTx = TransactionModel(
             id: oldInitialTx.id,
             type: 'income',
             amount: balance,
             categoryId: oldInitialTx.categoryId,
             walletId: w.id,
             note: 'Initial Balance',
             date: oldInitialTx.date,
             createdAt: oldInitialTx.createdAt,
           );
           await txProvider.updateTransaction(oldInitialTx, newTx);
        }
      } else if (balance > 0) {
        // Create an Initial Balance transaction if it didn't exist but user entered one
        final newTx = TransactionModel(
          id: HiveDatabase.generateId(),
          type: 'income',
          amount: balance,
          categoryId: 'cat_salary',
          walletId: w.id,
          note: 'Initial Balance',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await txProvider.addTransaction(newTx);
      }
    }

    walletProvider.loadWallets();

    if (mounted) Navigator.pop(context);
    if (mounted) AppUtils.showSnackBar(context, 'Wallet saved');
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Error saving wallet: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              widget.wallet == null ? 'Add Wallet' : 'Edit Wallet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  hintText: 'e.g. Chase Bank, Cash',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: widget.wallet == null ? 'Initial Balance' : 'Adjust Initial Balance',
                  hintText: '0.00',
                  prefixText: '${context.read<SettingsProvider>().currency} ',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 32),

            Row(
              children: [
                if (widget.wallet != null) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        context.read<WalletProvider>().deleteWallet(
                          widget.wallet!.id,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: PrimaryButton(label: 'Save', onPressed: _save),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }
}
