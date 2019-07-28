import 'package:flutter/material.dart';
import 'package:trello_app/data.dart';
import 'package:trello_app/task_model.dart';

final List<TaskModel> todoTasks = DATA_TODO.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();
final List<TaskModel> inProgressTasks = DATA_IN_PROGRESS.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();
final List<TaskModel> doneTasks = DATA_DONE.map<TaskModel>((data)=>TaskModel(id: data["id"], title: data["title"])).toList();


GlobalKey listViewKey = GlobalKey(debugLabel: "TaskCardContainersKey");
ScrollController taskCardContainerController = ScrollController();
BuildContext taskContainerContext; 