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

// ✅ guard + current user perms
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';

import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/provider/position_provider.dart';

class PositionView extends ConsumerStatefulWidget {
  const PositionView({super.key});

  @override
  ConsumerState<PositionView> createState() => _PositionViewState();
}

class _PositionViewState extends ConsumerState<PositionView> {
  final positionProvider = ChangeNotifierProvider.autoDispose<PositionProvider>(
        (ref) => PositionProvider(),
  );

  late final PermissionGuard _guard;

  // ── Permission getters: security.position.* or security.* ────────────────
  bool get _canCreatePosition =>
      _guard.allows('workforce_structure.position.create') ||
          _guard.allows('workforce_structure.position.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canUpdatePosition =>
      _guard.allows('workforce_structure.position.update') ||
          _guard.allows('workforce_structure.position.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canDeletePosition =>
      _guard.allows('workforce_structure.position.delete') ||
          _guard.allows('workforce_structure.position.*') ||
          _guard.allows('workforce_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      final perms =
      (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
          .toList();
      _guard = PermissionGuard(perms);
      ref.read(positionProvider).getPositions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(positionProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;


    final hasActions = _canUpdatePosition || _canDeletePosition;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Positions"),
              20.verticalSpace,

              if (_canCreatePosition)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-position"),
                  title: "Add Position",
                ),


              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: CustomDataTable(
                    emptyMessage: 'No Positions found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'position-detail',
                        pathParameters: {"id": notifier.positions[index].id},
                        extra: {"position": notifier.positions[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Position Title')),
                      const DataColumn(label: Text('Company')),
                      const DataColumn(label: Text('Business Unit')),
                      const DataColumn(label: Text('Department')),
                      const DataColumn(label: Text('Job')),
                      const DataColumn(label: Text('Grade')),
                      const DataColumn(label: Text('Status')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(notifier.positions.length, (index) {
                      final position = notifier.positions[index];
                      final isEven = index.isEven;

                      final createdText = DateFormat('MMM dd, yyyy').format(position.createdDate);

                      // robust status check
                      final statusRaw = (position.positionStatus).trim();
                      final isActive = statusRaw.toUpperCase() == 'ACTIVE';

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(position.positionTitle)),
                        DataCell(Text(position.company?.companyName ?? "")),
                        DataCell(Text(position.businessUnit?.businessUnitName ?? "")),
                        DataCell(Text(position.department?.departmentName ?? "")),
                        DataCell(Text(position.job?.jobTitle ?? "")),
                        DataCell(Text(position.grade?.gradeName ?? "")),
                        DataCell(_statusBadge(statusRaw.isEmpty ? '—' : statusRaw, isActive)),
                        DataCell(Text(createdText)),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdatePosition)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-position',
                                        pathParameters: {"id": position.id},
                                        extra: {"position": position},
                                      );
                                    },
                                  ),
                                if (_canDeletePosition)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () => ref.read(positionProvider).deletePosition(
                                            positionId: position.id,
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

  // kept your original look, just renamed intent & made it robust
  Widget _statusBadge(String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.greenAccent.shade400 : Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
