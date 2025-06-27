import 'package:repair_shop_web/app/features/dashboard/models/CarInfoDTO.dart';
import 'package:repair_shop_web/app/features/dashboard/models/UserProfileDTO.dart';
class CarProblemReportResponseDTO {
  String? id;
  CarInfoDTO? carInfo;
  UserProfile? creatorUser;
  String problemSummary;
  DateTime dateTime;

  CarProblemReportResponseDTO({
    this.id,
    this.carInfo,
    this.creatorUser,
    required this.problemSummary,
    required this.dateTime,
  });

  factory CarProblemReportResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarProblemReportResponseDTO(
      id: json['id'] as String?,
      carInfo: json['carInfo'] != null
          ? CarInfoDTO.fromJson(json['carInfo'])
          : null,
      creatorUser: json['creatorUser'] != null
          ? UserProfile.fromJson(json['creatorUser'])
          : null,
      problemSummary: json['problemSummary'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (carInfo != null) 'carInfo': carInfo!.toJson(),
      if (creatorUser != null) 'creatorUser': creatorUser!.toJson(),
      'problemSummary': problemSummary,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
