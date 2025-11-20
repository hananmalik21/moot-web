import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/common_widgets/add_button_department.dart';
import 'package:moot_web/features/common_widgets/common_dialog.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/custom_data_table.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// ✅ Needed for PermissionGuard + current user's permissions
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/glass_header_widget.dart';
import 'package:moot_web/features/common_widgets/permission_chip.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/provider/role_provider.dart';

class RolesView extends ConsumerStatefulWidget {
  const RolesView({super.key});

  @override
  ConsumerState<RolesView> createState() => _RolesViewState();
}

class _RolesViewState extends ConsumerState<RolesView> {
  final rolesProvider = ChangeNotifierProvider.autoDispose<RoleProvider>(
    (ref) => RoleProvider(),
  );

  late final PermissionGuard _guard;

  // ────────────────────── Permission Getters ──────────────────────
  // security.* can do anything; security.role.* can do all role actions.
  bool get _canCreateRole =>
      _guard.allows('security.role.create') ||
      _guard.allows('security.role.*') ||
      _guard.allows('security.*');

  bool get _canUpdateRole =>
      _guard.allows('security.role.update') ||
      _guard.allows('security.role.*') ||
      _guard.allows('security.*');

  bool get _canDeleteRole =>
      _guard.allows('security.role.delete') ||
      _guard.allows('security.role.*') ||
      _guard.allows('security.*');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rolesProvider).getRoles();
      // Build guard from current user’s permissions
      final perms =
          (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[])
              .toList();
      _guard = PermissionGuard(perms);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(rolesProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    final hasActions = _canUpdateRole || _canDeleteRole;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: notifier.isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SafeArea(
          child: Column(
            children: [
              buildGlassCover(context, isMobile, "Roles"),
              20.verticalSpace,

              // Create button only if allowed
              if (_canCreateRole)
                AddButtonWidget(
                  onTap: () => context.goNamed("create-role"),
                  title: "Add Role",
                ),

              20.verticalSpace,
              CustomDataTable(
                emptyMessage: 'No roles found',
                headerColor: context.primaryColor,
                onRowTap: (index){
                  context.goNamed(
                    'role-detail',
                    pathParameters: {"id": notifier.roles[index].id},
                    extra: {"role": notifier.roles[index]},
                  );
                },
                columns: [
                  const DataColumn(label: Text('#')),
                  const DataColumn(label: Text('Name')),
                  const DataColumn(label: Text('Description')),
                  const DataColumn(label: Text('Permissions')),
                  const DataColumn(label: Text('System Role')),
                  if (hasActions) const DataColumn(label: Text('Actions')),
                ],
                rows: List<DataRow>.generate(notifier.roles.length, (index) {
                  final role = notifier.roles[index];
                  final isEven = index.isEven;

                  final cells = <DataCell>[
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(role.name ?? "")),
                    DataCell(Text(role.description ?? "")),

                    // Permissions count (tap to view)
                    DataCell(
                      InkWell(
                        onTap: () {
                          Utils().showCustomDialog(
                            context,
                            ViewPermissionsDialog(role: role),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, size: 18),
                            const SizedBox(width: 6),
                            Text('${role.permissions.length}'),
                          ],
                        ),
                      ),
                    ),

                    DataCell(Text(role.isSystemRole.toString())),
                  ];

                  if (hasActions) {
                    cells.add(
                      DataCell(
                        Row(
                          children: [
                            if (_canUpdateRole)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                tooltip: 'Edit',
                                onPressed: () {
                                  context.goNamed(
                                    'edit-role',
                                    pathParameters: {"id": role.id},
                                    extra: {"role": role},
                                  );
                                },
                              ),
                            if (_canDeleteRole)
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
                                      onClick: () =>
                                          notifier.deleteRole(roleId: role.id),
                                    ),
                                  );
                                },
                              ),
                            // Always allow viewing permissions
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.teal,
                                size: 20,
                              ),
                              tooltip: 'View permissions',
                              onPressed: () {
                                Utils().showCustomDialog(
                                  context,
                                  ViewPermissionsDialog(role: role),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────── Permissions Dialog ──────────────────────

class ViewPermissionsDialog extends StatefulWidget {
  final Role role;
  final Map<String, String>? keyToLabel;

  const ViewPermissionsDialog({super.key, required this.role, this.keyToLabel});

  @override
  State<ViewPermissionsDialog> createState() => _ViewPermissionsDialogState();
}

class _ViewPermissionsDialogState extends State<ViewPermissionsDialog> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<String> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final list = widget.role.permissions;
    if (q.isEmpty) return list;
    return list.where((p) => p.toLowerCase().contains(q)).toList();
  }

  String _displayFor(String key) {
    final label = widget.keyToLabel?[key];
    if (label != null && label.trim().isNotEmpty) return label;
    return key.replaceAll('.', ' → ');
  }

  Future<void> _copyAll() async {
    final text = widget.role.permissions.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) Utils().showToast("Permissions copied to clipboard");
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final perms = _filtered;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Glass background
            Container(
              width: isMobile ? 600 : 900,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 600 : 900,
                      maxHeight:
                          MediaQuery.of(context).size.height *
                          (isMobile ? 0.75 : 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(Icons.security, color: context.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Permissions • ${widget.role.name ?? "Unnamed Role"}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${widget.role.permissions.length}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Search + Copy
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search permissions…',
                                  prefixIcon: const Icon(Icons.search),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            customUploadBtnWidget(
                              text: 'Copy All',
                              width: 120,
                              height: 40,
                              onTap: _copyAll,
                              borderRadius: 10,
                              context: context,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Body
                        Expanded(
                          child: perms.isEmpty
                              ? Center(
                                  child: Text(
                                    widget.role.permissions.isEmpty
                                        ? 'No permissions'
                                        : 'No matches for “${_searchCtrl.text}”',
                                  ),
                                )
                              : Scrollbar(
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(
                                      right: 4,
                                      bottom: 12,
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: perms.map((key) {
                                        return PermissionChip(permission: _displayFor(key));
                                      }).toList(),
                                    ),
                                  ),
                                ),
                        ),

                        // Footer
                        Align(
                          alignment: Alignment.centerRight,
                          child: customUploadBtnWidget(
                            context: context,
                            text: 'Close',
                            width: 120,
                            height: 44,
                            borderRadius: 10,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
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


