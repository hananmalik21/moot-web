import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/background_widget.dart';
import 'package:moot_web/features/common_widgets/build_drop_down.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/provider/users_provider.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/provider/role_provider.dart';

class AssignRoleToUser extends ConsumerStatefulWidget {
  const AssignRoleToUser({super.key});

  @override
  ConsumerState<AssignRoleToUser> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<AssignRoleToUser> {
  bool isEdit = false;
  User? user;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController departmentsController = TextEditingController();

  final userProvider = ChangeNotifierProvider.autoDispose<UserProvider>(
    (ref) => UserProvider(),
  );
  final rolesProvider = ChangeNotifierProvider.autoDispose<RoleProvider>(
    (ref) => RoleProvider(),
  );
  final departmentsProvider =
      ChangeNotifierProvider.autoDispose<DepartmentsProvider>(
        (ref) => DepartmentsProvider(),
      );

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    final usr = extra?['user'] as User?;
    user = usr;
    isEdit = user != null;

    userNameController.text =
        "${user?.firstName ?? ""} ${user?.lastName ?? ""}";
    ref.read(rolesProvider).getRoles();
    ref.read(departmentsProvider).getDepartments();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.watch(userProvider);
    final rolesNotifier = ref.watch(rolesProvider);
    final departmentsNotifier = ref.watch(departmentsProvider);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall:
            userNotifier.isLoading ||
            rolesNotifier.isLoading ||
            departmentsNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return BackgroundWidget(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FormContainer(
                          constraints: constraints,
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Assign role to ${user?.firstName ?? ""} ${user?.lastName ?? ""}',
                                        style: context.text20SemiBold.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const Divider(color: Colors.white24),
                                      20.verticalSpace,
                                      InputFieldWidget(
                                        title: "User name",
                                        hint: "Enter name",
                                        enable: false,
                                        controller: userNameController,
                                      ),
                                      BuildDropdown(
                                        controller: roleController,
                                        displayField: (val) => val.name ?? "",
                                        onChange: (val) {
                                          rolesNotifier.setRole(val);
                                        },
                                        title: "Role",
                                        label: "Choose Role",
                                        isLoadingMore: false,
                                        showSearch: false,
                                        onPagination: (val) {},
                                        searchLoading: false,
                                        searchHint: '',
                                        searchController:
                                            TextEditingController(),
                                        options: rolesNotifier.roles,
                                        onSearch: (val) {},
                                        padding: EdgeInsets.zero,
                                      ),
                                      BuildDropdown(
                                        controller: departmentsController,
                                        displayField: (val) =>
                                            val.departmentName,
                                        onChange: (val) {
                                          departmentsNotifier.setDepartment(
                                            val,
                                          );
                                        },
                                        title: "Department",
                                        label: "Choose department",
                                        isLoadingMore: false,
                                        showSearch: false,
                                        onPagination: (val) {},
                                        searchLoading: false,
                                        searchHint: '',
                                        searchController:
                                            TextEditingController(),
                                        options:
                                            departmentsNotifier.departments,
                                        onSearch: (val) {},
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // static footer
                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: customUploadBtnWidget(
                                      isLoading: userNotifier.isLoading,
                                      onTap: () {
                                        final body = {
                                          "roleId":
                                              rolesNotifier.selectedRole?.id ??
                                              "",
                                          "departmentId":
                                              departmentsNotifier
                                                  .selectedDepartment
                                                  ?.id ??
                                              "",
                                        };
                                        //
                                        userNotifier.assignRoleToUser(
                                          userId: user?.id ?? "",
                                          body: body,
                                          onSuccess: () {
                                            context.goNamed('users');
                                          },
                                        );
                                      },
                                      text: "Assign",
                                      context: context,
                                    ),
                                  ),
                                  20.verticalSpace,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
