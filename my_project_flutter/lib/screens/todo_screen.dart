import 'package:flutter/material.dart';
import 'package:my_project_client/my_project_client.dart';

import '../main.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    try {
      final todos = await client.todos.getAllTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading todos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTodo() async {
    if (_textController.text.isEmpty) return;

    final todo = Todo(
      text: _textController.text,
      completed: false,
    );

    try {
      await client.todos.createTodo(todo);
      _textController.clear();
      _loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    todo.completed = !todo.completed;
    try {
      await client.todos.updateTodo(todo);
      _loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> _deleteTodo(int id) async {
    try {
      await client.todos.deleteTodo(id);
      _loadTodos();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                    onPressed: _addTodo,
                  ),
                ),
                onSubmitted: (_) => _addTodo(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: todo.completed
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (_) => _toggleTodo(todo),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: Colors.green,
                            ),
                            title: Text(
                              todo.text,
                              style: TextStyle(
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.completed
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteTodo(todo.id!),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
