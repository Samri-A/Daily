import 'package:flutter/material.dart';
import 'package:myhabit/Components/task.dart';
import 'package:myhabit/model/data.dart';
import 'package:myhabit/service/task_db.dart';
import 'package:myhabit/service/widget_updater.dart';
import 'addTask.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> tasks = [];
  bool isLoading = true;

  String _formatDate(DateTime date) {
    const weekdays = [
      "Monday", "Tuesday", "Wednesday", "Thursday",
      "Friday", "Saturday", "Sunday",
    ];
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December",
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return "$weekday, $month ${date.day}";
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await TaskDatabase.instance.readAllTasks();
    if (!mounted) return;
    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  Future<void> _addTask(Task task) async {
    await TaskDatabase.instance.create(task);
    await _loadTasks();
    await WidgetUpdater.refresh();
  }

  Future<void> _updateTask(Task task) async {
    await TaskDatabase.instance.update(task);
    await WidgetUpdater.refresh();
  }

  Future<void> _onTaskChanged() async {
    await _loadTasks();
    await WidgetUpdater.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final todayText = _formatDate(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todayText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF717182),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: tasks
                          .map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TaskCard(
                                task: task,
                                onCompletedChanged: _updateTask,
                                onTaskChanged: _onTaskChanged,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addtask()),
          );
          if (result != null && result is Task) {
            await _addTask(result);
          }
        },
        backgroundColor: const Color(0xFF030213),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
