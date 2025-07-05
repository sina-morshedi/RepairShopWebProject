import 'package:repair_shop_web/app/shared_imports/shared_imports.dart';
import 'package:repair_shop_web/app/features/dashboard/controllers/UserController.dart';

class TeamMemberWidget extends StatefulWidget {
  final VoidCallback onPressedAdd;
  const TeamMemberWidget({required this.onPressedAdd, Key? key}) : super(key: key);

  @override
  _TeamMemberWidgetState createState() => _TeamMemberWidgetState();
}

class _TeamMemberWidgetState extends State<TeamMemberWidget> {
  int totalMember = 0;

  @override
  void initState() {
    super.initState();
    backend_services().countAllMembers().then((count) {
      setState(() {
        totalMember = count;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final permissionName = userController.currentUser?.permission.permissionName ?? "";

    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kFontColorPallets[0],
            ),
            children: [
              const TextSpan(text: "Team Member "),
              TextSpan(
                text: "($totalMember)",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: kFontColorPallets[2],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        permissionName == "Yönetici"
            ? IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddAccountDialog(),
            );
          },
          icon: const Icon(EvaIcons.plus),
          tooltip: "üye ekle",
        )
            : const SizedBox.shrink(),
      ],
    );
  }

}

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({Key? key}) : super(key: key);

  @override
  State<AddAccountDialog> createState() => _AddAccountDialog();
}

class _AddAccountDialog extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedRole;
  String? _selectedPermission;

  List<String> rolesName = [];
  List<String> permissionsName = [];

  List<permissions> _permissionsList = [];
  List<roles> _rolesList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final permissionsResponse = await backend_services().fetchAllPermissions();
    final rolesResponse = await backend_services().fetchAllRoles();

    if (!mounted) return;

    setState(() {
      _permissionsList = permissionsResponse.data ?? [];
      _rolesList = rolesResponse.data ?? [];

      permissionsName = _permissionsList.map((p) => p.permissionName).toList();
      rolesName = _rolesList.map((r) => r.roleName).toList();
    });
  }


  Future<void> saveNewUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    roles? foundRole = _rolesList.firstWhere(
      (p) => p.roleName == _selectedRole,
      orElse: () => roles(id: "null", roleName: "NotFound"),
    );

    permissions? foundPermission = _permissionsList.firstWhere(
      (p) => p.permissionName == _selectedPermission,
      orElse: () => permissions(id: "null", permissionName: "NotFound"),
    );


    final response = await backend_services().registerUser(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      roleId: foundRole.id,
      roleName: foundRole.roleName,
      permissionId: foundPermission.id,
      permissionName: foundPermission.permissionName,
    );
    if (response.status == 'success') {
      StringHelper.showInfoDialog(context, "${response.message}");
    } else {
      StringHelper.showErrorDialog(context, "${response.message}");
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Yeni Personel Bilgileri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen kullanıcı adını girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifreyi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Adı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Soyadı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: rolesName.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Rol Seçin',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen bir rol seçin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedPermission,
                  items: permissionsName.map((perm) {
                    return DropdownMenuItem<String>(
                      value: perm,
                      child: Text(perm),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Yetki Seviyesi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPermission = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lütfen yetki seviyesi seçin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await saveNewUser();
                        }
                      },
                      child: const Text('Onayla'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
