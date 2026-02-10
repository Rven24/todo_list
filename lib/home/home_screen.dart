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

  // Logic to dispose controllers safely
  void _safeDispose(TextEditingController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
  }

  // UI Helper: Modern Input Decoration
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _addTask() async {
    final TextEditingController addController = TextEditingController();
    final String? newTask = await showDialog<String>(
      context: context,
      builder: (context) => _buildTaskDialog(
        title: 'New Task',
        controller: addController,
        confirmLabel: 'Add',
      ),
    );

    _safeDispose(addController);
    if (newTask != null && newTask.isNotEmpty && mounted) {
      setState(() => _tasks.add(Task(title: newTask)));
    }
  }

  Future<void> _editTask(int index) async {
    final TextEditingController editController = TextEditingController(text: _tasks[index].title);
    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) => _buildTaskDialog(
        title: 'Edit Task',
        controller: editController,
        confirmLabel: 'Save',
      ),
    );

    _safeDispose(editController);
    if (newTitle != null && newTitle.isNotEmpty && mounted) {
      setState(() => _tasks[index].title = newTitle);
    }
  }

  // Minimalist Dialog Builder
  Widget _buildTaskDialog({
    required String title,
    required TextEditingController controller,
    required String confirmLabel,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: _inputStyle('Enter task description...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }

  Future<void> _deleteTask(int index) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Delete Task?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _tasks.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('All clear for now!', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.grey[50] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: GestureDetector(
                      onTap: () => setState(() => task.isCompleted = !task.isCompleted),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: task.isCompleted ? Colors.black : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted ? Colors.black : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: task.isCompleted ? Colors.white : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') _editTask(index);
                        if (val == 'delete') _deleteTask(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: Colors.black,
        elevation: 4,
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}