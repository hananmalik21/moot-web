import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/time_format.dart';

// 🧊 Glass header + Neumorphic + Dynamic info
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;

// 🧩 Models
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/data/models/location_model.dart';

// 🧩 Provider (adjust path/name to your real provider)

class DepartmentDetailPage extends ConsumerStatefulWidget {
  const DepartmentDetailPage({super.key});

  @override
  ConsumerState<DepartmentDetailPage> createState() =>
      _DepartmentDetailPageState();
}

class _DepartmentDetailPageState extends ConsumerState<DepartmentDetailPage> {
  final departmentsProvider =
      ChangeNotifierProvider.autoDispose<DepartmentsProvider>(
        (ref) => DepartmentsProvider(),
      );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("department id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Implement this method in your DepartmentsProvider
      // e.g. getDepartments(departmentId: id);
      ref.read(departmentsProvider).getDepartments(departmentId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final depNotifier = ref.watch(departmentsProvider);
    final Department? department = depNotifier.selectedDepartment;

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle = (department?.departmentName.isNotEmpty ?? false)
        ? department!.departmentName
        : "Department Detail";

    final Company? company = department?.company;
    final BusinessUnit? businessUnit = department?.businessUnit;
    final Location? location = department?.location;
    final Manager? manager = department?.manager;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: depNotifier.isLoading,
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
                          // ℹ️ DEPARTMENT INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: Padding(
                              padding: EdgeInsets.all(18.w),
                              child: DynamicInfoSection(
                                title: "Department Information",
                                items: [
                                  InfoItem(
                                    label: "Department Name",
                                    value: department?.departmentName,
                                  ),
                                  InfoItem(
                                    label: "Company",
                                    value: company?.companyName,
                                  ),
                                  InfoItem(
                                    label: "Business Unit",
                                    value: businessUnit?.businessUnitName,
                                  ),
                                  InfoItem(
                                    label: "Location",
                                    value: location?.streetAddress,
                                  ),
                                  InfoItem(
                                    label: "Manager",
                                    value:
                                        "${manager?.firstName ?? ""} ${manager?.lastName ?? ""}",
                                  ),
                                  InfoItem(
                                    label: "Created At",
                                    value: department?.createdAt != null
                                        ? department!.createdAt.toCustomFormat()
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
