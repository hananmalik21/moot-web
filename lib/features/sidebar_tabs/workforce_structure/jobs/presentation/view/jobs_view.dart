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
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/provider/jobs_provider.dart';


class JobsView extends ConsumerStatefulWidget {
  const JobsView({super.key});

  @override
  ConsumerState<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends ConsumerState<JobsView> {
  final jobsProvider = ChangeNotifierProvider.autoDispose<JobsProvider>(
        (ref) => JobsProvider(),
  );

  late final PermissionGuard _guard;

  // ── Permission gates: security.job.* or security.* ─────────────────────────
  bool get _canCreateJob =>
      _guard.allows('workforce_structure.job.create') ||
          _guard.allows('workforce_structure.job.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canUpdateJob =>
      _guard.allows('workforce_structure.job.update') ||
          _guard.allows('workforce_structure.job.*') ||
          _guard.allows('workforce_structure.*');

  bool get _canDeleteJob =>
      _guard.allows('workforce_structure.job.delete') ||
          _guard.allows('workforce_structure.job.*') ||
          _guard.allows('workforce_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobsProvider).getJobs();
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
    final notifier = ref.watch(jobsProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final hasActions = _canUpdateJob || _canDeleteJob;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Jobs"),
              20.verticalSpace,

              if (_canCreateJob)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-jobs"),
                  title: "Add Job",
                ),

              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: CustomDataTable(
                    emptyMessage: 'No jobs found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'job-detail',
                        pathParameters: {"id": notifier.jobs[index].id},
                        extra: {"role": notifier.jobs[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Job Title')),
                      const DataColumn(label: Text('Description')),
                      const DataColumn(label: Text('Min Salary')),
                      const DataColumn(label: Text('Max Salary')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(notifier.jobs.length, (index) {
                      final job = notifier.jobs[index];
                      final isEven = index.isEven;

                      final createdText = DateFormat('MMM dd, yyyy').format(job.createdDate);

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(job.jobTitle)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Text(job.description),
                          ),
                        ),
                        DataCell(_salaryBadge(job.minSalary.toString(), true)),
                        DataCell(_salaryBadge(job.maxSalary.toString(), true)),
                        DataCell(Text(createdText)),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdateJob)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-jobs',
                                        pathParameters: {"id": job.id},
                                        extra: {"job": job},
                                      );
                                    },
                                  ),
                                if (_canDeleteJob)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () => ref
                                              .read(jobsProvider)
                                              .deleteJob(jobId: job.id),
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

  // Badge renderer (kept your style)
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
