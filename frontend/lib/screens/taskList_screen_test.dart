import 'package:flutter/material.dart';
import '../providers/task_service_test.dart';
import '../models/task_model_test.dart';

class TaskListScreenTest extends StatefulWidget {
  final String userId;
  TaskListScreenTest({required this.userId});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreenTest> {
  late Future<List<Task>> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = TaskService().fetchTasks(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task List")),
      body: FutureBuilder<List<Task>>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          List<Task> tasks = snapshot.data!;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.status),
                trailing: task.status == "Pending"
                    ? TextButton(
                  onPressed: () async {
                    try {
                      await TaskService().verifyTask(task.id, "1234");
                      setState(() {
                        _taskFuture = TaskService().fetchTasks(widget.userId);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task Verified!")));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Failed")));
                    }
                  },
                  child: Text("Verify", style: TextStyle(color: Colors.blue)),
                )
                    : Icon(Icons.check_circle, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}
