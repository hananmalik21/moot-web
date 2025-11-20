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
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/data/model/grade_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/provider/grades_provider.dart';

class GradeDetailPage extends ConsumerStatefulWidget {
  const GradeDetailPage({super.key});

  @override
  ConsumerState<GradeDetailPage> createState() => _GradeDetailPageState();
}

class _GradeDetailPageState extends ConsumerState<GradeDetailPage> {
  final gradeProvider = ChangeNotifierProvider.autoDispose<GradeProvider>(
        (ref) => GradeProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("grade id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Implement this in your GradeProvider
      // e.g. getGrades(gradeId: id);
      ref.read(gradeProvider).getGrades(gradeId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradeNotifier = ref.watch(gradeProvider);
    final Grade? grade = gradeNotifier.selectedGrade; // 🔁 adjust field name

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle =
    (grade?.gradeName.isNotEmpty ?? false) ? grade!.gradeName : "Grade Detail";

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: gradeNotifier.isLoading,
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


                          // ℹ️ GRADE INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: DynamicInfoSection(
                                title: "Grade Information",
                                items: [
                                  InfoItem(
                                    label: "Grade Name",
                                    value: grade?.gradeName,
                                  ),
                                  InfoItem(
                                    label: "Description",
                                    value: grade?.description,
                                  ),
                                  InfoItem(
                                    label: "Minimum Salary",
                                    value: grade != null
                                        ? _formatSalary(grade.minSalary)
                                        : null,
                                  ),
                                  InfoItem(
                                    label: "Maximum Salary",
                                    value: grade != null
                                        ? _formatSalary(grade.maxSalary)
                                        : null,
                                  ),
                                  InfoItem(
                                    label: "Created Date",
                                    value: grade != null
                                        ? grade.createdDate.toCustomFormat()
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



  String _formatSalary(int value) {
    // Simple formatting; you can switch to NumberFormat if you want commas/currency
    return value.toString();
  }

}
