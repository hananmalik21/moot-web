import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';
import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

// ✅ For PermissionGuard + current user's permissions
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';

import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/provider/permission_provider.dart';

class PermissionsView extends ConsumerStatefulWidget {
  const PermissionsView({super.key});

  @override
  ConsumerState<PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends ConsumerState<PermissionsView> {
  final permissionProvider =
  ChangeNotifierProvider.autoDispose<PermissionProvider>(
        (ref) => PermissionProvider(),
  );

  late final PermissionGuard _guard;

  // ─── Permission getters ────────────────────────────────────────────────────
  bool get _canCreatePermission =>
      _guard.allows('security.permission.create') ||
          _guard.allows('security.permission.*') ||
          _guard.allows('security.*');

  bool get _canUpdatePermission =>
      _guard.allows('security.permission.update') ||
          _guard.allows('security.permission.*') ||
          _guard.allows('security.*');

  bool get _canDeletePermission =>
      _guard.allows('security.permission.delete') ||
          _guard.allows('security.permission.*') ||
          _guard.allows('security.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      ref.read(permissionProvider).getPermissions();
      // Build guard from current user’s permissions
      final perms =
      (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
          .toList();
      _guard = PermissionGuard(perms);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(permissionProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;



    final hasActions = _canUpdatePermission || _canDeletePermission;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Permissions"),
              20.verticalSpace,

              // Create button only if allowed
              if (_canCreatePermission)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-permission"),
                  title: "Add Permission",
                ),

              20.verticalSpace,
              CustomDataTable(
                emptyMessage: 'No permission found',
                headerColor: context.primaryColor,
                onRowTap: (index){
                  context.goNamed(
                    'permission-detail',
                    pathParameters: {"id": notifier.permissions[index].id},
                    extra: {"permission": notifier.permissions[index]},
                  );
                },
                columns: [
                  const DataColumn(label: Text('#')),
                  const DataColumn(label: Text('Label')),
                  const DataColumn(label: Text('Key')),
                  const DataColumn(label: Text('Group')),
                  const DataColumn(label: Text('System Permission')),
                  if (hasActions) const DataColumn(label: Text('Actions')),
                ],
                rows: List<DataRow>.generate(notifier.permissions.length,
                        (index) {
                      final permission = notifier.permissions[index];
                      final isEven = index.isEven;

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(permission.label)),
                        DataCell(Text(permission.key)),
                        DataCell(Text(permission.group)),
                        DataCell(Text((permission.isSystemPermission).toString())),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdatePermission)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-permission',
                                        pathParameters: {"id": permission.id},
                                        extra: {"permission": permission},
                                      );
                                    },
                                  ),
                                if (_canDeletePermission)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () {
                                            ref
                                                .read(permissionProvider)
                                                .deletePermission(
                                              permissionId: permission.id,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return DataRow(
                        color: WidgetStateProperty.all(
                          isEven
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                        ),
                        cells: cells,
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
