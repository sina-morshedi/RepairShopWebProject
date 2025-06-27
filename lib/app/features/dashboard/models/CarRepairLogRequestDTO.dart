class CarRepairLogRequestDTO {
  final String carId;
  final String creatorUserId;
  final String? description;
  final String taskStatusId;
  final DateTime dateTime;
  final String? problemReportId;

  CarRepairLogRequestDTO({
    required this.carId,
    required this.creatorUserId,
    this.description,
    required this.taskStatusId,
    required this.dateTime,
    this.problemReportId,
  });

  factory CarRepairLogRequestDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogRequestDTO(
      carId: json['carId'],
      creatorUserId: json['creatorUserId'],
      description: json['description'],
      taskStatusId: json['taskStatusId'],
      dateTime: DateTime.parse(json['dateTime']),
      problemReportId: json['problemReportId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'creatorUserId': creatorUserId,
      if (description != null) 'description': description,
      'taskStatusId': taskStatusId,
      'dateTime': dateTime.toIso8601String(),
      if (problemReportId != null) 'problemReportId': problemReportId,
    };
  }
}
