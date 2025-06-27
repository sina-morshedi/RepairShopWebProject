import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarProblemReportRequestDTO.dart';

class CarRepairLogResponseDTO {
  final String? id;
  final CarInfoDTO car;
  final UserProfile creatorUser;
  final String? description;
  final TaskStatusDTO taskStatus;
  final DateTime dateTime;
  final CarProblemReportRequestDTO? problemReport;

  CarRepairLogResponseDTO({
    this.id,
    required this.car,
    required this.creatorUser,
    this.description,
    required this.taskStatus,
    required this.dateTime,
    this.problemReport,
  });

  factory CarRepairLogResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogResponseDTO(
      id: json['_id'] ?? json['id'],
      car: CarInfoDTO.fromJson(json['car']),
      creatorUser: UserProfile.fromJson(json['creatorUser']),
      description: json['description'],
      taskStatus: TaskStatusDTO.fromJson(json['taskStatus']),
      dateTime: DateTime.parse(json['dateTime']),
      problemReport: json['problemReport'] != null
          ? CarProblemReportRequestDTO.fromJson(json['problemReport'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'car': car.toJson(),
      'creatorUser': creatorUser.toJson(),
      if (description != null) 'description': description,
      'taskStatus': taskStatus.toJson(),
      'dateTime': dateTime.toIso8601String(),
      if (problemReport != null) 'problemReport': problemReport!.toJson(),
    };
  }
}

