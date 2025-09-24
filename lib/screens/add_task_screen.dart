import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _motivationController = TextEditingController();

  bool _isForMe = false;
  int? _selectedCategoryId; // ✅ use ID instead of Category object
  double? _selectedHours;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Title ----
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // ---- Category Dropdown ----
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: provider.categories
                    .map((c) =>
                    DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null ? "Please select category" : null,
              ),
              const SizedBox(height: 20),

              // ---- Time Needed Dropdown ----
              DropdownButtonFormField<double>(
                value: _selectedHours,
                items: [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
                    .map((h) => DropdownMenuItem<double>(
                  value: h,
                  child: Text("$h hours"),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedHours = val),
                decoration: const InputDecoration(
                  labelText: "Time Needed",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // ---- Motivation ----
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(
                  labelText: "Motivation (Why)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ---- Ownership Checkbox ----
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
              const SizedBox(height: 20),

              // ---- Submit Button ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Task"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final task = Task(
                        title: _titleController.text,
                        categoryId: _selectedCategoryId,
                        timeNeeded: _selectedHours,
                        motivation: _motivationController.text,
                        isForMe: _isForMe,
                      );
                      provider.addTask(task);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
