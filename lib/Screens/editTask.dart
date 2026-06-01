import 'package:flutter/material.dart';
import '../model/data.dart';

class EditTask extends StatefulWidget {
  final Task task;
  const EditTask({super.key, required this.task});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late String daily;
  late int priority;
  late String taskName;
  Color save_button = Color.fromARGB(255, 13, 13, 17);

  initState() {
    super.initState();
    daily = widget.task.habit ? "Daily" : "Once";
    priority = widget.task.priority;
    taskName = widget.task.taskName;
    save_button = taskName.trim().isEmpty
        ? const Color(0xFF717182)
        : const Color.fromARGB(255, 10, 10, 11);
  }

  final TextEditingController taskController = TextEditingController();

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Task"),
                          content: const Text(
                            "Are you sure you want to delete this task?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        Navigator.pop(context, "delete");
                      }
                    },
                    icon: const Icon(Icons.delete_outline_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: "Task Name",
                child: Text(
                  taskName,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: "Repetition",
                child: Column(
                  children: [
                    _OptionTile(
                      title: "Daily",
                      subtitle: "Repeats every day",
                      selected: daily == "Daily",
                      onTap: () => setState(() => daily = "Daily"),
                    ),
                    const SizedBox(height: 10),
                    _OptionTile(
                      title: "Once",
                      subtitle: "One-time task",
                      selected: daily == "Once",
                      onTap: () => setState(() => daily = "Once"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: "Priority",
                child: Column(
                  children: [
                    _OptionTile(
                      title: "Low",
                      selected: priority == 1,
                      onTap: () => setState(() => priority = 1),
                    ),
                    const SizedBox(height: 10),
                    _OptionTile(
                      title: "Medium",
                      selected: priority == 2,
                      onTap: () => setState(() => priority = 2),
                    ),
                    const SizedBox(height: 10),
                    _OptionTile(
                      title: "High",
                      selected: priority == 3,
                      onTap: () => setState(() => priority = 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (taskController.text.trim().isEmpty) {
                      return;
                    }
                    final updatedTask = Task(
                      widget.task.id,
                      taskController.text.trim(),
                      priority,
                      daily == "Daily",
                      isCompleted: widget.task.isCompleted,
                    );
                    Navigator.pop(context, updatedTask);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: save_button,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Task",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1A000000), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1A000000), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBEBEC7), width: 1),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
