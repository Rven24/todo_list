import 'package:flutter/material.dart';

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Task> _tasks = [];

  // Logic to dispose controllers after the frame is done
  void _safeDispose(TextEditingController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
  }

  Future<void> _addTask() async {
    final TextEditingController addController = TextEditingController();

    final String? newTask = await showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevents accidental taps causing state issues
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Task Baru'),
          content: TextField(
            controller: addController,
            decoration: const InputDecoration(
              hintText: 'Masukkan task...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) Navigator.of(dialogContext).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (addController.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop(addController.text);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    _safeDispose(addController);

    if (newTask != null && newTask.isNotEmpty && mounted) {
      setState(() {
        _tasks.add(Task(title: newTask));
      });
    }
  }

  Future<void> _editTask(int index) async {
    final TextEditingController editController =
        TextEditingController(text: _tasks[index].title);

    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Masukkan task baru...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop(editController.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    _safeDispose(editController);

    if (newTitle != null && newTitle.isNotEmpty && mounted) {
      setState(() {
        _tasks[index].title = newTitle;
      });
    }
  }

  Future<void> _deleteTask(int index) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Hapus task "${_tasks[index].title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _tasks.removeAt(index);
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List'), elevation: 2),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'Belum ada task.\nTekan tombol + untuk menambah task!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  // ObjectKey uses the actual Task object to identify the row
                  key: ObjectKey(task), 
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => _toggleTask(index),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTask(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Tambah Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}