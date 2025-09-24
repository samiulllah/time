import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Focus"),
      ),
      body: taskProvider.focus.isEmpty
          ? const Center(child: Text("No tasks in focus yet."))
          : ListView.builder(
        itemCount: taskProvider.focus.length,
        itemBuilder: (context, index) {
          final task = taskProvider.focus[index];
          return FocusTaskTile(task: task);
        },
      ),
    );
  }
}

class FocusTaskTile extends StatelessWidget {
  final Task task;

  const FocusTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isMine = task.isForMe;

    return Card(
      elevation: 4,
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
            // ---- Title + Me/Other ----
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text("Category: ${taskProvider.getCategoryName(task.categoryId)}",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),

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

            const SizedBox(height: 12),

            // ---- Action Buttons Row ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(0, 40)),
                    icon: const Icon(Icons.block, size: 18, color: Colors.white),
                    label: const Text("Blocked",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => taskProvider.blockTask(task),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(0, 40)),
                    icon: const Icon(Icons.undo, size: 18, color: Colors.white),
                    label: const Text("Return",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => taskProvider.returnTask(task),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 40)),
                    icon: const Icon(Icons.check, size: 16, color: Colors.white),
                    label: const Text("Complete",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => taskProvider.completeTask(task),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
