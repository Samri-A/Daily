class Task{
  int? id;
  String taskName;
  int priority;
  bool habit;
  bool isCompleted;

  Task(this.id , this.taskName , this.priority , this.habit , {this.isCompleted = false});

  void completeTask(){
    isCompleted = true;
  }


  Map<String , dynamic> toMap(){
    return {
      "id" : id,
      "taskName" : taskName,
      "priority" : priority,
      "habit" : habit ? 1 : 0 ,
      "completed" : isCompleted ? 1 : 0,
    };
  }

  static Task fromMap(Map< String , dynamic> map){
    final dynamic priorityValue = map["priority"];
    return Task(
      map["id"],
      map["taskName"] ?? map["taskname"] ?? "",
      priorityValue is int
          ? priorityValue
          : priorityValue == "high"
              ? 3
              : priorityValue == "medium"
                  ? 2
                  : priorityValue == "low"
                      ? 1
                      : int.tryParse("${priorityValue ?? 1}") ?? 1,
      map["habit"] == 1,
      isCompleted: map["completed"] == 1 || map["isCompleted"] == 1,
    );
  }

}