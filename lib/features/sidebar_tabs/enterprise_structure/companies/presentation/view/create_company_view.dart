import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';

class CreateCompanyView extends ConsumerStatefulWidget {
  const CreateCompanyView({super.key});

  @override
  ConsumerState<CreateCompanyView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<CreateCompanyView> {
  bool isEdit = false;
  Company? company;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();

  final companyProvider = ChangeNotifierProvider.autoDispose<CompanyProvider>(
    (ref) => CompanyProvider(),
  );

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    final comp = extra?['company'] as Company?;
    company = comp;
    isEdit = company != null;

    companyNameController.text = company?.companyName ?? "";
    descriptionController.text = company?.description ?? "";
    addressController.text = company?.address ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final companyNotifier = ref.watch(companyProvider);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: companyNotifier.isLoading,
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
                                          ? 'Edit Company'
                                          : 'Create Company',
                                      style: context.text20SemiBold
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Company Name",
                                      hint: "Enter name",
                                      controller: companyNameController,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Company Description",
                                      hint: "Enter description",
                                      controller: descriptionController,
                                      minLines: 4,
                                      maxLines: 8,
                                      showPadding: true,
                                    ),
                                    20.verticalSpace,
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
                                    isLoading: companyNotifier.isLoading,
                                    onTap: () {
                                      if (companyNameController
                                          .text
                                          .isEmpty) {
                                        Utils().showToast(
                                          "Please enter company name",
                                        );
                                        return;
                                      }
                                      final body = {
                                        "companyName":
                                            companyNameController.text,
                                        "description":
                                            descriptionController.text,
                                        "address": addressController.text,
                                      };

                                      if (isEdit) {
                                        companyNotifier.updateCompany(
                                          companyId: company?.id ?? "",

                                          body: body,
                                          onSuccess: () {
                                            context.goNamed('companies');
                                          },
                                        );
                                        return;
                                      }
                                      companyNotifier.createCompany(
                                        body: body,
                                        onSuccess: () {
                                          context.goNamed('companies');
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
