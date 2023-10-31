import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo-List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  // int _count = 0;  INI DIHAPUS!!!

  void refreshItemList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      _todos = todos;
      _titleController.clear(); // tambahan
      _descController.clear(); // tambahan
    });
  }

  void searchItems() async {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      final todos = await dbHelper.getTodoByTitle(keyword);
      setState(() {
        _todos = todos;
      });
    } else {
      refreshItemList();
    }
  }

  void addItem(String title, String desc) async {
    final todo =
        Todo(title: title, description: desc, completed: false); // ID dihapus
    await dbHelper.insertTodo(todo);
    refreshItemList();
  }

  void updateItem(Todo todo, bool completed) async {
    final item = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: completed,
    );
    await dbHelper.updateTodo(item);
    refreshItemList();
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshItemList();
  }

  void showValueEdit(Todo todo) {
    _titleController.text = todo.title;
    _descController.text = todo.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                var todo = _todos[index];
                return ListTile(
                  leading: todo.completed
                      ? IconButton(
                          onPressed: () {
                            updateItem(todo, !todo.completed);
                          },
                          icon: const Icon(Icons.check_circle),
                        )
                      : IconButton(
                          onPressed: () {
                            updateItem(todo, !todo.completed);
                          },
                          icon: const Icon(Icons.radio_button_unchecked),
                        ),
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteItem(todo.id!); //tambahi tanda !!!!! (NULL SAFETY)
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tambah Todo'),
              content: SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Judul todo'),
                    ),
                    TextField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(hintText: 'Deskripsi todo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batalkan'),
                ),
                TextButton(
                  onPressed: () {
                    addItem(_titleController.text, _descController.text);
                    Navigator.pop(context);
                    // tak perlu pake set State
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
          );
          refreshItemList(); // tambahan
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
