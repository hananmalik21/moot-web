import 'dart:developer';
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
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/provider/permission_provider.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/provider/role_provider.dart';


final roleProvider = ChangeNotifierProvider.autoDispose<RoleProvider>(
  (ref) => RoleProvider(),
);
final permissionProvider =
    ChangeNotifierProvider.autoDispose<PermissionProvider>(
      (ref) => PermissionProvider(),
    );

// ======== VIEW ========
class CreateRoleView extends ConsumerStatefulWidget {
  const CreateRoleView({super.key});

  @override
  ConsumerState<CreateRoleView> createState() => _CreateRoleViewState();
}

class _CreateRoleViewState extends ConsumerState<CreateRoleView> {
  bool isEdit = false;
  Role? role;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  bool isSystemRole = false;

  // hold selected permission keys
  final Set<String> selectedPermissionKeys = {};

  @override
  void initState() {
    super.initState();
    // read from router extra if editing
    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    role = extra?['role'] as Role?;
    isEdit = role != null;

    nameCtrl.text = role?.name ?? '';
    descCtrl.text = role?.description ?? '';
    isSystemRole = role?.isSystemRole ?? false;
    if (role?.permissions != null) {
      selectedPermissionKeys.addAll(role!.permissions);
      log("keys are $selectedPermissionKeys");
    }
    ref.read(permissionProvider).getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final rolesNotifier = ref.watch(roleProvider);
    final permsNotifier = ref.watch(permissionProvider);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: rolesNotifier.isLoading || permsNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  children: [
                    Expanded(
                      child: FormContainer(
                        width: 0.5.sw,
                        constraints: constraints,
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 14,
                                bottom: 6,
                              ),
                              child: Text(
                                isEdit ? 'Edit Role' : 'Create Role',
                                style: context.text20SemiBold
                              ),
                            ),
                            const Divider(color: Colors.white24),

                            // Body scroll
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    20.verticalSpace,
                                    // Role Name
                                    InputFieldWidget(
                                      title: "Role Name *",
                                      hint: "e.g. HR Admin",
                                      controller: nameCtrl,
                                    ),
                                    16.verticalSpace,
                                    // Description
                                    InputFieldWidget(
                                      title: "Description",
                                      hint: "Optional",
                                      controller: descCtrl,
                                      minLines: 3,
                                      maxLines: 6,
                                      showPadding: true,
                                    ),
                                    12.verticalSpace,
                                    // System role toggle
                                    _SwitchTile(
                                      title: "System Role",
                                      value: isSystemRole,
                                      onChanged: (v) =>
                                          setState(() => isSystemRole = v),
                                    ),
                                    20.verticalSpace,

                                    // Permissions picker
                                    Text(
                                      'Permissions',
                                      style: context.text16SemiBold.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    8.verticalSpace,
                                    _PermissionPicker(
                                      isLoading: permsNotifier.isLoading,
                                      permissions: permsNotifier.permissions,
                                      selectedKeys: selectedPermissionKeys,
                                      onChanged: (key, selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedPermissionKeys.add(key);
                                          } else {
                                            selectedPermissionKeys.remove(
                                              key,
                                            );
                                          }
                                        });
                                      },
                                    ),

                                    20.verticalSpace,
                                    // Selected chips
                                    if (selectedPermissionKeys.isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: selectedPermissionKeys
                                            .map(
                                              (k) => _KeyChip(
                                                text: k,
                                                onRemove: () => setState(() {
                                                  selectedPermissionKeys
                                                      .remove(k);
                                                }),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    24.verticalSpace,
                                  ],
                                ),
                              ),
                            ),

                            // Footer button
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: customUploadBtnWidget(
                                    isLoading: rolesNotifier.isLoading,
                                    text: isEdit
                                        ? 'Update Role'
                                        : 'Create Role',
                                    context: context,
                                    onTap: () {
                                      final name = nameCtrl.text.trim();
                                      if (name.isEmpty) {
                                        Utils().showToast(
                                          'Role name is required',
                                        );
                                        return;
                                      }

                                      final body = {
                                        "name": name,
                                        if (descCtrl.text.trim().isNotEmpty)
                                          "description": descCtrl.text.trim(),
                                        "isSystemRole": isSystemRole,
                                        "permissions": selectedPermissionKeys
                                            .toList(),
                                      };

                                      if (isEdit) {
                                        ref
                                            .read(roleProvider)
                                            .updateRole(
                                              roleId: role!.id,
                                              body: body,
                                              onSuccess: () =>
                                                  context.goNamed('roles'),
                                            );
                                      } else {
                                        ref
                                            .read(roleProvider)
                                            .createRole(
                                              body: body,
                                              onSuccess: () =>
                                                  context.goNamed('roles'),
                                            );
                                      }
                                    },
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

// ===== UI bits =====

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.text14Medium.copyWith(color: Colors.white70),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _PermissionPicker extends StatefulWidget {
  final bool isLoading;
  final List<Permission> permissions;
  final Set<String> selectedKeys;
  final void Function(String key, bool selected) onChanged;

  const _PermissionPicker({
    required this.isLoading,
    required this.permissions,
    required this.selectedKeys,
    required this.onChanged,
  });

  @override
  State<_PermissionPicker> createState() => _PermissionPickerState();
}

class _PermissionPickerState extends State<_PermissionPicker> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        child: const CircularProgressIndicator.adaptive(),
      );
    }

    final list =
        widget.permissions.where((p) {
          if (query.isEmpty) return true;
          final q = query.toLowerCase();
          return p.key.toLowerCase().contains(q) ||
              p.label.toLowerCase().contains(q) ||
              (p.group).toLowerCase().contains(q) ||
              (p.module ?? '').toLowerCase().contains(q);
        }).toList()..sort((a, b) {
          // group -> module -> label sorting for nicer UX
          final g = (a.group).compareTo(b.group);
          if (g != 0) return g;
          final m = (a.module ?? '').compareTo(b.module ?? '');
          if (m != 0) return m;
          return a.label.compareTo(b.label);
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // search
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search permissions (key, label, group, module)',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        10.verticalSpace,

        // list
        Container(
          constraints: const BoxConstraints(maxHeight: 280,minHeight: 100),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Scrollbar(
            controller: ScrollController(),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final item = list[i];
                final selected = widget.selectedKeys.contains(item.key);
                final subtitleParts = [
                  item.group,
                  if (item.module != null) item.module!,
                ];
                return CheckboxListTile(
                  value: selected,
                  onChanged: (v) => widget.onChanged(item.key, v ?? false),
                  title: Text(
                    item.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${item.key}${subtitleParts.isNotEmpty ? '  •  ${subtitleParts.join(" / ")}' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;

  const _KeyChip({required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
      onDeleted: onRemove,
    );
  }
}
