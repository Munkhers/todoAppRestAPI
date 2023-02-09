import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  var items = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    var response =
        await Dio().get('http://api.nstack.in/v1/todos?page=1&limit=10');
    if (response.statusCode == 200) {
      setState(() {
        items = response.data['items'];
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo list'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: ((context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      navigateToEditPage(item);
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              );
            }),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAdd,
        label: const Text('Add Todo'),
      ),
    );
  }

  Future<void> navigateToAdd() async {
    final route = MaterialPageRoute(
      builder: ((context) => const AddTodoPage()),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  void navigateToEditPage(Map item) {
    final route = MaterialPageRoute(
      builder: ((context) => AddTodoPage(todo: item)),
    );
    Navigator.push(context, route);
  }

  Future<void> deleteById(String id) async {
    final response = await Dio().delete('https://api.nstack.in/v1/todos/$id');
    if (response.statusCode == 200) {
      setState(() {
        items = items.where((element) => element['_id'] != id).toList();
      });
      showDeleteMessage('Todo deleted');
    }
  }

  void showDeleteMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
