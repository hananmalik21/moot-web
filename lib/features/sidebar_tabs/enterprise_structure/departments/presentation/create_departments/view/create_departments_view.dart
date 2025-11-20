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
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/provider/departments_provider.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/provider/users_provider.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/provider/locations_provider.dart';

class CreateDepartmentsView extends ConsumerStatefulWidget {
  const CreateDepartmentsView({super.key});

  @override
  ConsumerState<CreateDepartmentsView> createState() => _DepartmentsViewState();
}

class _DepartmentsViewState extends ConsumerState<CreateDepartmentsView> {
  // State
  bool _isEdit = false;
  Department? _department;

  // Controllers
  final TextEditingController _departmentNameController = TextEditingController();
  final TextEditingController _managerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _businessUnitController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  // Providers
  final _departmentsProvider =
  ChangeNotifierProvider.autoDispose<DepartmentsProvider>((ref) => DepartmentsProvider());
  final _locationsProvider =
  ChangeNotifierProvider.autoDispose<LocationsProvider>((ref) => LocationsProvider());
  final _usersProvider =
  ChangeNotifierProvider.autoDispose<UserProvider>((ref) => UserProvider());
  final _businessUnitProvider =
  ChangeNotifierProvider.autoDispose<BusinessUnitProvider>((ref) => BusinessUnitProvider());
  final _companyProvider =
  ChangeNotifierProvider.autoDispose<CompanyProvider>((ref) => CompanyProvider());

  @override
  void initState() {
    super.initState();
    _readRouteExtra();
    _departmentNameController.text = _department?.departmentName ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        _prefetchLocations(),
        _prefetchUsers(),
        _prefetchCompanyAndBusinessUnit(),
      ]);
    });
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _businessUnitController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  // ---- Setup helpers ----

  void _readRouteExtra() {
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    _department = extra?['department'] as Department?;
    _isEdit = _department != null;
  }

  Future<void> _prefetchLocations() async {
    final loc = ref.read(_locationsProvider);
    await loc.getLocations(
      locationId: _department?.location?.id,
      onSuccess: () {
        final selected = ref.read(_locationsProvider).selectedLocation;
        _locationController.text = "${selected?.streetAddress ?? ""} ${selected?.city ?? ""}";
      },
    );
  }

  Future<void> _prefetchUsers() async {
    final users = ref.read(_usersProvider);
    await users.getUsers(
      userId: _department?.manager?.id,
      onSuccess: () {
        _managerController.text =
        "${_department?.manager?.firstName ?? ""} ${_department?.manager?.lastName ?? ""}";
      },
    );
  }

  Future<void> _prefetchCompanyAndBusinessUnit() async {
    final companies = ref.read(_companyProvider);
    final bu = ref.read(_businessUnitProvider);

    await companies.getCompanies(
      companyId: _department?.company?.id,
      onSuccess: () async {
        companies.setCompany(_department?.company);
        if(_department?.company!=null){
          await bu.getBusinessUnits(
            companyId: companies.selectedCompany?.id,
            businessUnitId: _department?.businessUnit?.id,
            onSuccess: () {
              _businessUnitController.text = bu.selectedBusinessUnit?.businessUnitName ?? "";
            },
          );
          _companyController.text = companies.selectedCompany?.companyName ?? "";
        }

      },
    );
  }

  // ---- UI helpers ----

  Widget _buildTitle(BuildContext context) {
    return Text(
      _isEdit ? "Edit Department" : 'Create Department',
      style: context.text20SemiBold,
    );
  }

  Widget _buildDepartmentName() {
    return InputFieldWidget(
      title: "Department Name",
      hint: "Enter name",
      controller: _departmentNameController,
    );
  }

  // Generic dropdown builder to keep identical visuals/behavior
  Widget _buildDropdown<T>({
    required TextEditingController controller,
    required String title,
    required String label,
    required List<T> options,
    required String Function(T) displayField,
    required void Function(T) onChange,
    bool showSearch = false,
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
      showSearch: showSearch,
      searchHint: "",
      searchController: TextEditingController(),
      options: options,
      onSearch: (_) {},
    );
  }

  void _onSubmit({
    required DepartmentsProvider departmentNotifier,
    required LocationsProvider locationNotifier,
    required UserProvider usersNotifier,
    required CompanyProvider companyNotifier,
    required BusinessUnitProvider businessUnitNotifier,
  }) {
    if (companyNotifier.selectedCompany == null) {
      Utils().showToast("Please select company");
      return;
    }
    if (businessUnitNotifier.selectedBusinessUnit == null) {
      Utils().showToast("Please select Business unit");
      return;
    }

    if (_isEdit) {
      departmentNotifier.updateDepartment(
        departmentId: _department?.id ?? '',
        departmentName: _departmentNameController.text,
        managerId: usersNotifier.manager?.id ?? "",
        locationId: locationNotifier.selectedLocation?.id ?? "",
        companyId: companyNotifier.selectedCompany?.id ?? "",
        businessUnitId: businessUnitNotifier.selectedBusinessUnit?.id ?? "",
        onSuccess: () => context.goNamed('departments'),
      );
      return;
    }

    departmentNotifier.createDepartment(
      departmentName: _departmentNameController.text,
      managerId: usersNotifier.manager?.id ?? "",
      companyId: companyNotifier.selectedCompany?.id ?? "",
      businessUnitId: businessUnitNotifier.selectedBusinessUnit?.id ?? "",
      locationId: locationNotifier.selectedLocation?.id ?? "",
      onSuccess: () => context.goNamed('departments'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationNotifier = ref.watch(_locationsProvider);
    final usersNotifier = ref.watch(_usersProvider);
    final departmentNotifier = ref.watch(_departmentsProvider);
    final companyNotifier = ref.watch(_companyProvider);
    final businessUnitNotifier = ref.watch(_businessUnitProvider);

    final isBusy = locationNotifier.isLoading ||
        usersNotifier.isLoading ||
        companyNotifier.isLoading ||
        businessUnitNotifier.isLoading;

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
                                    _buildTitle(context),
                                    const Divider(color: Colors.white24),
                                    20.verticalSpace,
                                    _buildDepartmentName(),
                                    20.verticalSpace,

                                    // Company
                                    _buildDropdown(
                                      controller: _companyController,
                                      title: "Company",
                                      label: "Select company",
                                      options: companyNotifier.companies,
                                      displayField: (val) => val.companyName,
                                      onChange: (val) async {
                                        companyNotifier.setCompany(val);
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
                                    _buildDropdown(
                                      controller: _businessUnitController,
                                      title: "Business Unit",
                                      label: "Select business unit",
                                      options: businessUnitNotifier.businessUnits,
                                      displayField: (val) => val.businessUnitName,
                                      onChange: businessUnitNotifier.setBusinessUnit,
                                    ),

                                    // Manager
                                    _buildDropdown(
                                      controller: _managerController,
                                      title: "Manager",
                                      label: "Select manager",
                                      options: usersNotifier.users,
                                      displayField: (val) => "${val.firstName} ${val.lastName}",
                                      onChange: usersNotifier.setManager,
                                    ),

                                    // Location
                                    _buildDropdown(
                                      controller: _locationController,
                                      title: "Location",
                                      label: "Select location",
                                      options: locationNotifier.locations,
                                      displayField: (val) => "${val.streetAddress} ${val.city}",
                                      onChange: locationNotifier.setLocation,
                                      showSearch: false,
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
                                    isLoading: departmentNotifier.isLoading,
                                    onTap: () => _onSubmit(
                                      departmentNotifier: departmentNotifier,
                                      locationNotifier: locationNotifier,
                                      usersNotifier: usersNotifier,
                                      companyNotifier: companyNotifier,
                                      businessUnitNotifier: businessUnitNotifier,
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
