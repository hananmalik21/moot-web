import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';

import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/provider/users_provider.dart';


class UsersView extends ConsumerStatefulWidget {
  const UsersView({super.key});

  @override
  ConsumerState<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView> {
  // Provider
  final usersProvider = ChangeNotifierProvider.autoDispose<UserProvider>(
    (ref) => UserProvider(),
  );

  // Permissions
  late final PermissionGuard _guard;

  bool get _canCreateUser =>
      _guard.allows('security.user.create') ||
      _guard.allows('security.*') ||
      _guard.allows('security.user.*');

  bool get _canUpdateUser =>
      _guard.allows('security.user.update') ||
      _guard.allows('security.*') ||
      _guard.allows('security.user.*');

  bool get _canDeleteUser =>
      _guard.allows('security.user.delete') ||
      _guard.allows('security.*') ||
      _guard.allows('security.user.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final perms =
          (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
              .toList();
      _guard = PermissionGuard(perms);
      ref.read(usersProvider).getUsers();
    });
  }
@override
  void dispose() {
    // TODO: implement dispose
  debugPrint("user view disposed");
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(usersProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Employees"),
              20.verticalSpace,
              if (_canCreateUser) _buildAddEmployeeButton(context),
              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: _buildUsersTable(context, notifier),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _buildAddEmployeeButton(BuildContext context) {
    return AddButtonWidget(
      onTap: () => context.goNamed("create-user"),
      title: "Add Employee",
    );
  }

  Widget _buildUsersTable(BuildContext context, UserProvider notifier) {
    final hasActions = _canUpdateUser || _canDeleteUser;

    final columns = <DataColumn>[
      const DataColumn(label: Text('#')),
      const DataColumn(label: Text('Employee')),
      const DataColumn(label: Text('Name')),
      const DataColumn(label: Text('Email')),
      const DataColumn(label: Text('Department Name')),
      const DataColumn(label: Text('Job')),
      const DataColumn(label: Text('Position')),
      const DataColumn(label: Text('Grade')),
      const DataColumn(label: Text('Roles')),
      const DataColumn(label: Text('Designation')),
      const DataColumn(label: Text('Hired Date')),
      if (hasActions) const DataColumn(label: Text('Actions')),
    ];

    return CustomDataTable(
      emptyMessage: 'No User found',
      headerColor: context.primaryColor,
      columns: columns,
      onRowTap: (index){
        context.goNamed(
          'user-detail',
          pathParameters: {"id": notifier.users[index].id},
          extra: {"user": notifier.users[index]},
        );
      },
      rows: List<DataRow>.generate(
        notifier.users.length,
        (index) => _buildUserRow(context, notifier, index, hasActions),
      ),
    );
  }

  DataRow _buildUserRow(
    BuildContext context,
    UserProvider notifier,
    int index,
    bool hasActions,
  ) {
    final user = notifier.users[index];
    final isEven = index.isEven;

    final cells = <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(Text(user.employeeId)),
      DataCell(Text('${user.firstName} ${user.lastName}')),
      DataCell(Text(user.email)),
      DataCell(Text(user.department?.departmentName ?? '')),
      DataCell(Text(user.job?.jobTitle ?? '')),
      DataCell(Text(user.position?.positionTitle ?? '')),
      DataCell(Text(user.grade?.gradeName ?? '')),
      _buildRolesCell(context, notifier, user),
      DataCell(Text(user.designation)),
      DataCell(
        Text(
          user.hireDate != null
              ? DateFormat('MMM dd, yyyy').format(user.hireDate!)
              : '—',
        ),
      ),
      if (hasActions) _buildActionsCell(context, notifier, user),
    ];

    return DataRow(
      color: WidgetStateProperty.all(
        isEven ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
      ),
      cells: cells,
    );
  }

  DataCell _buildActionsCell(
    BuildContext context,
    UserProvider notifier,
    User user,
  ) {
    return DataCell(
      Row(
        children: [
          if (_canUpdateUser)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
              tooltip: 'Edit',
              onPressed: () {
                context.goNamed(
                  'edit-user',
                  pathParameters: {"id": user.id},
                  extra: {"user": user},
                );
              },
            ),
          if (_canDeleteUser)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
              tooltip: 'Delete',
              onPressed: () {
                Utils().showCustomDialog(
                  context,
                  DeleteDialogWidget(
                    onClick: () => notifier.deleteUser(userId: user.id),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  DataCell _buildRolesCell(
    BuildContext context,
    UserProvider notifier,
    User user,
  ) {
    // Prefer effective roles, fallback gracefully
    final List<EffectiveUserRoleAssignment> effectiveAsDisplay = user
        .effectiveUserRoles
        .map((e) {
          final dept =
              e.department ??
              UserDepartment(
                id: '',
                departmentName: (e.access == null || e.access!.isEmpty)
                    ? 'ALL'
                    : e.access!,
              );
          return EffectiveUserRoleAssignment(
            role: e.role,
            department: dept,
            access: e.access,
          );
        })
        .toList(growable: false);

    final List<EffectiveUserRoleAssignment> display =
        effectiveAsDisplay.isNotEmpty
        ? effectiveAsDisplay
        : user.effectiveUserRoles;

    final roleCount = display.length;
    final hasRoles = roleCount > 0;

    final content = Row(
      children: [
        Icon(
          Icons.group,
          size: 18,
          color: hasRoles ? context.primaryColor : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          hasRoles ? '$roleCount' : '—',
          style: TextStyle(color: hasRoles ? null : Colors.grey),
        ),
        if (effectiveAsDisplay.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Text('effective', style: TextStyle(fontSize: 10)),
          ),
        ],
      ],
    );

    if (!hasRoles) return DataCell(content);

    return DataCell(
      Tooltip(
        message: 'View $roleCount role${roleCount == 1 ? '' : 's'}',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Allow delete from the dialog (your provider will handle auth/validation server-side)
            Utils().showCustomDialog(
              context,
              ViewUserRolesDialog(
                fullName: '${user.firstName} ${user.lastName}',
                roles: display,
                user: user,
                onDelete: (roleId, departmentId) {
                  // Early exit if user lacks delete privilege on role assignment (optional)
                  notifier.removeRoleFromUser(
                    userId: user.id,
                    body: {"roleId": roleId, "departmentId": departmentId},
                  );
                },
              ),
            );
          },
          child: content,
        ),
      ),
    );
  }
}

// ---------------- Dialog ----------------

class ViewUserRolesDialog extends StatefulWidget {
  final String fullName;
  final List<EffectiveUserRoleAssignment> roles;
  final User user;
  final void Function(String roleId, String departmentId) onDelete;

  const ViewUserRolesDialog({
    super.key,
    required this.fullName,
    required this.roles,
    required this.user,
    required this.onDelete,
  });

  @override
  State<ViewUserRolesDialog> createState() => _ViewUserRolesDialogState();
}

class _ViewUserRolesDialogState extends State<ViewUserRolesDialog> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EffectiveUserRoleAssignment> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.roles;
    bool match(EffectiveUserRoleAssignment r) {
      final roleName = r.role.name.toLowerCase();
      final deptName = (r.department?.departmentName ?? "").toLowerCase();
      return roleName.contains(q) || deptName.contains(q);
    }

    return widget.roles.where(match).toList();
  }

  Future<void> _addNewRole() async {
    context.goNamed(
      'assign-role',
      pathParameters: {"id": widget.user.id},
      extra: {"user": widget.user},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final roles = _filtered;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: isMobile ? 520 : 720,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 520 : 720,
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          (isMobile ? 0.75 : 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(Icons.group, color: context.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Roles • ${widget.fullName}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${roles.length}/${widget.roles.length}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search + Add
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search roles or departments…',
                                  prefixIcon: const Icon(Icons.search),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            customUploadBtnWidget(
                              text: 'Add role',
                              width: 120,
                              height: 40,
                              onTap: _addNewRole,
                              borderRadius: 10,
                              context: context,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Body
                        Expanded(
                          child: roles.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.roles.isEmpty
                                        ? 'No roles'
                                        : 'No matches for “${_searchCtrl.text}”',
                                  ),
                                )
                              : Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(
                                      right: 4,
                                      bottom: 12,
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: roles.map((r) {
                                        final dep =
                                            r.department?.departmentName ?? '';
                                        final label = dep.isNotEmpty
                                            ? '${r.role.name} • $dep'
                                            : r.role.name;
                                        return Chip(
                                          label: Text(label),
                                          avatar: Icon(
                                            Icons.badge,
                                            size: 16,
                                            color: context.blackColor,
                                          ),
                                          deleteIcon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          onDeleted: () {
                                            Navigator.of(context).pop();
                                            widget.onDelete(
                                              r.role.id,
                                              r.department?.id ?? "",
                                            );
                                          },
                                          backgroundColor: context.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: BorderSide(
                                              color: Colors.white.withOpacity(
                                                0.18,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                        ),

                        // Footer
                        Align(
                          alignment: Alignment.centerRight,
                          child: customUploadBtnWidget(
                            context: context,
                            text: 'Close',
                            width: 120,
                            height: 44,
                            borderRadius: 10,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
