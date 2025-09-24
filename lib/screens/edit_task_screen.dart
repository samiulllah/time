import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _motivationController;

  bool _isForMe = false;
  Category? _selectedCategory;
  double? _selectedHours;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _motivationController =
        TextEditingController(text: widget.task.motivation ?? "");
    _isForMe = widget.task.isForMe;
    _selectedHours = widget.task.timeNeeded;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    // set initial category
    _selectedCategory = provider.categories.firstWhere(
          (c) => c.id == widget.task.categoryId,
      orElse: () => provider.categories.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
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

              // Category
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: provider.categories
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Time
              DropdownButtonFormField<double>(
                value: _selectedHours,
                items: [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
                    .map((h) =>
                    DropdownMenuItem(value: h, child: Text("$h hours")))
                    .toList(),
                onChanged: (val) => setState(() => _selectedHours = val),
                decoration: const InputDecoration(
                  labelText: "Time Needed",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Motivation
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(
                  labelText: "Motivation (Why)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Ownership
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Update Task"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.task.title = _titleController.text;
                      widget.task.categoryId = _selectedCategory?.id;
                      widget.task.timeNeeded = _selectedHours;
                      widget.task.motivation = _motivationController.text;
                      widget.task.isForMe = _isForMe;

                      provider.updateTask(widget.task);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task updated")),
                      );
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
