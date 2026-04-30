import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../database/hive_database.dart';

// ============================================================
// Category Provider — State management for categories
// ============================================================

class CategoryProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _expenseCategories = [];
  List<CategoryModel> _incomeCategories = [];

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories => _expenseCategories;
  List<CategoryModel> get incomeCategories => _incomeCategories;

  void loadCategories() {
    _categories = _db.getAllCategories();
    _expenseCategories = _db.getCategoriesByType('expense');
    _incomeCategories = _db.getCategoriesByType('income');
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) => _db.getCategoryById(id);

  Future<void> addCategory(CategoryModel c) async {
    await _db.addCategory(c);
    loadCategories();
  }

  Future<void> updateCategory(CategoryModel c) async {
    await _db.updateCategory(c);
    loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
    loadCategories();
  }

  void clearData() {
    loadCategories();
  }
}
