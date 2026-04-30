import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/category_model.dart';
import '../../database/hive_database.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/category_provider.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Category Manager Screen
// ============================================================

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Categories')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Expense'),
                      Tab(text: 'Income'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CategoryList(
                        categories: provider.expenseCategories,
                        type: 'expense',
                      ),
                      _CategoryList(
                        categories: provider.incomeCategories,
                        type: 'income',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, 'expense'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, String initialType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddCategorySheet(initialType: initialType),
    );
  }
}

// ============================================================
// Internal List Widget
// ============================================================

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String type;

  const _CategoryList({required this.categories, required this.type});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = AppUtils.colorFromHex(cat.color);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark ? AppColors.darkCard : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CategoryIcons.getIcon(cat.icon), color: color),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              onPressed: () async {
                final confirm = await AppUtils.showConfirmDialog(
                  context,
                  title: 'Delete Category',
                  message: 'Are you sure you want to delete ${cat.name}?',
                  isDanger: true,
                );
                if (confirm && context.mounted) {
                  context.read<CategoryProvider>().deleteCategory(cat.id);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// Add/Edit Bottom Sheet
// ============================================================

class _AddCategorySheet extends StatefulWidget {
  final String initialType;

  const _AddCategorySheet({required this.initialType});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  late String _type;
  String _selectedIcon = 'other';
  String _selectedColor = '#6C5CE7';

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppUtils.showSnackBar(context, 'Please enter a name', isError: true);
      return;
    }

    final cat = CategoryModel(
      id: HiveDatabase.generateId(),
      name: name,
      icon: _selectedIcon,
      color: _selectedColor,
      type: _type,
    );

    context.read<CategoryProvider>().addCategory(cat);
    Navigator.pop(context);
    AppUtils.showSnackBar(context, 'Category saved');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                const Text(
                  'New Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Type selector
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Expense'),
                        value: 'expense',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                        activeColor: AppColors.expense,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Income'),
                        value: 'income',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                        activeColor: AppColors.income,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Shopping, Salary',
                  ),
                ),
                const SizedBox(height: 24),

                // Icon
                const Text(
                  'Select Icon',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                IconSelector(
                  selectedIcon: _selectedIcon,
                  onSelected: (icon) => setState(() => _selectedIcon = icon),
                ),
                const SizedBox(height: 24),

                // Color
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ColorSelector(
                  selectedColor: _selectedColor,
                  onSelected: (color) => setState(() => _selectedColor = color),
                ),
                const SizedBox(height: 48),

                PrimaryButton(label: 'Save', onPressed: _save),
              ],
            ),
          );
        },
      ),
    );
  }
}
