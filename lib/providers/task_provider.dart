import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../services/alarm_manager_service.dart'; // ✅ added

class TaskProvider with ChangeNotifier {
  final _dbHelper = DatabaseHelper();

  List<Task> ideaDump = [];
  List<Task> focus = [];
  List<Task> blocked = [];
  List<Task> completed = [];
  List<Category> categories = [];

  Future loadTasks() async {
    ideaDump = await _dbHelper.getTasksByStatus("idea_dump");
    focus = await _dbHelper.getTasksByStatus("focus");
    blocked = await _dbHelper.getTasksByStatus("blocked");
    completed = await _dbHelper.getTasksByStatus("completed");
    categories = await _dbHelper.getCategories();

    // ✅ Refresh alarms with latest snapshot of tasks
    await AlarmManagerService.scheduleDynamicSummaries();

    notifyListeners();
  }

  // ---------- Category ----------
  Future addCategory(Category category) async {
    await _dbHelper.insertCategory(category);
    await loadTasks();
  }

  Future deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    await loadTasks();
  }

  // ---------- Tasks ----------
  Future addTask(Task task) async {
    await _dbHelper.insertTask(task);
    await loadTasks();
  }

  Future updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    await loadTasks();
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    final result = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await loadTasks();
    return result;
  }

  Future completeTask(Task task) async {
    task.status = "completed";
    task.completedAt = DateTime.now();
    await _dbHelper.updateTask(task);
    await loadTasks();
  }

  Future blockTask(Task task) async {
    task.status = "blocked";
    await _dbHelper.updateTask(task);
    await loadTasks();
  }

  Future returnTask(Task task) async {
    task.status = "idea_dump";
    task.completedAt = null;
    await _dbHelper.updateTask(task);
    await loadTasks();
  }

  // ---------- Helpers ----------
  String getCategoryName(int? id) {
    if (id == null) return "Uncategorized";
    final cat = categories.firstWhere(
          (c) => c.id == id,
      orElse: () => Category(id: 0, name: "Uncategorized"),
    );
    return cat.name;
  }

  int completedToday() {
    final today = DateTime.now();
    return completed.where((t) =>
    t.completedAt != null &&
        t.completedAt!.year == today.year &&
        t.completedAt!.month == today.month &&
        t.completedAt!.day == today.day).length;
  }

  int completedThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final weekEnd = weekStart.add(const Duration(days: 6)); // Sunday
    return completed.where((t) =>
    t.completedAt != null &&
        t.completedAt!.isAfter(weekStart) &&
        t.completedAt!.isBefore(weekEnd.add(const Duration(days: 1)))).length;
  }
}
