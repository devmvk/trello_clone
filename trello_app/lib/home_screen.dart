import 'package:flutter/material.dart';
import 'package:trello_app/task_card_container.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trello Clone"),
      ),
      body: Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(3, (index)=>TaskCardContainer())
        ),
      ),
    );
  }
}