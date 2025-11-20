import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';

// 🧊 Glass header
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;
import 'package:moot_web/features/common_widgets/permission_chip.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/provider/role_provider.dart';

class RoleDetailPage extends ConsumerStatefulWidget {
  const RoleDetailPage({super.key});

  @override
  ConsumerState<RoleDetailPage> createState() => _RoleDetailPageState();
}

class _RoleDetailPageState extends ConsumerState<RoleDetailPage> {
  // 🔁 Auto-dispose Roles provider
  final rolesProvider = ChangeNotifierProvider.autoDispose<RoleProvider>(
    (ref) => RoleProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint(
        "role id is ${GoRouter.of(context).state.pathParameters['id']}",
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Adjust this method name according to your RolesProvider
      ref.read(rolesProvider).getRoles(roleId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleNotifier = ref.watch(rolesProvider);

    // 🔁 Adjust `selectedRole` to whatever your provider exposes
    final Role? role = roleNotifier.selectedRole;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: roleNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(
              context,
              isMobile,
              role?.name ?? "Role Detail",
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
                          // 🧊 ROLE SUMMARY CARD
                          SizedBox(
                            width: cardWidth,
                            child: NeumorphicCard(
                              child: Padding(
                                padding: EdgeInsets.all(18.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                role?.name ?? "-",
                                                style: context.text20SemiBold
                                                    .copyWith(
                                                      color:
                                                          context.primaryColor,
                                                    ),
                                              ),
                                              8.verticalSpace,
                                              Text(
                                                role?.description ??
                                                    "No description provided",
                                                style: context.text14Regular,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (role?.isSystemRole ?? false)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: context.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              "SYSTEM ROLE",
                                              style: context.text12SemiBold
                                                  .copyWith(
                                                    color: context.primaryColor,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 📋 ROLE INFO SECTION
                          SizedBox(
                            width: cardWidth,
                            child: DynamicInfoSection(
                              title: "Role Information",
                              items: [
                                InfoItem(label: "Role Name", value: role?.name),
                                InfoItem(
                                  label: "Description",
                                  value: role?.description,
                                ),
                                InfoItem(
                                  label: "System Role",
                                  value: (role?.isSystemRole ?? false)
                                      ? "Yes"
                                      : "No",
                                ),
                                InfoItem(
                                  label: "Total Permissions",
                                  value: (role?.permissions.length ?? 0)
                                      .toString(),
                                ),
                              ],
                            ),
                          ),

                          // 🧱 PERMISSIONS GRID
                          SizedBox(
                            width: fullWidth, // take full width for grid
                            child: NeumorphicCard(
                              child: Padding(
                                padding: EdgeInsets.all(18.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Permissions",
                                      style: context.text18SemiBold.copyWith(
                                        color: context.primaryColor,
                                      ),
                                    ),
                                    12.verticalSpace,
                                    if (role == null ||
                                        role.permissions.isEmpty)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20.h,
                                        ),
                                        child: Text(
                                          "No permissions assigned to this role.",
                                          style: context.text14Regular,
                                        ),
                                      )
                                    else
                                      LayoutBuilder(
                                        builder: (context, gridConstraints) {
                                          final maxWidth =
                                              gridConstraints.maxWidth;

                                          // 🔢 Responsive columns
                                          int crossAxisCount = 4;
                                          if (maxWidth < 500) {
                                            crossAxisCount = 1;
                                          } else if (maxWidth < 800) {
                                            crossAxisCount = 2;
                                          } else if (maxWidth < 1100) {
                                            crossAxisCount = 3;
                                          }

                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),

                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      crossAxisCount,
                                                  mainAxisSpacing: 10,
                                                  crossAxisSpacing: 10,
                                                  mainAxisExtent:
                                                      38, // 🔥 forces smaller height
                                                ),
                                            itemCount: role.permissions.length,
                                            itemBuilder: (context, index) {
                                              final permission =
                                                  role.permissions[index];

                                              return PermissionChip(
                                                permission: permission,
                                                enableShadow: true,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                  ],
                                ),
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
