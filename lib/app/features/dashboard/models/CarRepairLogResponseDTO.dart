import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarProblemReportResponseDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/CarProblemReportRequestDTO.dart';

class CarRepairLogResponseDTO {
  final String? id;
  final CarInfoDTO carInfo;
  final UserProfile creatorUser;
  final String? description;
  final TaskStatusDTO taskStatus;
  final DateTime dateTime;
  final CarProblemReportResponseDTO? problemReport;

  CarRepairLogResponseDTO({
    this.id,
    required this.carInfo,
    required this.creatorUser,
    this.description,
    required this.taskStatus,
    required this.dateTime,
    this.problemReport,
  });

  factory CarRepairLogResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarRepairLogResponseDTO(
      id: json['_id'] ?? json['id'],
      carInfo: CarInfoDTO.fromJson(json['carInfo']),
      creatorUser: UserProfile.fromJson(json['creatorUser']),
      description: json['description'],
      taskStatus: TaskStatusDTO.fromJson(json['taskStatus']),
      dateTime: DateTime.parse(json['dateTime']),
      problemReport: json['problemReport'] != null
          ? CarProblemReportResponseDTO.fromJson(json['problemReport'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'carInfo': carInfo.toJson(),
      'creatorUser': creatorUser.toJson(),
      if (description != null) 'description': description,
      'taskStatus': taskStatus.toJson(),
      'dateTime': dateTime.toIso8601String(),
      if (problemReport != null) 'problemReport': problemReport!.toJson(),
    };
  }

  @override
  String toString() {
    return 'CarRepairLogResponseDTO('
        'id: $id, '
        'carInfo: $carInfo, '
        'creatorUser: $creatorUser, '
        'description: $description, '
        'taskStatus: $taskStatus, '
        'dateTime: $dateTime, '
        'problemReport: $problemReport'
        ')';
  }

}

