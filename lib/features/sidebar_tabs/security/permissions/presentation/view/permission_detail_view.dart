import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';

// 🧊 Glass header + Neumorphic
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/newmorphic_card.dart';
import 'package:moot_web/features/common_widgets/dynamic_info_section.dart'
    show InfoItem, DynamicInfoSection;

// 🔑 Permission model
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/provider/permission_provider.dart';

// 🔐 Role model (used for "All Security Roles")

class PermissionDetailPage extends ConsumerStatefulWidget {
  const PermissionDetailPage({super.key});

  @override
  ConsumerState<PermissionDetailPage> createState() =>
      _PermissionDetailPageState();
}

class _PermissionDetailPageState extends ConsumerState<PermissionDetailPage> {
  final permissionsProvider =
  ChangeNotifierProvider.autoDispose<PermissionProvider>(
        (ref) => PermissionProvider(),
  );

  @override
  void initState() {
    super.initState();

    final id = GoRouter.of(context).state.pathParameters['id'];

    if (kDebugMode) {
      debugPrint("permission id is $id");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔁 Your provider already uses this
      ref.read(permissionsProvider).getPermissions(permissionId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionNotifier = ref.watch(permissionsProvider);
    final Permission? permission = permissionNotifier.selectedPermission;

    final isMobile = MediaQuery.of(context).size.width < 600;
    final String headerTitle = permission?.label.isNotEmpty == true
        ? permission!.label
        : (permission?.key ?? "Permission Detail");

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: permissionNotifier.isLoading,
        child: Column(
          children: [
            // 🔥 Glass header
            buildGlassCover(
              context,
              isMobile,
              headerTitle,
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
                      final double cardWidth =
                      desiredWidth < 380 ? fullWidth : desiredWidth;

                      return Wrap(
                        spacing: 22.w,
                        runSpacing: 22.h,
                        alignment: WrapAlignment.center,
                        children: [
                          // 🧊 SUMMARY CARD
                          SizedBox(
                            width: cardWidth,
                            child: NeumorphicCard(
                              child: Padding(
                                padding: EdgeInsets.all(18.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      permission?.label.isNotEmpty == true
                                          ? permission!.label
                                          : (permission?.key ?? "-"),
                                      style: context.text20SemiBold.copyWith(
                                        color: context.primaryColor,
                                      ),
                                    ),
                                    8.verticalSpace,
                                    Text(
                                      permission?.key ?? "-",
                                      style: context.text14Regular.copyWith(
                                        color: context.gray99TextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ℹ️ PERMISSION INFORMATION
                          SizedBox(
                            width: cardWidth,
                            child: DynamicInfoSection(
                              title: "Permission Information",
                              items: [
                                InfoItem(
                                  label: "Label",
                                  value: permission?.label,
                                ),
                                InfoItem(
                                  label: "Key",
                                  value: permission?.key,
                                ),
                                InfoItem(
                                  label: "Group",
                                  value: permission?.group,
                                ),
                                InfoItem(
                                  label: "Module",
                                  value: permission?.module,
                                ),
                                InfoItem(
                                  label: "Active",
                                  value: (permission?.isActive ?? false)
                                      ? "Yes"
                                      : "No",
                                ),
                                InfoItem(
                                  label: "System Permission",
                                  value:
                                  (permission?.isSystemPermission ?? false)
                                      ? "Yes"
                                      : "No",
                                ),
                              ],
                            ),
                          ),

                          // 🔍 EXTRA CARD – parsed key view
                          if (permission != null)
                            SizedBox(
                              width: fullWidth,
                              child: NeumorphicCard(
                                child: Padding(
                                  padding: EdgeInsets.all(18.w),
                                  child: _KeyBreakdownSection(
                                    keyString: permission.key,
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

/// 🔍 Key breakdown: workforce_structure.job.view
class _KeyBreakdownSection extends StatelessWidget {
  final String keyString;

  const _KeyBreakdownSection({required this.keyString});

  Map<String, String> _parsePermissionKey(String key) {
    if (key.isEmpty) return {};
    final parts = key.split('.');
    if (parts.length == 1) {
      return {
        'module': parts[0],
        'resource': '-',
        'action': '-',
      };
    }
    if (parts.length == 2) {
      return {
        'module': parts[0],
        'resource': parts[1],
        'action': '-',
      };
    }
    return {
      'module': parts.first,
      'resource': parts.length > 2 ? parts[1] : '-',
      'action': parts.last,
    };
  }

  String _humanizeSegment(String segment) {
    if (segment.isEmpty || segment == '-') return '-';
    return segment
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isEmpty
          ? w
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parsePermissionKey(keyString);
    final module = parsed['module'] ?? '-';
    final resource = parsed['resource'] ?? '-';
    final action = parsed['action'] ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Key Breakdown",
          style: context.text18SemiBold.copyWith(
            color: context.primaryColor,
          ),
        ),
        12.verticalSpace,
        Wrap(
          spacing: 14.w,
          runSpacing: 10.h,
          children: [
            _buildItem(
              context,
              title: "Module",
              value: _humanizeSegment(module),
            ),
            _buildItem(
              context,
              title: "Resource",
              value: _humanizeSegment(resource),
            ),
            _buildItem(
              context,
              title: "Action",
              value: _humanizeSegment(action),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(
      BuildContext context, {
        required String title,
        required String value,
      }) {
    return Container(
      width: 220.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text12SemiBold.copyWith(
              color: context.gray99TextColor,
            ),
          ),
          4.verticalSpace,
          Text(
            value,
            style: context.text14Regular,
          ),
        ],
      ),
    );
  }
}
