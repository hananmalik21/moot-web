import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/build_drop_down.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/provider/business_unit_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';

class CreateBusinessUnitView extends ConsumerStatefulWidget {
  const CreateBusinessUnitView({super.key});

  @override
  ConsumerState<CreateBusinessUnitView> createState() =>
      _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<CreateBusinessUnitView> {
  bool isEdit = false;
  BusinessUnit? businessUnit;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessUnitController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final businessUnitProvider =
      ChangeNotifierProvider.autoDispose<BusinessUnitProvider>(
        (ref) => BusinessUnitProvider(),
      );
  final companyProvider = ChangeNotifierProvider.autoDispose<CompanyProvider>(
    (ref) => CompanyProvider(),
  );

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    final unit = extra?['business-units'] as BusinessUnit?;
    businessUnit = unit;
    isEdit = businessUnit != null;

    businessUnitController.text = businessUnit?.businessUnitName ?? "";
    companyNameController.text = businessUnit?.company?.companyName ?? "";
    addressController.text = businessUnit?.address ?? "";
    ref.read(companyProvider).getCompanies(onSuccess: (){
      ref
          .read(businessUnitProvider)
          .setCompany(businessUnit?.company, companies: ref.read(companyProvider).companies);
      companyNameController.text = ref.read(businessUnitProvider).selectedCompany?.companyName??"";
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessUnitNotifier = ref.watch(businessUnitProvider);
    final companyNotifier = ref.watch(companyProvider);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: businessUnitNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FormContainer(
                        constraints: constraints,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      isEdit
                                          ? 'Edit Business Unit'
                                          : 'Create Business Unit',
                                      style: context.text20SemiBold
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Business Unit Name",
                                      hint: "Enter name",
                                      controller: businessUnitController,
                                    ),
                                    20.verticalSpace,
                                    BuildDropdown(
                                      controller: companyNameController,
                                      displayField: (val) => val.companyName,
                                      onChange: (val) => businessUnitNotifier
                                          .setCompany(val),
                                      title: "Company",
                                      label: "Select company",
                                      isLoadingMore: false,
                                      onPagination: (val) {},
                                      searchLoading: false,
                                      searchHint: "",
                                      searchController:
                                          TextEditingController(),
                                      options: companyNotifier.companies,
                                      onSearch: (val) {},
                                    ),

                                    InputFieldWidget(
                                      title: "Address",
                                      hint: "Enter address",
                                      controller: addressController,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // static footer
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: customUploadBtnWidget(
                                    isLoading: businessUnitNotifier.isLoading,
                                    onTap: () {
                                      if (companyNameController
                                          .text
                                          .isEmpty) {
                                        Utils().showToast(
                                          "Please enter company name",
                                        );
                                        return;
                                      } if (businessUnitNotifier.selectedCompany==null) {
                                        Utils().showToast(
                                          "Please select company",
                                        );
                                        return;
                                      }

                                      final body = {
                                        "company": businessUnitNotifier.selectedCompany?.id??"",
                                        "businessUnitName": businessUnitController.text,
                                        "address": addressController.text
                                      };

                                      if (isEdit) {
                                        businessUnitNotifier
                                            .updateBusinessUnit(
                                              businessUnitId:
                                                  businessUnit?.id ?? "",

                                              body: body,
                                              onSuccess: () {
                                                context.goNamed(
                                                  'business-units',
                                                );
                                              },
                                            );
                                        return;
                                      }
                                      businessUnitNotifier.createBusinessUnit(
                                        body: body,
                                        onSuccess: () {
                                          context.goNamed('business-units');
                                        },
                                      );
                                    },
                                    text: isEdit ? "Edit" : "Create",
                                    context: context,
                                  ),
                                ),
                                20.verticalSpace,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
