import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';
import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

// ✅ Permission guard + current user
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart';

class DepartmentsView extends ConsumerStatefulWidget {
  const DepartmentsView({super.key});

  @override
  ConsumerState<DepartmentsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<DepartmentsView> {
  final departmentsProvider =
      ChangeNotifierProvider.autoDispose<DepartmentsProvider>(
        (ref) => DepartmentsProvider(),
      );

  // Initialize once; don't reassign in build()
  PermissionGuard? _guard;

  // ── Permissions: enterprise_structure.department.* or enterprise_structure.* ──
  bool get _canCreateDepartment =>
      _guard?.allows('enterprise_structure.department.create') == true ||
      _guard?.allows('enterprise_structure.department.*') == true ||
      _guard?.allows('enterprise_structure.*') == true;

  bool get _canUpdateDepartment =>
      _guard?.allows('enterprise_structure.department.update') == true ||
      _guard?.allows('enterprise_structure.department.*') == true ||
      _guard?.allows('enterprise_structure.*') == true;

  bool get _canDeleteDepartment =>
      _guard?.allows('enterprise_structure.department.delete') == true ||
      _guard?.allows('enterprise_structure.department.*') == true ||
      _guard?.allows('enterprise_structure.*') == true;

  @override
  void initState() {
    super.initState();

    // Kick off data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentsProvider).getDepartments();

      // Build guard ONCE with current user's permissions
      final perms =
      (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
              .toList();
      setState(() {
        _guard = PermissionGuard(perms);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(departmentsProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    // If guard hasn't been set yet (very first build), treat as no actions
    final hasActions = _canUpdateDepartment || _canDeleteDepartment;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Departments"),

              // Add button (guarded)
              if (_canCreateDepartment)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-departments"),
                  title: "Add Department",
                ),

              const SizedBox(height: 12),

              // Table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CustomDataTable(
                    emptyMessage: 'No departments found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'department-detail',
                        pathParameters: {"id": notifier.departments[index].id},
                        extra: {"department": notifier.departments[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Department Name')),
                      const DataColumn(label: Text('Business Unit')),
                      const DataColumn(label: Text('Company')),
                      const DataColumn(label: Text('Location')),
                      const DataColumn(label: Text('Manager')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(notifier.departments.length, (
                      index,
                    ) {
                      final dept = notifier.departments[index];
                      final isEven = index.isEven;
                      final createdText = DateFormat(
                        'MMM dd, yyyy',
                      ).format(dept.createdAt);

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(dept.departmentName)),
                        DataCell(
                          Text(dept.businessUnit?.businessUnitName ?? ""),
                        ),
                        DataCell(Text(dept.company?.companyName ?? "")),
                        DataCell(Text(dept.location?.streetAddress ?? "--")),
                        DataCell(
                          Text(
                            "${dept.manager?.firstName ?? ""} ${dept.manager?.lastName ?? ""}",
                          ),
                        ),
                        DataCell(Text(createdText)),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdateDepartment)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Edit Department',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-departments',
                                        pathParameters: {"id": dept.id},
                                        extra: {"department": dept},
                                      );
                                    },
                                  ),
                                if (_canDeleteDepartment)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Delete Department',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () => ref
                                              .read(departmentsProvider)
                                              .deleteDepartment(
                                                departmentId: dept.id,
                                              ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
