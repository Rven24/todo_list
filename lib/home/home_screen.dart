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
  final TextEditingController _textController = TextEditingController();

  Future<void> _addTask() async {
    final TextEditingController addController = TextEditingController();

    final String? newTask = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
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
              if (value.isNotEmpty) {
                Navigator.of(context).pop(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (addController.text.isNotEmpty) {
                  Navigator.of(context).pop(addController.text);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    // Cleanup controller
    addController.dispose();

    // Tambahkan task jika ada input
    if (newTask != null && newTask.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: newTask));
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  // Method BARU: Konfirmasi sebelum delete
  Future<void> _deleteTask(int index) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Hapus task "${_tasks[index].title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Jika user klik "Hapus"
    if (confirmed == true) {
      setState(() {
        _tasks.removeAt(index);
      });
    }
  }

  // Method BARU: Edit task
  Future<void> _editTask(int index) async {
    final TextEditingController editController = TextEditingController(
      text: _tasks[index].title,
    );

    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Masukkan task baru...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.of(context).pop(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  Navigator.of(context).pop(editController.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    // Cleanup controller
    editController.dispose();

    // Update task jika ada perubahan
    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _tasks[index].title = newTitle;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
      // BARU: FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Tambah Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
