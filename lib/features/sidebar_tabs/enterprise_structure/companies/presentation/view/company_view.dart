import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';
import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

// ✅ Permission guard + current user
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';

import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/provider/company_provider.dart';

class CompanyView extends ConsumerStatefulWidget {
  const CompanyView({super.key});

  @override
  ConsumerState<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends ConsumerState<CompanyView> {
  final companyProvider = ChangeNotifierProvider.autoDispose<CompanyProvider>(
    (ref) => CompanyProvider(),
  );

  late final PermissionGuard _guard;

  // ── Permissions: enterprise_structure.company.*  or enterprise_structure.* (no security.*) ──
  bool get _canCreateCompany =>
      _guard.allows('enterprise_structure.company.create') ||
      _guard.allows('enterprise_structure.company.*') ||
      _guard.allows('enterprise_structure.*');

  bool get _canUpdateCompany =>
      _guard.allows('enterprise_structure.company.update') ||
      _guard.allows('enterprise_structure.company.*') ||
      _guard.allows('enterprise_structure.*');

  bool get _canDeleteCompany =>
      _guard.allows('enterprise_structure.company.delete') ||
      _guard.allows('enterprise_structure.company.*') ||
      _guard.allows('enterprise_structure.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider).getCompanies();
      final perms =
          (ref.read(userDataProvider).user?.user.permissions ?? const <String>[])
              .toList();
      setState(() {
        _guard = PermissionGuard(perms);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(companyProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final hasActions = _canUpdateCompany || _canDeleteCompany;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Companies"),
              20.verticalSpace,

              if (_canCreateCompany)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-company"),
                  title: "Add Company",
                ),

              20.verticalSpace,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: CustomDataTable(
                    emptyMessage: 'No Company found',
                    headerColor: context.primaryColor,
                    onRowTap: (index){
                      context.goNamed(
                        'company-detail',
                        pathParameters: {"id": notifier.companies[index].id},
                        extra: {"role": notifier.companies[index]},
                      );
                    },
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Company')),
                      const DataColumn(label: Text('Description')),
                      const DataColumn(label: Text('Address')),
                      const DataColumn(label: Text('Active')),
                      const DataColumn(label: Text('Created Date')),
                      if (hasActions) const DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(notifier.companies.length, (
                      index,
                    ) {
                      final company = notifier.companies[index];
                      final isEven = index.isEven;

                      final createdText = company.createdAt != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(company.createdAt!)
                          : '—';

                      final cells = <DataCell>[
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(company.companyName)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Text(company.description ?? ""),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Text(company.address ?? ""),
                          ),
                        ),
                        DataCell(Text((company.isActive).toString())),
                        DataCell(Text(createdText)),
                      ];

                      if (hasActions) {
                        cells.add(
                          DataCell(
                            Row(
                              children: [
                                if (_canUpdateCompany)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Edit',
                                    onPressed: () {
                                      context.goNamed(
                                        'edit-company',
                                        pathParameters: {"id": company.id},
                                        extra: {"company": company},
                                      );
                                    },
                                  ),
                                if (_canDeleteCompany)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'Delete',
                                    onPressed: () {
                                      Utils().showCustomDialog(
                                        context,
                                        DeleteDialogWidget(
                                          onClick: () => ref
                                              .read(companyProvider)
                                              .deleteCompany(
                                                companyId: company.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return DataRow(
                        color: WidgetStateProperty.all(
                          isEven
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                        ),
                        cells: cells,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
