import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';

class TaskInputDialog extends StatefulWidget {
  const TaskInputDialog({super.key});

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _motivationController = TextEditingController();
  bool _isForMe = false;
  Category? _selectedCategory;
  double? _selectedHours;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Task Title"),
                  validator: (val) =>
                  val == null || val.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  items: provider.categories
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  decoration: const InputDecoration(labelText: "Category"),
                  validator: (val) =>
                  val == null ? "Please select category" : null,
                ),
                const SizedBox(height: 12),

                // Time Needed (hours)
                DropdownButtonFormField<double>(
                  value: _selectedHours,
                  items: [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
                      .map((h) => DropdownMenuItem<double>(
                    value: h,
                    child: Text("$h hours"),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedHours = val),
                  decoration: const InputDecoration(labelText: "Time Needed"),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _motivationController,
                  decoration:
                  const InputDecoration(labelText: "Motivation (Why)"),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _isForMe,
                      onChanged: (val) =>
                          setState(() => _isForMe = val ?? false),
                    ),
                    const Text("Is this task for me?"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Add"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final task = Task(
                title: _titleController.text,
                categoryId: _selectedCategory?.id,
                timeNeeded: _selectedHours,
                motivation: _motivationController.text,
                isForMe: _isForMe,
              );
              provider.addTask(task);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
