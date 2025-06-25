class TaskStatusDTO {
  final String? id;
  final String taskStatusName;

  TaskStatusDTO({
    this.id,
    required this.taskStatusName,
  });

  factory TaskStatusDTO.fromJson(Map<String, dynamic> json) {
    return TaskStatusDTO(
      id: json['id'],
      taskStatusName: json['taskStatusName'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'taskStatusName': taskStatusName,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'id: $id, taskStatusName: $taskStatusName';
  }
}
