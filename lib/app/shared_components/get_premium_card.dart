import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repair_shop_web/app/constans/app_constants.dart';
import '../features/dashboard/models/UserProfileDTO.dart';
import '../features/dashboard/models/users.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/backend_services/ApiEndpoints.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';


class GetPremiumCard extends StatelessWidget {
  GetPremiumCard({
    Key? key,
    this.backgroundColor,
  }) : super(key: key);

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(kBorderRadius),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(kBorderRadius),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => UsersListDialog(),
          );
        },
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      ImageVectorPath.wavyAllMembers,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(15),
                child: _Info(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tüm kullanıcılar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class UsersListDialog extends StatelessWidget {
  const UsersListDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(
          maxHeight: 500,
          minHeight: 200,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tüm kullanıcılar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<ApiResponse<List<UserProfileDTO>>>(
              future: backend_services().fetchAllProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.status != 'success') {
                  return const Center(child: Text('Failed to load users.'));
                } else if (snapshot.data!.data == null || snapshot.data!.data!.isEmpty) {
                  return const Center(child: Text('No users found.'));
                } else {
                  final usersList = snapshot.data!.data!;
                  return ListView.separated(
                    itemCount: usersList.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = usersList[index];
                      return ListTile(
                        leading: const Icon(EvaIcons.person),
                        title: Text(user.username ?? 'No Username'),
                        subtitle: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(EvaIcons.edit2Outline, color: Colors.blue),
                              onPressed: () {
                                // TODO: call edit dialog
                              },
                            ),
                            IconButton(
                              icon: const Icon(EvaIcons.trash2Outline, color: Colors.red),
                              onPressed: () {
                                // TODO: call delete confirm
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


