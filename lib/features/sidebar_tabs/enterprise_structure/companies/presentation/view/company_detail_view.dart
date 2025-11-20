import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/time_format.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';

class CompanyDetailPage extends ConsumerStatefulWidget {
  const CompanyDetailPage({super.key});

  @override
  ConsumerState<CompanyDetailPage> createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends ConsumerState<CompanyDetailPage> {
  final companyProvider = ChangeNotifierProvider.autoDispose<CompanyProvider>(
    (ref) => CompanyProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("company id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider).getCompanies(companyId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyNotifier = ref.watch(companyProvider);
    final Company? company = companyNotifier.selectedCompany;

    final isMobile = MediaQuery.of(context).size.width < 600;

    final String headerTitle = (company?.companyName.isNotEmpty ?? false)
        ? company!.companyName
        : "Company Detail";

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: companyNotifier.isLoading,
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
                          // ℹ️ COMPANY INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: DynamicInfoSection(
                              hideTitle: true,
                              title: "Company Information",
                              items: [
                                InfoItem(
                                  label: "Company Name",
                                  value: company?.companyName,
                                ),
                                InfoItem(
                                  label: "Description",
                                  value: company?.description,
                                ),
                                InfoItem(
                                  label: "Address",
                                  value: company?.address,
                                ),
                                InfoItem(
                                  label: "Active",
                                  value: (company?.isActive ?? false)
                                      ? "Yes"
                                      : "No",
                                ),
                                InfoItem(
                                  label: "Updated At",
                                  value: company?.updatedAt != null
                                      ? (company!.updatedAt!).toCustomFormat()
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
