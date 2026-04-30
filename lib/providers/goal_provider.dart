import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../database/hive_database.dart';

class GoalProvider with ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();
  List<GoalModel> _goals = [];

  List<GoalModel> get goals => _goals;

  void loadGoals() {
    _goals = _db.getGoals();
    _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    notifyListeners();
  }

  Future<void> addGoal(GoalModel goal) async {
    _goals.add(goal);
    await _db.saveGoals(_goals);
    loadGoals();
  }

  Future<void> updateGoal(GoalModel goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _db.saveGoals(_goals);
      loadGoals();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _db.saveGoals(_goals);
    loadGoals();
  }

  void clearData() {
    loadGoals();
  }
}
