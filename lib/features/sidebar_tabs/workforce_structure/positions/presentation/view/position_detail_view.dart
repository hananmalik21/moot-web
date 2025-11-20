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
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/data/model/position_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/provider/position_provider.dart';

class PositionDetailPage extends ConsumerStatefulWidget {
  const PositionDetailPage({super.key});

  @override
  ConsumerState<PositionDetailPage> createState() => _PositionDetailPageState();
}

class _PositionDetailPageState extends ConsumerState<PositionDetailPage> {
  final positionsProvider =
      ChangeNotifierProvider.autoDispose<PositionProvider>(
        (ref) => PositionProvider(),
      );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("position id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(positionsProvider).getPositions(positionId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final posNotifier = ref.watch(positionsProvider);
    final Position? position = posNotifier.selectedPosition; // adjust name

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle = (position?.positionTitle.isNotEmpty ?? false)
        ? position!.positionTitle
        : "Position Detail";

    final JobsModel? job = position?.job;
    final Grade? grade = position?.grade;
    final Department? department = position?.department;
    final BusinessUnit? businessUnit = position?.businessUnit;
    final Company? company = position?.company;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: posNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(context, isMobile, headerTitle, showButtons: false),

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
                      final double cardWidth = desiredWidth < 380
                          ? fullWidth
                          : desiredWidth;

                      return Wrap(
                        spacing: 22.w,
                        runSpacing: 22.h,
                        alignment: WrapAlignment.center,
                        children: [
                          // ℹ️ POSITION INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: DynamicInfoSection(
                                title: "Position Information",
                                items: [
                                  InfoItem(
                                    label: "Position Title",
                                    value: position?.positionTitle,
                                  ),
                                  InfoItem(
                                    label: "Position Status",
                                    value: position?.positionStatus,
                                  ),
                                  InfoItem(
                                    label: "Job",
                                    value: job?.jobTitle,
                                  ),
                                  InfoItem(
                                    label: "Grade",
                                    value: grade?.gradeName,
                                  ),
                                  InfoItem(
                                    label: "Department",
                                    value: department?.departmentName,
                                  ),
                                  InfoItem(
                                    label: "Business Unit",
                                    value: businessUnit?.businessUnitName,
                                  ),
                                  InfoItem(
                                    label: "Company",
                                    value: company?.companyName,
                                  ),
                                  InfoItem(
                                    label: "Created Date",
                                    value: position != null
                                        ? (position.createdAt ??
                                                  position.createdDate)
                                              .toCustomFormat()
                                        : null,
                                  ),
                                  InfoItem(
                                    label: "Updated At",
                                    value: position?.updatedAt != null
                                        ? position!.updatedAt!
                                              .toCustomFormat()
                                        : null,
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
}
