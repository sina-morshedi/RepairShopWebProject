import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/models/profile.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';
import 'package:repair_shop_web/app/features/dashboard/models/TaskStatusCountDTO.dart';


class DashboardController extends GetxController {

  final RxInt selectedIndex = 0.obs;

  final RxList<TaskStatusCountDTO> taskStatusCounts = <TaskStatusCountDTO>[].obs;

  Future<void> initTaskStatusCounts(BuildContext context) async {
    try {
      final result = await CarRepairLogApi().getTaskStatusCount();
      if(result.status == 'success')
        taskStatusCounts.assignAll(result.data!);
      else
        StringHelper.showErrorDialog(context, result.message!);
    } catch (e) {
      StringHelper.showErrorDialog(context,'Error fetching task status counts: $e');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  // Data
  Profile? getProfil() {
    final user = Get.find<UserController>().user.value;

    if (user == null) return null;

    return Profile(
      photo: const AssetImage(ImageRasterPath.avatar1),
      first_name: user.firstName,
      last_name: user.lastName,
      role_name: user.role.roleName,
    );
  }


  List<TaskCardData> getAllTask() {
    return [
      const TaskCardData(
        title: "Landing page UI Design",
        dueDay: 2,
        totalComments: 50,
        type: TaskType.todo,
        totalContributors: 30,
        profilContributors: [
          AssetImage(ImageRasterPath.avatar1),
          AssetImage(ImageRasterPath.avatar2),
          AssetImage(ImageRasterPath.avatar3),
          AssetImage(ImageRasterPath.avatar4),
        ],
      ),
      const TaskCardData(
        title: "Landing page UI Design",
        dueDay: -1,
        totalComments: 50,
        totalContributors: 34,
        type: TaskType.inProgress,
        profilContributors: [
          AssetImage(ImageRasterPath.avatar5),
          AssetImage(ImageRasterPath.avatar6),
          AssetImage(ImageRasterPath.avatar7),
          AssetImage(ImageRasterPath.avatar8),
        ],
      ),
      const TaskCardData(
        title: "Landing page UI Design",
        dueDay: 1,
        totalComments: 50,
        totalContributors: 34,
        type: TaskType.done,
        profilContributors: [
          AssetImage(ImageRasterPath.avatar5),
          AssetImage(ImageRasterPath.avatar3),
          AssetImage(ImageRasterPath.avatar4),
          AssetImage(ImageRasterPath.avatar2),
        ],
      ),
    ];
  }

  ProjectCardData getSelectedProject() {
    return selectedProject.value;
  }


  final Rx<ProjectCardData> selectedProject = Rx<ProjectCardData>(
    ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logo1),
      projectName: "Nano Electronics Bolu",
      releaseTime: DateTime.now(),
    ),
  );


  List<ProjectCardData> getActiveProject() {
    return [
      ProjectCardData(
        percent: .3,
        projectImage: const AssetImage(ImageRasterPath.logo2),
        projectName: "Taxi Online",
        releaseTime: DateTime.now().add(const Duration(days: 130)),
      ),
      ProjectCardData(
        percent: .5,
        projectImage: const AssetImage(ImageRasterPath.logo3),
        projectName: "E-Movies Mobile",
        releaseTime: DateTime.now().add(const Duration(days: 140)),
      ),
      ProjectCardData(
        percent: .8,
        projectImage: const AssetImage(ImageRasterPath.logo4),
        projectName: "Video Converter App",
        releaseTime: DateTime.now().add(const Duration(days: 100)),
      ),
    ];
  }


  List<ImageProvider> getMember() {
    //TODO Have to modify
    return const [
      AssetImage(ImageRasterPath.avatar1),
      AssetImage(ImageRasterPath.avatar2),
      AssetImage(ImageRasterPath.avatar3),
      AssetImage(ImageRasterPath.avatar4),
      AssetImage(ImageRasterPath.avatar5),
      AssetImage(ImageRasterPath.avatar6),
    ];
  }

  List<ChattingCardData> getChatting() {
    return const [
      ChattingCardData(
        image: AssetImage(ImageRasterPath.avatar6),
        isOnline: true,
        name: "Samantha",
        lastMessage: "i added my new tasks",
        isRead: false,
        totalUnread: 100,
      ),
      ChattingCardData(
        image: AssetImage(ImageRasterPath.avatar3),
        isOnline: false,
        name: "John",
        lastMessage: "well done john",
        isRead: true,
        totalUnread: 0,
      ),
      ChattingCardData(
        image: AssetImage(ImageRasterPath.avatar4),
        isOnline: true,
        name: "Alexander Purwoto",
        lastMessage: "we'll have a meeting at 9AM",
        isRead: false,
        totalUnread: 1,
      ),
    ];
  }
}
