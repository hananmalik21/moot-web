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
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/provider/grades_provider.dart';


class GradesView extends ConsumerStatefulWidget {
  const GradesView({super.key});

  @override
  ConsumerState<GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends ConsumerState<GradesView> {
  final gradesProvider = ChangeNotifierProvider.autoDispose<GradeProvider>(
        (ref) => GradeProvider(),
  );

  late final PermissionGuard _guard;

  // ── Permission gates: security.grade.* or security.* ───────────────────────
  bool get _canCreateGrade =>
      _guard.allows('workforce_structure.grade.create') ||
          _guard.allows('workforce_structure.grade.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canUpdateGrade =>
      _guard.allows('workforce_structure.grade.update') ||
          _guard.allows('workforce_structure.grade.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canDeleteGrade =>
      _guard.allows('workforce_structure.grade.delete') ||
          _guard.allows('workforce_structure.grade.*') ||
          _guard.allows('workforce_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Build guard from current user’s permissions
      final perms =
      (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
          .toList();
      _guard = PermissionGuard(perms);
      ref.read(gradesProvider).getGrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(gradesProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;



    final hasActions = _canUpdateGrade || _canDeleteGrade;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Grades"),
              20.verticalSpace,

              if (_canCreateGrade)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-grade"),
                  title: "Add Grade",
                ),
              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: CustomDataTable(
                    emptyMessage: 'No Grades found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'grade-detail',
                        pathParameters: {"id": notifier.grades[index].id},
                        extra: {"role": notifier.grades[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Grade')),
                      const DataColumn(label: Text('Description')),
                      const DataColumn(label: Text('Min Salary')),
                      const DataColumn(label: Text('Max Salary')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(notifier.grades.length, (index) {
                      final grade = notifier.grades[index];
                      final isEven = index.isEven;

                      final createdText = DateFormat('MMM dd, yyyy').format(grade.createdDate);

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(grade.gradeName)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Text(grade.description),
                          ),
                        ),
                        DataCell(_salaryBadge(grade.minSalary.toString(), true)),
                        DataCell(_salaryBadge(grade.maxSalary.toString(), true)),
                        DataCell(Text(createdText)),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdateGrade)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-grade',
                                        pathParameters: {"id": grade.id},
                                        extra: {"grade": grade},
                                      );
                                    },
                                  ),
                                if (_canDeleteGrade)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () => ref
                                              .read(gradesProvider)
                                              .deleteGrade(gradeId: grade.id),
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

  // Badge renderer (kept your look)
  Widget _salaryBadge(String salary, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        salary,
        style: TextStyle(
          color: isActive ? Colors.greenAccent.shade400 : Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
