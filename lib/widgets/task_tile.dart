import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  Function? onTap;

   TaskTile({super.key, required this.task,this.onTap});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isMine = task.isForMe;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal, // swipe left/right
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 👉 Swipe right = Edit
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTaskScreen(task: task),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // 👈 Swipe left = Delete
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Delete Task"),
              content: const Text("Are you sure you want to delete this task?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(ctx, false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete",style: TextStyle(color: Colors.white),),
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            ),
          );
          if (confirm == true) {
            taskProvider.deleteTask(task.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task deleted")),
            );
            return true;
          }
          return false;
        }
        return false;
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: (isMine ? Colors.indigo : Colors.grey).withOpacity(0.4),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Title + Ownership Badge ----
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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

              const SizedBox(height: 10),

              // ---- Action Button (Move / Return / Complete) ----
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.status == "focus"
                        ? Colors.orange
                        : Colors.green,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    task.status == "focus"
                        ? Icons.undo
                        : Icons.arrow_circle_up,
                    size: 16,color: Colors.white,
                  ),
                  label: Text(
                    task.status == "focus" ? "Return" : "Focus",
                    style: const TextStyle(fontSize: 12,color: Colors.white),
                  ),
                  onPressed: () {
                    if (task.status == "focus") {
                      taskProvider.returnTask(task);
                    } else {
                      task.status = "focus";
                      taskProvider.updateTask(task);
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
