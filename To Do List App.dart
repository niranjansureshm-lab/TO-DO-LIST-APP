import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

// ================= APP =================

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
      ),
      home: const TodoHomePage(),
    );
  }
}

// ================= TASK MODEL =================

class TodoTask {
  final int id;
  final String title;
  bool isCompleted;

  TodoTask({required this.id, required this.title, this.isCompleted = false});
}

// ================= HOME PAGE =================

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController taskController = TextEditingController();

  final List<TodoTask> tasks = [];

  int nextId = 0;

  TodoTask? deletedTask;
  int? deletedIndex;

  // ================= TASK COUNTERS =================

  int getCompletedTasks() {
    return tasks.where((task) => task.isCompleted).length;
  }

  int getRemainingTasks() {
    return tasks.where((task) => !task.isCompleted).length;
  }

  int getTotalTasks() {
    return tasks.length;
  }

  // ================= ADD TASK =================

  void addTask() {
    String title = taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      tasks.add(TodoTask(id: nextId++, title: title));

      taskController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  // ================= TOGGLE TASK =================

  void toggleTask(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  // ================= DELETE TASK =================

  void deleteTask(TodoTask task, int index) {
    setState(() {
      deletedTask = task;
      deletedIndex = index;

      tasks.remove(task);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${task.title}" deleted'),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFF60A5FA),
          onPressed: undoDelete,
        ),
      ),
    );
  }

  // ================= UNDO DELETE =================

  void undoDelete() {
    if (deletedTask == null) return;

    setState(() {
      int index = deletedIndex ?? tasks.length;

      if (index > tasks.length) {
        index = tasks.length;
      }

      tasks.insert(index, deletedTask!);

      deletedTask = null;
      deletedIndex = null;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER

                  buildHeader(),

                  const SizedBox(height: 25),

                  // STATISTICS
                  buildStatistics(),

                  const SizedBox(height: 25),

                  // ADD TASK SECTION
                  buildAddTask(),

                  const SizedBox(height: 25),

                  // TASK LIST HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        '${getRemainingTasks()} remaining',
                        style: const TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // TASK LIST
                  Expanded(
                    child: tasks.isEmpty
                        ? buildEmptyState()
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];

                              return buildTaskCard(task, index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= HEADER =================

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 30,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 15),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My To-Do List',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 5),

              Text(
                'Organize your day, achieve your goals.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),

        const Icon(Icons.notifications_none, color: Colors.white70, size: 27),
      ],
    );
  }

  // ================= STATISTICS =================

  Widget buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            'Total Tasks',
            getTotalTasks().toString(),
            Icons.assignment_outlined,
            const Color(0xFF3B82F6),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: buildStatCard(
            'Completed',
            getCompletedTasks().toString(),
            Icons.check_circle_outline,
            const Color(0xFF22C55E),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: buildStatCard(
            'Remaining',
            getRemainingTasks().toString(),
            Icons.pending_actions,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF17233D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ================= ADD TASK =================

  Widget buildAddTask() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17233D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: taskController,
            onSubmitted: (_) => addTask(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF60A5FA)),
              filled: true,
              fillColor: const Color(0xFF0B1120),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TASK CARD =================

  Widget buildTaskCard(TodoTask task, int index) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),

      onDismissed: (_) {
        deleteTask(task, index);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? const Color(0xFF102D2B)
              : const Color(0xFF17233D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.25)
                : Colors.white.withOpacity(0.06),
          ),
        ),

        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              activeColor: const Color(0xFF22C55E),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (_) {
                toggleTask(index);
              },
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted ? Colors.white54 : Colors.white,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    task.isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      color: task.isCompleted
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: task.isCompleted ? Colors.greenAccent : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF17233D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 55,
              color: Color(0xFF60A5FA),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No Tasks Yet!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Add your first task and start organizing your day.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),

          const SizedBox(height: 15),

          const Text(
            'Tap + to get started',
            style: TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }
}
