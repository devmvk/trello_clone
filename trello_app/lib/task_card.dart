import 'package:flutter/material.dart';
import 'package:trello_app/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;

  TaskCard(this.task);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        color: Colors.yellow,
        height: 150.0,
        key: Key(widget.task.id.toString()),
        child: Center(
          child: Text(widget.task.title),
        ),
      );
  }

}