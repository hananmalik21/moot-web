import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/build_drop_down.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/provider/business_unit_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart' show DepartmentsProvider;
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/provider/users_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/provider/grades_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/provider/jobs_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/provider/position_provider.dart';

class CreateUserView extends ConsumerStatefulWidget {
  const CreateUserView({super.key});

  @override
  ConsumerState<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends ConsumerState<CreateUserView> {
  // ===== State =====
  bool isEdit = false;
  User? user;

  // ===== Simple, explicit controllers (autocompletion-friendly) =====
  final firstNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();
  final phoneC = TextEditingController();
  final designationC = TextEditingController();
  final departmentC = TextEditingController();
  final managerC = TextEditingController();
  final jobC = TextEditingController();
  final gradeC = TextEditingController();
  final positionC = TextEditingController();
  final salaryC = TextEditingController();
  final commissionC = TextEditingController();
  final companyC = TextEditingController();
  final businessUnitC = TextEditingController();

  // Providers
  final departmentsProvider =
      ChangeNotifierProvider.autoDispose<DepartmentsProvider>(
        (ref) => DepartmentsProvider(),
      );
  final jobsProvider = ChangeNotifierProvider.autoDispose<JobsProvider>(
    (ref) => JobsProvider(),
  );
  final gradeProvider = ChangeNotifierProvider.autoDispose<GradeProvider>(
    (ref) => GradeProvider(),
  );
  final positionProvider = ChangeNotifierProvider.autoDispose<PositionProvider>(
    (ref) => PositionProvider(),
  );
  final usersProvider = ChangeNotifierProvider.autoDispose<UserProvider>(
    (ref) => UserProvider(),
  );
  final _businessUnitProvider =
      ChangeNotifierProvider.autoDispose<BusinessUnitProvider>(
        (ref) => BusinessUnitProvider(),
      );
  final _companyProvider = ChangeNotifierProvider.autoDispose<CompanyProvider>(
    (ref) => CompanyProvider(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeUserData());
  }

  Future<void> _initializeUserData() async {
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    user = extra?['user'] as User?;
    isEdit = user != null;

    firstNameC.text = user?.firstName ?? '';
    lastNameC.text = user?.lastName ?? '';
    emailC.text = user?.email ?? '';
    phoneC.text = user?.phoneNumber ?? '';
    designationC.text = user?.designation ?? '';
    salaryC.text = (user?.salary ?? '').toString();
    commissionC.text = (user?.commissionPct ?? '').toString();

    await Future.wait([
      ref
          .read(jobsProvider)
          .getJobs(
            jobId: user?.job?.id,
            onSuccess: () {
              jobC.text = ref.read(jobsProvider).selectedJob?.jobTitle ?? '';
            },
          ),
      ref
          .read(usersProvider)
          .getUsers(
            userId: user?.manager?.id,
            onSuccess: () {
              final m = ref.read(usersProvider).manager;
              managerC.text = '${m?.firstName ?? ''} ${m?.lastName ?? ''}';
            },
          ),
      ref
          .read(gradeProvider)
          .getGrades(
            gradeId: user?.grade?.id,
            onSuccess: () {
              gradeC.text =
                  ref.read(gradeProvider).selectedGrade?.gradeName ?? '';
            },
          ),
      // ref.read(positionProvider).getPositions(
      //   positionId: user?.position?.id,
      //   onSuccess: () {
      //     positionC.text = ref.read(positionProvider).selectedPosition?.positionTitle ?? '';
      //   },
      // ),
      _prefetchCompanyAndBusinessUnit(),
    ]);
  }

  Future<void> _prefetchCompanyAndBusinessUnit() async {
    final companies = ref.read(_companyProvider);
    final bu = ref.read(_businessUnitProvider);
    final dept = ref.read(departmentsProvider);

    await companies.getCompanies(
      companyId: user?.company?.id,
      onSuccess: () async {
        if (user?.company == null) return;

        companies.setCompany(
          Company(
            id: user!.company!.id,
            companyName: user!.company!.companyName,
          ),
        );

        await bu.getBusinessUnits(
          companyId: companies.selectedCompany?.id,
          businessUnitId: user?.businessUnit?.id,
          onSuccess: () {
            businessUnitC
              ..clear()
              ..text = bu.selectedBusinessUnit?.businessUnitName ?? '';
          },
        );
        companyC.text = companies.selectedCompany?.companyName ?? '';

        await dept.getDepartments(
          businessUnitId: user?.businessUnit?.id,
          departmentId: user?.department?.id,
          onSuccess: () {
            departmentC
              ..clear()
              ..text = dept.selectedDepartment?.departmentName ?? '';
          },
        );
        ref
            .read(positionProvider)
            .getPositions(
              departmentId: user?.department?.id,
              positionId: user?.position?.id,
              onSuccess: () {
                positionC.text =
                    ref
                        .read(positionProvider)
                        .selectedPosition
                        ?.positionTitle ??
                    '';
              },
            );
      },
    );
  }

  // ===== Reusable builders =====

  InputFieldWidget _labeledInput(
    String title,
    TextEditingController c, {
    String? hint,
  }) {
    return InputFieldWidget(
      title: title,
      hint: hint ?? 'Enter ${title.toLowerCase()}',
      controller: c,
    );
  }

  BuildDropdown<T> _buildDropdown<T>({
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
      showSearch: false,
      onPagination: (val) {},
      searchLoading: false,
      searchHint: '',
      searchController: TextEditingController(),
      options: options,
      onSearch: (val) {},
      padding: EdgeInsets.zero,
    );
  }

  Widget _employeeInfoWide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee Information',
          style: context.text20SemiBold

        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _labeledInput(
                'First Name*',
                firstNameC,
                hint: 'Enter first name',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledInput(
                'Last Name*',
                lastNameC,
                hint: 'Enter last name',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _labeledInput('Email*', emailC, hint: 'Enter email'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledInput('Phone no*', phoneC, hint: 'Enter no'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _labeledInput(
                'Designation*',
                designationC,
                hint: 'Enter designation',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputFieldWidget(
                title: "Salary",
                hint: 'Enter salary',
                controller: salaryC,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _labeledInput('Commission PCT', commissionC, hint: 'Enter commission'),
        if (!isEdit)
          Row(
            children: [
              Expanded(
                child: _labeledInput(
                  'Password*',
                  passwordC,
                  hint: 'Enter password',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _labeledInput(
                  'Confirm Password*',
                  confirmPasswordC,
                  hint: 'Enter password',
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _employeeInfoNarrow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee Information',
          style: context.text20SemiBold,
        ),
        const SizedBox(height: 16),
        _labeledInput('First Name*', firstNameC, hint: 'Enter first name'),
        const SizedBox(height: 12),
        _labeledInput('Last Name*', lastNameC, hint: 'Enter last name'),
        const SizedBox(height: 12),
        _labeledInput('Email*', emailC, hint: 'Enter email'),
        const SizedBox(height: 12),
        _labeledInput('Phone no*', phoneC, hint: 'Enter no'),
        const SizedBox(height: 12),
        _labeledInput('Designation*', designationC, hint: 'Enter designation'),
        const SizedBox(height: 12),
        InputFieldWidget(
          title: "Salary",
          hint: 'Enter salary',
          controller: salaryC,
        ),
        const SizedBox(height: 12),
        if (!isEdit) ...[
          _labeledInput('Password*', passwordC, hint: 'Enter password'),
          const SizedBox(height: 12),
          _labeledInput(
            'Confirm Password*',
            confirmPasswordC,
            hint: 'Enter password',
          ),
        ],
        const SizedBox(height: 12),
        _labeledInput('Commission PCT', commissionC, hint: 'Enter commission'),
      ],
    );
  }

  Widget _userAccountWide(BuildContext context) {
    final jobsNotifier = ref.watch(jobsProvider);
    final gradesNotifier = ref.watch(gradeProvider);
    final positionNotifier = ref.watch(positionProvider);
    final departmentNotifier = ref.watch(departmentsProvider);
    final usersNotifier = ref.watch(usersProvider);
    final companyNotifier = ref.watch(_companyProvider);
    final businessUnitNotifier = ref.watch(_businessUnitProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'User Account Information',
          style: context.text20SemiBold,
        ),
        const SizedBox(height: 16),

        _buildDropdown<Company>(
          controller: companyC,
          title: 'Company',
          label: 'Choose company',
          options: companyNotifier.companies,
          displayField: (c) => c.companyName,
          onChange: (val) async {
            companyNotifier.setCompany(val);
            departmentC.clear();
            positionC.clear();
            positionNotifier.setPosition(null);
            departmentNotifier.setDepartment(null);
            positionNotifier.clearList();
            departmentNotifier.clearList();

            await businessUnitNotifier.getBusinessUnits(
              companyId: companyNotifier.selectedCompany?.id,
              onSuccess: () {
                businessUnitC
                  ..clear()
                  ..text =
                      ref
                          .read(_businessUnitProvider)
                          .selectedBusinessUnit
                          ?.businessUnitName ??
                      '';
              },
            );

            companyC.text = companyNotifier.selectedCompany?.companyName ?? '';
          },
        ),

        _buildDropdown<BusinessUnit>(
          controller: businessUnitC,
          title: 'Business Unit',
          label: 'Select business unit',
          options: businessUnitNotifier.businessUnits,
          displayField: (b) => b.businessUnitName,
          onChange: (val) async {
            businessUnitNotifier.setBusinessUnit(val);
            await departmentNotifier.getDepartments(
              businessUnitId: businessUnitNotifier.selectedBusinessUnit?.id,
              onSuccess: () {
                departmentC
                  ..clear()
                  ..text =
                      departmentNotifier.selectedDepartment?.departmentName ??
                      '';
              },
            );
          },
        ),

        _buildDropdown<Department>(
          controller: departmentC,
          title: 'Department',
          label: 'Select department',
          options: departmentNotifier.departments,
          displayField: (d) => d.departmentName,
          onChange: (val) async {
            departmentNotifier.setDepartment(val);

            await positionNotifier.getPositions(
              departmentId: departmentNotifier.selectedDepartment?.id,
              onSuccess: () {
                positionC
                  ..clear()
                  ..text =
                      positionNotifier.selectedPosition?.positionTitle ?? '';
              },
            );
          },
        ),
        _buildDropdown(
          controller: positionC,
          title: 'Position',
          label: 'Select position',
          options: positionNotifier.positions,
          displayField: (p) => p.positionTitle,
          onChange: positionNotifier.setPosition,
        ),

        _buildDropdown<User>(
          controller: managerC,
          title: 'Manager',
          label: 'Select manager',
          options: usersNotifier.users,
          displayField: (u) => '${u.firstName} ${u.lastName}',
          onChange: usersNotifier.setManager,
        ),

        _buildDropdown(
          controller: jobC,
          title: 'Job',
          label: 'Select job',
          options: jobsNotifier.jobs,
          displayField: (j) => j.jobTitle,
          onChange: jobsNotifier.setJob,
        ),

        _buildDropdown(
          controller: gradeC,
          title: 'Grade',
          label: 'Select grade',
          options: gradesNotifier.grades,
          displayField: (g) => g.gradeName,
          onChange: gradesNotifier.setGrade,
        ),
      ],
    );
  }

  Widget _userAccountNarrow(BuildContext context) {
    final jobsNotifier = ref.watch(jobsProvider);
    final gradesNotifier = ref.watch(gradeProvider);
    final positionNotifier = ref.watch(positionProvider);
    final departmentNotifier = ref.watch(departmentsProvider);
    final usersNotifier = ref.watch(usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'User Account Information',
          style: context.text20SemiBold.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          controller: departmentC,
          title: 'Department',
          label: 'Select department',
          options: departmentNotifier.departments,
          displayField: (d) => d.departmentName,
          onChange: departmentNotifier.setDepartment,
        ),
        _buildDropdown<User>(
          controller: managerC,
          title: 'Employee Manager',
          label: 'Select manager',
          options: usersNotifier.users,
          displayField: (u) => '${u.firstName} ${u.lastName}',
          onChange: usersNotifier.setManager,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          controller: jobC,
          title: 'Job',
          label: 'Select job',
          options: jobsNotifier.jobs,
          displayField: (j) => j.jobTitle,
          onChange: jobsNotifier.setJob,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          controller: gradeC,
          title: 'Grade',
          label: 'Select grade',
          options: gradesNotifier.grades,
          displayField: (g) => g.gradeName,
          onChange: gradesNotifier.setGrade,
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          controller: positionC,
          title: 'Position',
          label: 'Select position',
          options: positionNotifier.positions,
          displayField: (p) => p.positionTitle,
          onChange: positionNotifier.setPosition,
        ),
      ],
    );
  }

  void _onSubmit() {
    final jobsNotifier = ref.watch(jobsProvider);
    final gradesNotifier = ref.watch(gradeProvider);
    final positionNotifier = ref.watch(positionProvider);
    final departmentNotifier = ref.watch(departmentsProvider);
    final usersNotifier = ref.watch(usersProvider);

    if (!isEdit) {
      if (passwordC.text.isEmpty || confirmPasswordC.text.isEmpty) {
        Utils().showToast('Please enter both password and confirm password');
        return;
      }
      if (passwordC.text != confirmPasswordC.text) {
        Utils().showToast('Password does not match confirm password');
        return;
      }
    }

    final body = <String, dynamic>{
      'firstName': firstNameC.text,
      'lastName': lastNameC.text,
      'email': emailC.text,
      'phoneNumber': phoneC.text,
      'designation': designationC.text,
      if (departmentNotifier.selectedDepartment != null)
        'departmentId': departmentNotifier.selectedDepartment?.id,
      if (jobsNotifier.selectedJob != null) 'job': jobsNotifier.selectedJob?.id,
      if (positionNotifier.selectedPosition != null)
        'position': positionNotifier.selectedPosition?.id,
      if (gradesNotifier.selectedGrade != null)
        'grade': gradesNotifier.selectedGrade?.id,
      'salary': salaryC.text.isEmpty ? null : double.parse(salaryC.text),
      if (commissionC.text.isNotEmpty)
        'commissionPct': double.parse(commissionC.text),
      if (usersNotifier.manager != null) 'manager': usersNotifier.manager?.id,
    };

    if (isEdit) {
      usersNotifier.updateUser(
        userId: user?.id ?? '',
        email: emailC.text,
        body: body,
        onSuccess: () => context.goNamed('users'),
      );
      return;
    }

    usersNotifier.registerUser(
      email: emailC.text,
      body: {...body, 'password': passwordC.text},
      onSuccess: () => context.goNamed('users'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsNotifier = ref.watch(jobsProvider);
    final gradesNotifier = ref.watch(gradeProvider);
    final positionNotifier = ref.watch(positionProvider);
    final departmentNotifier = ref.watch(departmentsProvider);
    final usersNotifier = ref.watch(usersProvider);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall:
            jobsNotifier.isLoading ||
            usersNotifier.isLoading ||
            gradesNotifier.isLoading ||
            departmentNotifier.isLoading ||
            positionNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, outerConstraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isWide = constraints.maxWidth >= 800;

                          final formContent = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isWide
                                  ? _employeeInfoWide(context)
                                  : _employeeInfoNarrow(context),
                              isWide
                                  ? _userAccountWide(context)
                                  : _userAccountNarrow(context),
                            ],
                          );

                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1000,
                              ),
                              child: FormContainer(
                                constraints: constraints,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Text(
                                                isEdit
                                                    ? 'Edit User'
                                                    : 'Create User',
                                                style: context.text20SemiBold
                                                    .copyWith(
                                                      color: Colors.white70,
                                                    ),
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.white24,
                                            ),
                                            20.verticalSpace,
                                            formContent,
                                            const SizedBox(height: 24),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: customUploadBtnWidget(
                                        isLoading: usersNotifier.isLoading,
                                        onTap: _onSubmit,
                                        text: isEdit ? 'Edit' : 'Create',
                                        context: context,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
