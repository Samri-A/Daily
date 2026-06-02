import 'package:flutter/material.dart';
import '../model/data.dart';
import '../service/task_db.dart';
import "../Screens/editTask.dart";

class TaskCard extends StatefulWidget {
  final Task task;
  final Future<void> Function(Task task) onCompletedChanged;
  final Future<void> Function()? onTaskChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCompletedChanged,
    this.onTaskChanged,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String _priorityLabel(int priority) {
    if (priority == 3) return "high";
    if (priority == 2) return "medium";
    return "low";
  }

  Color _titleColor(bool isCompleted) {
    return isCompleted ? const Color(0xFF717182) : const Color(0xFF0A0A0A);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.isCompleted;
    final priorityLabel = _priorityLabel(widget.task.priority);
    final habitLabel = widget.task.habit ? "Daily" : "Once";
    return GestureDetector(
      onDoubleTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditTask(task: widget.task)),
        );

        if (result is Task) {
          await TaskDatabase.instance.update(result);
          await widget.onTaskChanged?.call();
        } else if (result == "delete") {
          await TaskDatabase.instance.delete(widget.task.id!);
          await widget.onTaskChanged?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0x80ECECF0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A000000), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    widget.task.isCompleted = !widget.task.isCompleted;
                  });
                  await widget.onCompletedChanged(widget.task);
                },
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF030213)
                        : const Color(0xFFF3F3F5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF030213)
                          : const Color(0x1A000000),
                      width: 1,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.taskName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _titleColor(isCompleted),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEF2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0x1A000000),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          priorityLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEF2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          habitLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF030213),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
