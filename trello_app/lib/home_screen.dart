import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trello_app/task_card_container.dart';
import 'package:trello_app/task_model.dart';
import 'package:trello_app/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin<HomeScreen>{

  // How long an animation to reorder an element in the list takes.
  static const Duration _reorderAnimationDuration = Duration(milliseconds: 200);
  
  void _onReorder(int oldIndex, int newIndex, List<TaskModel> tasks){
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final TaskModel item = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, item);
    });
  }

  Widget buildTaskCard(TaskModel task){
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        height: 150.0,
        key: Key(task.id.toString()),
        child: Center(
          child: Text(task.title),
        ),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(16.0)
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    entranceController = AnimationController(vsync: this, duration: _reorderAnimationDuration);
    ghostController = AnimationController(vsync: this, duration: _reorderAnimationDuration);
    taskCardContainerController = ScrollController();
  }


  Widget _buildCardContainer({String headerText, Color containerColor, List<TaskModel> tasks, double width}){
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(6.0),
            child: SizedBox(
              width: width*0.75,
              child: TaskCardContainer(
                header: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(headerText , style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
                ),
                children: tasks.map<Widget>(buildTaskCard).toList(),
                onReorder: _onReorder,
                tasks: tasks,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: containerColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: ListView(
            key: listViewKey,
            scrollDirection: Axis.horizontal,
            controller: taskCardContainerController,
            children: <Widget>[
              _buildCardContainer(containerColor: Colors.red.shade400, headerText: "To Do", tasks: todoTasks, width: width),
              _buildCardContainer(containerColor: Colors.yellow.shade400, headerText: "In Progress", width: width, tasks: inProgressTasks),
              _buildCardContainer(containerColor: Colors.green.shade400, headerText: "Done" , tasks: doneTasks, width: width),
            ],
          ),
         decoration: BoxDecoration(
           image: DecorationImage(image: NetworkImage("https://www.gstatic.com/webp/gallery/4.webp"), fit: BoxFit.cover)
         ),
        ),
      )
    );
  }

  @override
  void dispose() {
    entranceController.dispose();
    ghostController.dispose();
    super.dispose();
  }
}