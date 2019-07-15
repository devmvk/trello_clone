import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final int id;

  TaskCard(this.id);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  
  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        color: Colors.yellow,
        height: 150.0,
      ),
      feedback: Container(
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        color: Colors.yellow.withOpacity(0.5),
        height: 150.0,
      ),
      onDragStarted: (){
        print("drag started");
        ReorderableListView();
      },
    );
  }

}