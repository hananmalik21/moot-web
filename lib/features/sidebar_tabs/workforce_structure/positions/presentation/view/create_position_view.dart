import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/build_drop_down.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/provider/business_unit_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/provider/grades_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/provider/jobs_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/data/model/position_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/provider/position_provider.dart';

class CreatePositionView extends ConsumerStatefulWidget {
  const CreatePositionView({super.key});

  @override
  ConsumerState<CreatePositionView> createState() => _CreatePositionViewState();
}

class _CreatePositionViewState extends ConsumerState<CreatePositionView> {
  // ---- State ----
  bool _isEdit = false;
  Position? _position;

  // ---- Controllers ----
  final TextEditingController _positionTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _businessUnitController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  // ---- Providers ----
  final _departmentsProvider =
  ChangeNotifierProvider.autoDispose<DepartmentsProvider>((ref) => DepartmentsProvider());
  final _gradeProvider =
  ChangeNotifierProvider.autoDispose<GradeProvider>((ref) => GradeProvider());
  final _jobProvider =
  ChangeNotifierProvider.autoDispose<JobsProvider>((ref) => JobsProvider());
  final _positionProvider =
  ChangeNotifierProvider.autoDispose<PositionProvider>((ref) => PositionProvider());
  final _businessUnitProvider =
  ChangeNotifierProvider.autoDispose<BusinessUnitProvider>((ref) => BusinessUnitProvider());
  final _companyProvider =
  ChangeNotifierProvider.autoDispose<CompanyProvider>((ref) => CompanyProvider());

  // ---------- Lifecycle ----------
  @override
  void initState() {
    super.initState();
    _initFromRoute();
    _initControllersFromPosition();

    // Keep the loading sequence identical to original timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapData(); // fire-and-forget Future.wait inside
    });
  }

  @override
  void dispose() {
    _positionTitleController.dispose();
    _departmentController.dispose();
    _businessUnitController.dispose();
    _companyController.dispose();
    _jobController.dispose();
    _gradeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  // ---------- Init helpers ----------
  void _initFromRoute() {
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    _position = extra?['position'] as Position?;
    _isEdit = _position != null;
  }

  void _initControllersFromPosition() {
    _positionTitleController.text = _position?.positionTitle ?? '';
    _statusController.text = _position?.positionStatus ?? '';
  }

  Future<void> _bootstrapData() async {
    await Future.wait([
      _hydrateJobs(),
      _hydrateGrades(),
      _prefetchCompanyAndBusinessUnit(),
      // Department prefetch remains commented exactly as in original source
      // _hydrateDepartments(),
    ]);
  }

  Future<void> _hydrateJobs() async {
    await ref.read(_jobProvider).getJobs(onSuccess: () {
      ref.read(_positionProvider).setJob(
        _position?.job,
        jobs: ref.read(_jobProvider).jobs,
      );
      _jobController.text = ref.read(_positionProvider).selectedJob?.jobTitle ?? '';
    });
  }

  Future<void> _hydrateGrades() async {
    await ref.read(_gradeProvider).getGrades(onSuccess: () {
      ref.read(_positionProvider).setGrade(
        _position?.grade,
        grades: ref.read(_gradeProvider).grades,
      );
      _gradeController.text = ref.read(_positionProvider).selectedGrade?.gradeName ?? '';
    });
  }

  Future<void> _prefetchCompanyAndBusinessUnit() async {
    final companies = ref.read(_companyProvider);
    final bu = ref.read(_businessUnitProvider);
    final dept = ref.read(_departmentsProvider);

    await companies.getCompanies(
      companyId: _position?.company?.id,
      onSuccess: () async {
        if (_position?.company != null) {
          companies.setCompany(_position?.company);
          await bu.getBusinessUnits(
            companyId: companies.selectedCompany?.id,
            businessUnitId: _position?.businessUnit?.id,
            onSuccess: () {
              _businessUnitController.text = bu.selectedBusinessUnit?.businessUnitName ?? '';
            },
          );
          _companyController.text = companies.selectedCompany?.companyName ?? '';
          await dept.getDepartments(
            businessUnitId: _position?.businessUnit?.id,
            departmentId: _position?.department?.id,
            onSuccess: () {
              _departmentController.text = dept.selectedDepartment?.departmentName ?? '';
            },
          );
        }
      },
    );
  }

  // ---------- UI helpers ----------
  Widget _dropdown<T>({
    required TextEditingController controller,
    required String title,
    required String label,
    required List<T> options,
    required String Function(T) displayField,
    required void Function(T) onChange,
  }) {
    return BuildDropdown<T>(
      controller: controller,
      displayField: displayField,
      onChange: onChange,
      title: title,
      label: label,
      isLoadingMore: false,
      onPagination: (_) {},
      searchLoading: false,
      showSearch: false,
      searchHint: "",
      searchController: TextEditingController(),
      options: options,
      onSearch: (_) {},
    );
  }

  void _submit({
    required PositionProvider positionNotifier,
    required CompanyProvider companyNotifier,
    required BusinessUnitProvider businessUnitNotifier,
    required DepartmentsProvider departmentNotifier,
  }) {
    if (_positionTitleController.text.isEmpty) {
      Utils().showToast("Please enter title");
      return;
    }
    if (companyNotifier.selectedCompany == null) {
      Utils().showToast("Please choose company");
      return;
    }
    if (businessUnitNotifier.selectedBusinessUnit == null) {
      Utils().showToast("Please choose business unit");
      return;
    }
    if (departmentNotifier.selectedDepartment == null) {
      Utils().showToast("Please choose department");
      return;
    }

    final body = {
      "positionTitle": _positionTitleController.text,
      "job": positionNotifier.selectedJob?.id,
      "grade": positionNotifier.selectedGrade?.id,
      "department": departmentNotifier.selectedDepartment?.id,
      "positionStatus": _statusController.text.toUpperCase(),
    };

    if (_isEdit) {
      positionNotifier.updatePosition(
        jobId: _position?.id ?? "",
        body: body,
        onSuccess: () => context.goNamed('positions'),
      );
      return;
    }

    positionNotifier.createPosition(
      body: body,
      onSuccess: () => context.goNamed('positions'),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final gradeNotifier = ref.watch(_gradeProvider);
    final positionNotifier = ref.watch(_positionProvider);
    final jobNotifier = ref.watch(_jobProvider);
    final departmentNotifier = ref.watch(_departmentsProvider);
    final companyNotifier = ref.watch(_companyProvider);
    final businessUnitNotifier = ref.watch(_businessUnitProvider);

    final isBusy = gradeNotifier.isLoading ||
        positionNotifier.isLoading ||
        jobNotifier.isLoading ||
        companyNotifier.isLoading ||
        businessUnitNotifier.isLoading ||
        departmentNotifier.isLoading;

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isBusy,
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
                            // Scrollable content
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      _isEdit ? "Edit Position" : 'Create Position',
                                      style: context.text20SemiBold,
                                    ),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,

                                    InputFieldWidget(
                                      title: "Position Title",
                                      hint: "Enter position",
                                      controller: _positionTitleController,
                                    ),
                                    20.verticalSpace,

                                    // Company
                                    _dropdown(
                                      controller: _companyController,
                                      title: "Company",
                                      label: "Choose company",
                                      options: companyNotifier.companies,
                                      displayField: (val) => val.companyName,
                                      onChange: (val) async {
                                        companyNotifier.setCompany(val);

                                        // reset department selection when company changes (kept as-is)
                                        _departmentController.clear();
                                        // preserve existing calls
                                        departmentNotifier.setDepartment(null);
                                        departmentNotifier.clearList();

                                        await businessUnitNotifier.getBusinessUnits(
                                          companyId: companyNotifier.selectedCompany?.id,
                                          onSuccess: () {
                                            _businessUnitController.clear();
                                            _businessUnitController.text = ref
                                                .read(_businessUnitProvider)
                                                .selectedBusinessUnit
                                                ?.businessUnitName ??
                                                "";
                                          },
                                        );
                                      },
                                    ),

                                    // Business Unit
                                    _dropdown(
                                      controller: _businessUnitController,
                                      title: "Business Unit",
                                      label: "Choose business unit",
                                      options: businessUnitNotifier.businessUnits,
                                      displayField: (val) => val.businessUnitName,
                                      onChange: (val) async {
                                        businessUnitNotifier.setBusinessUnit(val);
                                        await departmentNotifier.getDepartments(
                                          businessUnitId:
                                          businessUnitNotifier.selectedBusinessUnit?.id,
                                          onSuccess: () {
                                            _departmentController.clear();
                                            _departmentController.text = departmentNotifier
                                                .selectedDepartment
                                                ?.departmentName ??
                                                "";
                                          },
                                        );
                                      },
                                    ),

                                    // Department
                                    _dropdown(
                                      controller: _departmentController,
                                      title: "Department",
                                      label: "Select department",
                                      options: departmentNotifier.departments,
                                      displayField: (val) => val.departmentName,
                                      onChange: (val) => departmentNotifier.setDepartment(val),
                                    ),

                                    // Job
                                    _dropdown(
                                      controller: _jobController,
                                      title: "Job",
                                      label: "Select job",
                                      options: jobNotifier.jobs,
                                      displayField: (val) => val.jobTitle,
                                      onChange: (val) => positionNotifier.setJob(val),
                                    ),

                                    // Grade
                                    _dropdown(
                                      controller: _gradeController,
                                      title: "Grade",
                                      label: "Select grade",
                                      options: gradeNotifier.grades,
                                      displayField: (val) => val.gradeName,
                                      onChange: (val) => positionNotifier.setGrade(val),
                                    ),

                                    // Status
                                    _dropdown<String>(
                                      controller: _statusController,
                                      title: "Status",
                                      label: "Select status",
                                      options: const ["Active", "Inactive"],
                                      displayField: (val) => val,
                                      onChange: (_) {},
                                    ),

                                    20.verticalSpace,
                                  ],
                                ),
                              ),
                            ),

                            // Static footer
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: customUploadBtnWidget(
                                    isLoading: positionNotifier.isLoading,
                                    onTap: () => _submit(
                                      positionNotifier: positionNotifier,
                                      companyNotifier: companyNotifier,
                                      businessUnitNotifier: businessUnitNotifier,
                                      departmentNotifier: departmentNotifier,
                                    ),
                                    text: _isEdit ? "Edit" : "Create",
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
