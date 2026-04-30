import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/transaction_model.dart';
import '../../database/hive_database.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/wallet_model.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Add Transaction Screen
// ============================================================

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // If editing

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedWallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<WalletProvider>().loadWallets();
    });

    if (widget.transaction != null) {
      _type = widget.transaction!.transactionType;
      _amountCtrl.text = widget.transaction!.amount.toString();
      _noteCtrl.text = widget.transaction!.note;
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.categoryId;
      _selectedWallet = widget.transaction!.walletId;
    } else {
      // Set defaults if available
      final wallets = context.read<WalletProvider>().wallets;
      if (wallets.isNotEmpty) _selectedWallet = wallets.first.id;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      AppUtils.showSnackBar(context, 'Please select a category', isError: true);
      return;
    }
    if (_selectedWallet == null) {
      AppUtils.showSnackBar(context, 'Please select a wallet', isError: true);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      AppUtils.showSnackBar(
        context,
        'Please enter a valid amount',
        isError: true,
      );
      return;
    }

    final t = TransactionModel(
      id: widget.transaction?.id ?? HiveDatabase.generateId(),
      type: _type.name,
      amount: amount,
      categoryId: _selectedCategory!,
      walletId: _selectedWallet!,
      note: _noteCtrl.text.trim(),
      date: _selectedDate,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
    );

    final provider = context.read<TransactionProvider>();
    final walletProvider = context.read<WalletProvider>();
    if (widget.transaction == null) {
      await provider.addTransaction(t);
      if (mounted) {
        AppUtils.showSnackBar(context, 'Transaction added successfully');
      }
    } else {
      await provider.updateTransaction(widget.transaction!, t);
      if (mounted) AppUtils.showSnackBar(context, 'Transaction updated');
    }

    walletProvider.loadWallets();
    if (mounted) context.read<BudgetProvider>().loadBudgets();
    if (mounted) Navigator.pop(context);
  }

  void _showCurrencyConverter() {
    final settings = context.read<SettingsProvider>();

    final convertAmountCtrl = TextEditingController();
    String convertedResult = '';
    bool isConverting = false;

    final Map<String, String> currencySymbolToCode = {
      '₹': 'INR',
      '\$': 'USD',
      '€': 'EUR',
      '£': 'GBP',
      '¥': 'JPY',
      'A\$': 'AUD',
      'C\$': 'CAD',
    };

    final List<String> currencies = [
      'USD',
      'EUR',
      'GBP',
      'INR',
      'JPY',
      'AUD',
      'CAD',
      'CNY',
      'BRL',
      'KRW',
      'SGD',
      'HKD',
      'SEK',
      'NOK',
      'DKK',
      'MXN',
      'ZAR',
      'NZD',
      'CHF',
      'RUB',
    ];

    final toCurrency = currencySymbolToCode[settings.currency] ?? 'INR';
    // Ensure the default 'from' currency is never the same as 'to' currency
    String selectedFromCurrency = toCurrency == 'USD' ? 'EUR' : 'USD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💱 Currency Converter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Convert to ${settings.currency} ($toCurrency)',
                  style: TextStyle(
                    color: Theme.of(ctx).brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFromCurrency,
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: currencies
                            .where((c) => c != toCurrency)
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedFromCurrency = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: convertAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isConverting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync_alt),
                    label: Text(isConverting ? 'Converting...' : 'Convert'),
                    onPressed: isConverting
                        ? null
                        : () async {
                            final amount = double.tryParse(
                              convertAmountCtrl.text.replaceAll(',', ''),
                            );
                            if (amount == null || amount <= 0) {
                              setSheetState(
                                () => convertedResult = 'Enter a valid amount',
                              );
                              return;
                            }
                            setSheetState(() => isConverting = true);
                            try {
                              final url = Uri.parse(
                                'https://api.exchangerate-api.com/v4/latest/$selectedFromCurrency',
                              );
                              final response = await http.get(url);
                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                final rates =
                                    data['rates'] as Map<String, dynamic>;
                                final rate = rates[toCurrency];
                                if (rate != null) {
                                  final converted =
                                      amount * (rate as num).toDouble();
                                  setSheetState(() {
                                    convertedResult =
                                        '${settings.currency} ${converted.toStringAsFixed(2)}';
                                    isConverting = false;
                                  });
                                } else {
                                  setSheetState(() {
                                    convertedResult =
                                        'Rate not found for $toCurrency';
                                    isConverting = false;
                                  });
                                }
                              } else {
                                setSheetState(() {
                                  convertedResult =
                                      'API error (${response.statusCode})';
                                  isConverting = false;
                                });
                              }
                            } catch (e) {
                              setSheetState(() {
                                convertedResult = 'Network error: $e';
                                isConverting = false;
                              });
                            }
                          },
                  ),
                ),
                if (convertedResult.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          convertedResult,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Extract numeric value from result
                            final numStr = convertedResult
                                .replaceAll(settings.currency, '')
                                .trim();
                            final val = double.tryParse(numStr);
                            if (val != null) {
                              _amountCtrl.text = val.toStringAsFixed(2);
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('Use this amount'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium specific colors
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.transaction == null ? 'New Transaction' : 'Edit Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Currency Converter',
            onPressed: _showCurrencyConverter,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer3<CategoryProvider, WalletProvider, SettingsProvider>(
          builder: (context, catProvider, walletProvider, settings, child) {
            final categories = _type == TransactionType.income
                ? catProvider.incomeCategories
                : catProvider.expenseCategories;

            if (_selectedCategory != null &&
                !categories.any((c) => c.id == _selectedCategory)) {
              _selectedCategory = null;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Type Toggle ---
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TypeButton(
                              title: 'Expense',
                              isSelected: _type == TransactionType.expense,
                              color: AppColors.expense,
                              onTap: () => setState(
                                () => _type = TransactionType.expense,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _TypeButton(
                              title: 'Income',
                              isSelected: _type == TransactionType.income,
                              color: AppColors.income,
                              onTap: () => setState(
                                () => _type = TransactionType.income,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Amount Area ---
                    Center(
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _type == TransactionType.income
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.2),
                            ),
                            prefixText: settings.currency,
                            prefixStyle: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _type == TransactionType.income
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return '*';
                            if (double.tryParse(val.replaceAll(',', '')) ==
                                null) {
                              return '*';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    // Currency converter shortcut
                    Center(
                      child: TextButton.icon(
                        onPressed: _showCurrencyConverter,
                        icon: const Icon(Icons.currency_exchange, size: 16),
                        label: const Text('Convert from another currency'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Categorization ---
                    _buildSectionTitle('Category'),
                    if (categories.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'No categories available. Add one in settings.',
                          style: TextStyle(color: AppColors.expense),
                        ),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = _selectedCategory == cat.id;
                            final catColor = AppUtils.colorFromHex(cat.color);
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 85,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? catColor.withValues(alpha: 0.1)
                                      : cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? catColor : borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? catColor
                                            : catColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        CategoryIcons.getIcon(cat.icon),
                                        color: isSelected
                                            ? Colors.white
                                            : catColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? catColor
                                            : (isDark
                                                  ? Colors.white70
                                                  : Colors.black87),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32),

                    // --- Details Row (Wallet & Date) ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectorCard(
                            title: 'Wallet',
                            icon: Icons.account_balance_wallet_rounded,
                            value: walletProvider.wallets
                                .firstWhere(
                                  (w) => w.id == _selectedWallet,
                                  orElse: () => walletProvider.wallets.first,
                                )
                                .name,
                            onTap: () => _showWalletPicker(
                              context,
                              walletProvider.wallets,
                            ),
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSelectorCard(
                            title: 'Date',
                            icon: Icons.calendar_month_rounded,
                            value: DateFormat(
                              'MMM dd, yyyy',
                            ).format(_selectedDate),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Note Area ---
                    _buildSectionTitle('Note (Optional)'),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextFormField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'What was this for?',
                          prefixIcon: Icon(Icons.notes_rounded),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- Save Button ---
                    PrimaryButton(
                      label: widget.transaction == null
                          ? 'Save Transaction'
                          : 'Update Transaction',
                      onPressed: _save,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required Color cardColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(BuildContext context, List<WalletModel> wallets) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...wallets.map(
                (w) => ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    w.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: w.id == _selectedWallet
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedWallet = w.id);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
