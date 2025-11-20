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

// 🧊 Glass header + Neumorphic
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart'
    show BusinessUnit;
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/provider/business_unit_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';

class BusinessUnitDetailPage extends ConsumerStatefulWidget {
  const BusinessUnitDetailPage({super.key});

  @override
  ConsumerState<BusinessUnitDetailPage> createState() =>
      _BusinessUnitDetailPageState();
}

class _BusinessUnitDetailPageState
    extends ConsumerState<BusinessUnitDetailPage> {
  final businessUnitProvider =
      ChangeNotifierProvider.autoDispose<BusinessUnitProvider>(
        (ref) => BusinessUnitProvider(),
      );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("business unit id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Implement this in your BusinessUnitProvider
      // e.g. getBusinessUnitById(businessUnitId: id);
      ref.read(businessUnitProvider).getBusinessUnits(businessUnitId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final buNotifier = ref.watch(businessUnitProvider);
    final BusinessUnit? businessUnit = buNotifier.selectedBusinessUnit;

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle =
        (businessUnit?.businessUnitName.isNotEmpty ?? false)
        ? businessUnit!.businessUnitName
        : "Business Unit Detail";

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: buNotifier.isLoading,
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

                      final Company? parentCompany = businessUnit?.company;

                      return Wrap(
                        spacing: 22.w,
                        runSpacing: 22.h,
                        alignment: WrapAlignment.center,
                        children: [
                          // 🧊 SUMMARY CARD
                          // SizedBox(
                          //   width: cardWidth,
                          //   child: NeumorphicCard(
                          //     child: Padding(
                          //       padding: EdgeInsets.all(18.w),
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text(
                          //             businessUnit?.businessUnitName ?? "-",
                          //             style: context.text20SemiBold.copyWith(
                          //               color: context.primaryColor,
                          //             ),
                          //           ),
                          //           8.verticalSpace,
                          //           if ((businessUnit?.address?.isNotEmpty ??
                          //               false))
                          //             Text(
                          //               businessUnit!.address!,
                          //               style: context.text14Regular.copyWith(
                          //                 color: context.gray99TextColor,
                          //               ),
                          //             ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // ℹ️ BUSINESS UNIT INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: DynamicInfoSection(
                              hideTitle: true,
                              title: "Business Unit Information",
                              items: [
                                InfoItem(
                                  label: "Business Unit Name",
                                  value: businessUnit?.businessUnitName,
                                ),
                                InfoItem(
                                  label: "Company",
                                  value: parentCompany?.companyName,
                                ),
                                InfoItem(
                                  label: "Company ID",
                                  value: businessUnit?.companyId,
                                ),
                                InfoItem(
                                  label: "Address",
                                  value: businessUnit?.address,
                                ),
                                InfoItem(
                                  label: "Active",
                                  value: (businessUnit?.isActive ?? true)
                                      ? "Yes"
                                      : "No",
                                ),

                                InfoItem(
                                  label: "Updated At",
                                  value: businessUnit?.updatedAt != null
                                      ? businessUnit!.updatedAt!
                                            .toCustomFormat()
                                      : null,
                                ),
                              ],
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
