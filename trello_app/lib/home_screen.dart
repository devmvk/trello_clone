import 'package:flutter/material.dart';
import 'package:trello_app/task_card_container.dart';
import 'package:trello_app/data.dart';
import 'package:trello_app/task_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<TaskModel> todoTasks = DATA_TODO.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();
  final List<TaskModel> inProgressTasks = DATA_IN_PROGRESS.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();
  final List<TaskModel> doneTasks = DATA_DONE.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();

  void _onReorderToDo(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TaskModel item = todoTasks.removeAt(oldIndex);
      todoTasks.insert(newIndex, item);
    });
  }

  void _onReorderInProgress(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TaskModel item = inProgressTasks.removeAt(oldIndex);
      inProgressTasks.insert(newIndex, item);
    });
  }
  void _onReorderDone(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TaskModel item = doneTasks.removeAt(oldIndex);
      doneTasks.insert(newIndex, item);
    });
  }

  Widget buildTaskCard(TaskModel task){
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        color: Colors.yellow,
        height: 150.0,
        key: Key(task.id.toString()),
        child: Center(
          child: Text(task.title),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Trello Clone"),
      ),
      body: Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
              SizedBox(
                width: width*0.75,
                child: TaskCardContainer(
                  header: Text("To Do"),
                  children: todoTasks.map<Widget>(buildTaskCard).toList(),
                  onReorder: _onReorderToDo
                ),
              ),
              SizedBox(
                width: width*0.75,
                child: TaskCardContainer(
                  header: Text("In Progress"),
                  children: inProgressTasks.map<Widget>(buildTaskCard).toList(),
                  onReorder: _onReorderInProgress
                ),
              ),
              SizedBox(
                width: width*0.75,
                child: TaskCardContainer(
                  header: Text("Done"),
                  children: doneTasks.map<Widget>(buildTaskCard).toList(),
                  onReorder: _onReorderDone
                ),
              ),
            ],
        )
      ),
    );
  }
}