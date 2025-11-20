import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/model/user_data_model.dart';

// 🔤 Text styles extension
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

// 🧊 Glass header
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/provider/users_provider.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/view/widgets/user_info_widget.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({super.key});

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  final usersProvider = ChangeNotifierProvider.autoDispose<UserProvider>(
    (ref) => UserProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];
    if (kDebugMode) {
      debugPrint(
        "user id is ${GoRouter.of(context).state.pathParameters['id']}",
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider).getUsers(userId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.watch(usersProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: userNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(
              context,
              isMobile,
              "${userNotifier.manager?.firstName??""} ${userNotifier.manager?.lastName??""}",
              showButtons: false,
            ),

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
                          SizedBox(
                            width: cardWidth,
                            child: SizedBox(
                              // height: cardHeight,
                              child: NeumorphicCard(
                                child: UserInfoSection(
                                  user:
                                      userNotifier.manager ?? User.fromJson({}),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: DynamicInfoSection(
                              title: "User Account Information",
                              items: [
                                InfoItem(label: "Employee No", value: userNotifier.manager?.employeeId),
                                InfoItem(label: "Company", value: userNotifier.manager?.company?.companyName),
                                InfoItem(label: "Business Unit", value: userNotifier.manager?.businessUnit?.businessUnitName),
                                InfoItem(label: "Department", value: userNotifier.manager?.department?.departmentName),
                                InfoItem(label: "Job", value: userNotifier.manager?.job?.jobTitle),
                                InfoItem(label: "Grade", value: userNotifier.manager?.grade?.gradeName),
                                InfoItem(label: "Position", value: userNotifier.manager?.position?.positionTitle),
                              ],
                            )
                          ),
                          30.verticalSpace,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: CustomDataTable(
                              emptyMessage: 'No roles found',
                              headerColor: context.primaryColor,
                              columns: [
                                const DataColumn(label: Text('#')),
                                const DataColumn(label: Text('Role Name')),
                                const DataColumn(
                                  label: Text('Department Name'),
                                ),
                              ],
                              rows: List<DataRow>.generate(
                                (userNotifier.manager?.effectiveUserRoles ?? [])
                                    .length,
                                (index) {
                                  final role = userNotifier
                                      .manager
                                      ?.effectiveUserRoles[index];
                                  final isEven = index.isEven;

                                  final cells = <DataCell>[
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(role?.role.name ?? "")),
                                    DataCell(
                                      Text(
                                        role?.department?.departmentName ?? "",
                                      ),
                                    ),
                                  ];

                                  return DataRow(
                                    color: WidgetStateProperty.all(
                                      isEven
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.05),
                                    ),
                                    cells: cells,
                                  );
                                },
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
