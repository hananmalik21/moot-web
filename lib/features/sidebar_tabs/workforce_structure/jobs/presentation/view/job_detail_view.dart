import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/extensions/time_format.dart';

// 🧊 Glass header + Neumorphic + Dynamic Info
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/provider/jobs_provider.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  const JobDetailPage({super.key});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  final jobsProvider = ChangeNotifierProvider.autoDispose<JobsProvider>(
        (ref) => JobsProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("job id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Implement this in your JobsProvider
      // e.g. getJobs(jobId: id);
      ref.read(jobsProvider).getJobs(jobId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobsNotifier = ref.watch(jobsProvider);
    final JobsModel? job = jobsNotifier.selectedJob; // 🔁 adjust field name

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle =
    (job?.jobTitle.isNotEmpty ?? false) ? job!.jobTitle : "Job Detail";

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: jobsNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(
              context,
              isMobile,
              headerTitle,
              showButtons: false,
            ),

            // 👉 FLEXIBLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double fullWidth = constraints.maxWidth;
                      final double desiredWidth = fullWidth / 2 - 18.w;

                      // If very narrow, card goes full width
                      final double cardWidth =
                      desiredWidth < 380 ? fullWidth : desiredWidth;

                      return Wrap(
                        spacing: 22.w,
                        runSpacing: 22.h,
                        alignment: WrapAlignment.center,
                        children: [


                          // ℹ️ JOB INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: DynamicInfoSection(
                                title: "Job Information",
                                items: [
                                  InfoItem(
                                    label: "Job Title",
                                    value: job?.jobTitle,
                                  ),
                                  InfoItem(
                                    label: "Description",
                                    value: job?.description,
                                  ),
                                  InfoItem(
                                    label: "Minimum Salary",
                                    value: job != null
                                        ? _formatSalary(job.minSalary)
                                        : null,
                                  ),
                                  InfoItem(
                                    label: "Maximum Salary",
                                    value: job != null
                                        ? _formatSalary(job.maxSalary)
                                        : null,
                                  ),
                                  InfoItem(
                                    label: "Created Date",
                                    value: job?.createdDate.toCustomFormat(),
                                  ),

                                ],
                              ),
                            ),
                          ),

                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSalaryRange(double min, double max) {
    // You can enhance this with currency / locale if needed
    return "${_formatSalary(min)}  -  ${_formatSalary(max)}";
  }

  String _formatSalary(double value) {
    // Simple formatting, tweak as needed (currency, decimals, etc.)
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }


}
