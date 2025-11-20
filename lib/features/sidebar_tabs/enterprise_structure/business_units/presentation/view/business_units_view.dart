import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/provider/business_unit_provider.dart';

class BusinessUnitView extends ConsumerStatefulWidget {
  const BusinessUnitView({super.key});

  @override
  ConsumerState<BusinessUnitView> createState() => _BusinessUnitViewState();
}

class _BusinessUnitViewState extends ConsumerState<BusinessUnitView> {
  final businessUnitProvider =
      ChangeNotifierProvider.autoDispose<BusinessUnitProvider>(
        (ref) => BusinessUnitProvider(),
      );

  late final PermissionGuard _guard;

  // ── Permission gates: enterprise_structure.business_unit.* or enterprise_structure.* ──
  bool get _canCreateBU =>
      _guard.allows('enterprise_structure.business_unit.create') ||
      _guard.allows('enterprise_structure.business_unit.*') ||
      _guard.allows('enterprise_structure.*');

  bool get _canUpdateBU =>
      _guard.allows('enterprise_structure.business_unit.update') ||
      _guard.allows('enterprise_structure.business_unit.*') ||
      _guard.allows('enterprise_structure.*');

  bool get _canDeleteBU =>
      _guard.allows('enterprise_structure.business_unit.delete') ||
      _guard.allows('enterprise_structure.business_unit.*') ||
      _guard.allows('enterprise_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessUnitProvider).getBusinessUnits();
      // Build guard from current user’s permissions
      final perms =
          (ref.watch(userDataProvider)?.user?.user.permissions ?? const <String>[])
              .toList();
      _guard = PermissionGuard(perms);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(businessUnitProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final hasActions = _canUpdateBU || _canDeleteBU;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Business Units"),
              20.verticalSpace,

              if (_canCreateBU)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-business-units"),
                  title: "Add Business Units",
                ),

              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: CustomDataTable(
                    emptyMessage: 'No business units found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'business-unit-detail',
                        pathParameters: {"id": notifier.businessUnits[index].id},
                        extra: {"role": notifier.businessUnits[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Business Unit')),
                      const DataColumn(label: Text('Company')),
                      const DataColumn(label: Text('Address')),
                      const DataColumn(label: Text('Active')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      notifier.businessUnits.length,
                      (index) {
                        final bu = notifier.businessUnits[index];
                        final isEven = index.isEven;

                        final createdText = bu.createdAt != null
                            ? DateFormat('MMM dd, yyyy').format(bu.createdAt!)
                            : '—';

                        final cells = <DataCell>[
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(bu.businessUnitName)),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(bu.company?.companyName ?? ""),
                            ),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(bu.address ?? ""),
                            ),
                          ),
                          DataCell(Text((bu.isActive).toString())),
                          DataCell(Text(createdText)),
                        ];

                        if (hasActions) {
                          cells.add(
                            DataCell(
                              Row(
                                children: [
                                  if (_canUpdateBU)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      tooltip: 'Edit',
                                      onPressed: () {
                                        context.goNamed(
                                          'edit-business-units',
                                          pathParameters: {"id": bu.id},
                                          // keep a clear key name for extra
                                          extra: {"businessUnit": bu},
                                        );
                                      },
                                    ),
                                  if (_canDeleteBU)
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
                                            onClick: () => ref
                                                .read(businessUnitProvider)
                                                .deleteBusinessUnit(
                                                  businessUnitId: bu.id,
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
                      },
                    ),
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
