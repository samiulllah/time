import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Tasks"),
      ),
      body: taskProvider.completed.isEmpty
          ? const Center(child: Text("No completed tasks yet."))
          : ListView.builder(
        itemCount: taskProvider.completed.length,
        itemBuilder: (context, index) {
          final task = taskProvider.completed[index];
          return CompletedTaskTile(task: task);
        },
      ),
    );
  }
}

class CompletedTaskTile extends StatelessWidget {
  final Task task;

  const CompletedTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isMine = task.isForMe;

    return Dismissible(
      key: ValueKey("completed-${task.id}"),
      direction: DismissDirection.startToEnd, // only swipe right
      background: Container(
        color: Colors.orange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 28),
            SizedBox(width: 6),
            Text(
              "Reopen",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Reopen Task"),
            content: const Text(
                "Do you want to move this task back to your Idea Dump?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Reopen",style: TextStyle(color: Colors.white),),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
        if (confirm == true) {
          task.status = "idea_dump";
          task.completedAt = null;
          taskProvider.updateTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task reopened and moved to Idea Dump")),
          );
        }
        return false; // prevent visual dismiss
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: (isMine ? Colors.indigo : Colors.grey).withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Title + Ownership ----
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.indigo : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isMine ? "Me" : "Other",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "Category: ${taskProvider.getCategoryName(task.categoryId)}",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),

              if (task.timeNeeded != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${task.timeNeeded} hr"),
                  ],
                ),
              ],

              if (task.motivation != null &&
                  task.motivation!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  "Why: ${task.motivation}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 6),

              // Completed date
              if (task.completedAt != null)
                Text(
                  "Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
