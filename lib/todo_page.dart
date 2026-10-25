import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todo_provider.dart';

/// Hlavná stránka aplikácie so zoznamom úloh (To-Do list)
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Kontrolér na prístup k hodnote z TextFieldu
  final _controller = TextEditingController();

  /// Funkcia, ktorá sa zavolá pri kliknutí na "SAVE"
  /// – pridá novú úlohu do zoznamu
  void _addTodo() {
    // Kontrola prázdneho poľa
    if (_controller.text.isEmpty) {
      showMsg(context, 'Input field must not be empty');
      return;
    }

    Provider.of<TodoProvider>(context, listen: false).addTodo(_controller.text);
    _controller.clear();

    // Zatvorenie spodného okna (BottomSheet)
    Navigator.pop(context);
  }

  /// Hlavné rozloženie obrazovky
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Umiestnenie tlačidla v strede dole
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Tlačidlo na pridanie úlohy
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoSheet();
        },
        child: const Icon(Icons.add),
      ),

      // Horný AppBar s názvom
      appBar: AppBar(title: const Text('My Todos')),

      // Obsah obrazovky – buď text, alebo zoznam úloh
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return provider.todos.isEmpty
              ? const Center(child: Text('Nothing to do!'))
              : ListView.builder(
                  itemCount: provider.todos.length,
                  itemBuilder: (context, index) {
                    final todo = provider.todos[index];
                    return TodoItem(
                      todo: todo,
                      onChanged: (value) =>
                          provider.toggleTodoStatus(index, value),
                      onDelete: () => provider.removeTodo(index),
                    );
                  },
                );
        },
      ),
    );
  }

  /// Zobrazí spodné okno (BottomSheet) na pridanie novej úlohy
  void _showAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Textové pole pre názov úlohy
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'What to do?'),
            ),

            // Nadpis "Select Priority"
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Select Priority'),
            ),

            // Tri rádiové tlačidlá – výber priority
            Consumer<TodoProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<TodoPriority>(
                      value: TodoPriority.Low,
                      groupValue: provider.priority,
                      onChanged: (value) {
                        provider.setPriority(value!);
                      },
                    ),
                    const Text('Low'),

                    Radio<TodoPriority>(
                      value: TodoPriority.Normal,
                      groupValue: provider.priority,
                      onChanged: (value) {
                        provider.setPriority(value!);
                      },
                    ),
                    const Text('Normal'),

                    Radio<TodoPriority>(
                      value: TodoPriority.High,
                      groupValue: provider.priority,
                      onChanged: (value) {
                        provider.setPriority(value!);
                      },
                    ),
                    const Text('High'),
                  ],
                );
              },
            ),

            // Tlačidlo na uloženie úlohy
            ElevatedButton(onPressed: _addTodo, child: const Text('SAVE')),
          ],
        ),
      ),
    );
  }
}

/// Pomocná funkcia – zobrazí dialógové okno s chybovou hláškou
void showMsg(BuildContext context, String s) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Caution!'),
      content: Text(s),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    ),
  );
}

/// Widget pre jednotlivú úlohu – riadok so zaškrtávacím políčkom
class TodoItem extends StatelessWidget {
  final MyTodo todo;
  final Function(bool) onChanged;
  final void Function() onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(todo.name),
      subtitle: Text('Priority: ${todo.priority.name}'),
      value: todo.completed,
      secondary: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete),
      ),
      onChanged: (value) {
        onChanged(value!);
      },
    );
  }
}

/// Model (dátová trieda) pre jednu úlohu
class MyTodo {
  int id; // unikátne ID úlohy
  String name; // názov úlohy
  bool completed; // či je úloha dokončená
  TodoPriority priority; // priorita úlohy

  MyTodo({
    required this.id,
    required this.name,
    this.completed = false,
    required this.priority,
  });
}

/// Enum (výčtový typ) – definovanie troch úrovní priority
enum TodoPriority { Low, Normal, High }
