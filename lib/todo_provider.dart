import 'package:flutter/foundation.dart';
import 'todo_page.dart';

class TodoProvider extends ChangeNotifier {
  final List<MyTodo> _todos = [];
  TodoPriority _priority = TodoPriority.Normal;

  List<MyTodo> get todos => _todos;
  TodoPriority get priority => _priority;

  void addTodo(String name) {
    _todos.add(
      MyTodo(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        priority: _priority,
      ),
    );
    notifyListeners();
  }

  void toggleTodoStatus(int index, bool value) {
    _todos[index].completed = value;
    notifyListeners();
  }

  void setPriority(TodoPriority value) {
    _priority = value;
    notifyListeners();
  }
}
