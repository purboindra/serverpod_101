import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class TodosEndpoint extends Endpoint {
  Future<List<Todo>> getAllTodos(Session session) async {
    return await Todo.db.find(
      session,
      orderBy: (t) => t.id,
    );
  }

  Future<Todo?> getTodoById(Session session, int id) async {
    final response = await Todo.db.findById(session, id);
    return response;
  }

  Future<Todo> createTodo(Session session, Todo todo) async {
    return await Todo.db.insertRow(session, todo);
  }

  Future<Todo> updateTodo(Session session, Todo todo) async {
    return await Todo.db.updateRow(session, todo);
  }

  Future<void> deleteTodo(Session session, int id) async {
    await Todo.db.deleteWhere(session, where: (t) => t.id.equals(id));
  }
}
