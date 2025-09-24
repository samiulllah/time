import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class IdeaDumpScreen extends StatelessWidget {
  const IdeaDumpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Group tasks by category name
    final grouped = <String, List<Task>>{};
    for (var task in taskProvider.ideaDump) {
      final catName = taskProvider.getCategoryName(task.categoryId);
      grouped.putIfAbsent(catName, () => []);
      grouped[catName]!.add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Idea Dump"),
        actions: [
          IconButton(
              onPressed: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                  );
              }, icon: const Icon(Icons.add_task,size: 30,)),
          SizedBox(width: 20,)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await taskProvider.loadTasks();
        },
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            // ----- Today's Focus -----
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Focus",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (taskProvider.focus.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text("Drag or tap tasks to add here"),
                    ),
                  ...taskProvider.focus.map(
                        (t) => TaskTile(
                      task: t,
                      onTap: () {
                        // returning to idea dump
                        taskProvider.returnTask(t);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ----- Grouped Categories -----
            ...grouped.entries.map((entry) {
              final catName = entry.key;
              final tasks = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // remove inner divider
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            catName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${tasks.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: tasks
                        .map((t) => TaskTile(
                      task: t,
                      onTap: () {
                        // move to focus when tapped
                        t.status = "focus";
                        taskProvider.updateTask(t);
                      },
                    ))
                        .toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),

    );
  }
}
