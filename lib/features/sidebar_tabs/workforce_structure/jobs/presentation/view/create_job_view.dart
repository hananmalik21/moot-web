import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/data/models/jobs_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/provider/jobs_provider.dart';

class CreateJobsView extends ConsumerStatefulWidget {
  const CreateJobsView({super.key});

  @override
  ConsumerState<CreateJobsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<CreateJobsView> {
  bool isEdit = false;
  JobsModel? job;
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();

  final jobsProvider = ChangeNotifierProvider.autoDispose<JobsProvider>(
    (ref) => JobsProvider(),
  );

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    final dept = extra?['job'] as JobsModel?;
    job = dept;
    isEdit = job != null;

    jobTitleController.text = job?.jobTitle ?? "";
    descriptionController.text = job?.description ?? "";
    maxSalaryController.text = (job?.maxSalary ?? "").toString();
    minSalaryController.text = (job?.minSalary ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    final jobsNotifier = ref.watch(jobsProvider);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: jobsNotifier.isLoading,
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
                                      isEdit ? 'Edit Job' : 'Create Job',
                                      style: context.text20SemiBold
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Job Title",
                                      hint: "Enter title",
                                      controller: jobTitleController,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Job Description",
                                      hint: "Enter description",
                                      controller: descriptionController,
                                      minLines: 4,
                                      maxLines: 8,
                                      showPadding: true,
                                    ),
                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Max Salary",
                                      hint: "Enter salary",
                                      controller: maxSalaryController,

                                      inputFormatter: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}$'),
                                        ),
                                      ],
                                    ),

                                    20.verticalSpace,
                                    InputFieldWidget(
                                      title: "Min Salary",
                                      hint: "Enter salary",
                                      controller: minSalaryController,
                                      inputFormatter: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}$'),
                                        ),
                                      ],
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
                                    isLoading: jobsNotifier.isLoading,
                                    onTap: () {
                                      if (double.parse(
                                            minSalaryController.text,
                                          ) >
                                          double.parse(
                                            maxSalaryController.text,
                                          )) {
                                        Utils().showToast("Max salary cannot be less than min salary");
                                        return;
                                      }
                                      final body = {
                                        "jobTitle": jobTitleController.text,
                                        "minSalary": double.parse(
                                          minSalaryController.text,
                                        ),
                                        "maxSalary": double.parse(
                                          maxSalaryController.text,
                                        ),
                                        "description":
                                            descriptionController.text,
                                      };
                                      if (isEdit) {
                                        jobsNotifier.updateJob(
                                          jobId: job?.id ?? "",

                                          body: body,
                                          onSuccess: () {
                                            context.goNamed('jobs');
                                          },
                                        );
                                        return;
                                      }
                                      jobsNotifier.createJob(
                                        body: body,
                                        onSuccess: () {
                                          context.goNamed('jobs');
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
