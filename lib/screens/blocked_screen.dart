import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Blocked / Pending")),
      body: taskProvider.blocked.isEmpty
          ? const Center(child: Text("No blocked tasks."))
          : ListView.builder(
        itemCount: taskProvider.blocked.length,
        itemBuilder: (context, index) {
          final task = taskProvider.blocked[index];
          return TaskTile(
            task: task,
            onTap: () {
              // Unblock → return to Idea Dump
              taskProvider.returnTask(task);
            },
          );
        },
      ),
    );
  }
}
