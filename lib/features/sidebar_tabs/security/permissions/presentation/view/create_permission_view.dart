import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerStatefulWidget, ConsumerState;
import 'package:flutter_riverpod/legacy.dart' show ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'
    show ModalProgressHUD;

import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/model/permission_menu.dart'; // Menu, SubMenu, PermAction
import 'package:moot_web/core/utils/utils.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/common_widgets/build_drop_down.dart';
import 'package:moot_web/features/common_widgets/custom_button.dart';
import 'package:moot_web/features/common_widgets/inputfield_widget.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/menu_catalog.dart' show kMenuCatalog;
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/provider/permission_provider.dart';

final permissionProvider =
ChangeNotifierProvider.autoDispose<PermissionProvider>(
      (ref) => PermissionProvider(),
);

class CreatePermissionView extends ConsumerStatefulWidget {
  const CreatePermissionView({super.key});
  @override
  ConsumerState<CreatePermissionView> createState() =>
      _CreatePermissionViewState();
}

class _CreatePermissionViewState extends ConsumerState<CreatePermissionView> {
  bool isEdit = false;
  Permission? permission;

  // Form controllers
  final TextEditingController keyCtrl = TextEditingController();
  final TextEditingController labelCtrl = TextEditingController();
  final TextEditingController groupCtrl = TextEditingController();
  final TextEditingController moduleCtrl = TextEditingController();

  // Dropdown controllers
  late final TextEditingController _menuController;
  late final TextEditingController _menuSearchController;
  late final TextEditingController _subMenuController;
  late final TextEditingController _subMenuSearchController;
  late final TextEditingController _actionController;
  late final TextEditingController _actionSearchController;

  bool isSystemPermission = false;
  bool isActive = true;

  // ===== Selector state (SubMenu is nullable) =====
  Menu? _selectedMenu;
  SubMenu? _selectedSubMenu; // null => use parent menu permission
  PermAction? _selectedAction;
  bool _useWildcard = true;

  @override
  void initState() {
    super.initState();

    // init dropdown controllers
    _menuController = TextEditingController();
    _menuSearchController = TextEditingController();
    _subMenuController = TextEditingController();
    _subMenuSearchController = TextEditingController();
    _actionController = TextEditingController();
    _actionSearchController = TextEditingController();

    final extra = GoRouter.of(context).state.extra as Map<String, dynamic>?;
    permission = extra?['permission'] as Permission?;
    isEdit = permission != null;

    keyCtrl.text = permission?.key ?? '';
    labelCtrl.text = permission?.label ?? '';
    groupCtrl.text = permission?.group ?? '';
    moduleCtrl.text = permission?.module ?? '';
    isSystemPermission = permission?.isSystemPermission ?? false;
    isActive = permission?.isActive ?? true;

    // Defaults
    _selectedMenu = kMenuCatalog.first;
    _menuController.text = _selectedMenu!.menuName;

    _selectedSubMenu = null; // user can leave empty for parent scope
    _useWildcard = true;
    _selectedAction = PermAction.view;
    _actionController.text = _selectedAction!.label;

    final existingKey = permission?.key.trim();
    if (existingKey != null && existingKey.isNotEmpty) {
      _preselectFromExistingKey(existingKey);
    } else {
      _applySelectionToFields();
    }
  }

  @override
  void dispose() {
    keyCtrl.dispose();
    labelCtrl.dispose();
    groupCtrl.dispose();
    moduleCtrl.dispose();

    _menuController.dispose();
    _menuSearchController.dispose();
    _subMenuController.dispose();
    _subMenuSearchController.dispose();
    _actionController.dispose();
    _actionSearchController.dispose();

    super.dispose();
  }

  bool _isValidKey(String s) {
    final rx = RegExp(r'^[a-z0-9._*]+$');
    return rx.hasMatch(s);
  }

  // ===== Selection helpers =====
  void _applySelectionToFields() {
    if (_selectedMenu == null) return;
    final menu = _selectedMenu!;

    // No submenu selected -> use parent permission
    if (_selectedSubMenu == null) {
      keyCtrl.text = menu.permissionKey; // e.g. employee_management.*
      labelCtrl.text = 'All - ${menu.menuName}';
      groupCtrl.text = menu.menuName;
      moduleCtrl.text = ''; // no specific module
      return;
    }

    // Submenu selected -> build from submenu + action/wildcard
    final sub = _selectedSubMenu!;
    final group = menu.menuName;
    final module = sub.name;

    if (_useWildcard) {
      keyCtrl.text = '${sub.baseKey}.*';
      labelCtrl.text = 'All - $module';
    } else {
      final action = _selectedAction ?? PermAction.view;
      keyCtrl.text = '${sub.baseKey}.${action.key}';
      labelCtrl.text = '${action.label} $module';
    }
    groupCtrl.text = group;
    moduleCtrl.text = module;
  }

  void _preselectFromExistingKey(String key) {
    for (final menu in kMenuCatalog) {
      // parent match
      if (key == menu.permissionKey) {
        setState(() {
          _selectedMenu = menu;
          _menuController.text = menu.menuName;

          _selectedSubMenu = null;
          _subMenuController.clear();

          _useWildcard = true;
          _selectedAction = null;
          _actionController.clear();
        });
        _applySelectionToFields();
        return;
      }
      // submenu match
      for (final sub in menu.subMenus) {
        final base = sub.baseKey;
        if (key == '$base.*') {
          setState(() {
            _selectedMenu = menu;
            _menuController.text = menu.menuName;

            _selectedSubMenu = sub;
            _subMenuController.text = sub.name;

            _useWildcard = true;
            _selectedAction = null;
            _actionController.clear();
          });
          _applySelectionToFields();
          return;
        }
        for (final a in PermAction.values) {
          if (key == '$base.${a.key}') {
            setState(() {
              _selectedMenu = menu;
              _menuController.text = menu.menuName;

              _selectedSubMenu = sub;
              _subMenuController.text = sub.name;

              _useWildcard = false;
              _selectedAction = a;
              _actionController.text = a.label;
            });
            _applySelectionToFields();
            return;
          }
        }
      }
    }
  }

  Future<void> _onSubmit() async {
    final provider = ref.read(permissionProvider);

    final rawKey = keyCtrl.text.trim().toLowerCase();
    final label = labelCtrl.text.trim();
    final group = groupCtrl.text.trim();
    final module = moduleCtrl.text.trim();

    if (rawKey.isEmpty || label.isEmpty) {
      Utils().showToast('Key and Label are required');
      return;
    }
    if (!_isValidKey(rawKey)) {
      Utils().showToast(
          'Invalid key format. Use lowercase letters, numbers, ".", "_" or "*".');
      return;
    }

    final body = <String, dynamic>{
      'key': rawKey,
      'label': label,
      if (group.isNotEmpty) 'group': group,
      if (module.isNotEmpty) 'module': module,
      'isActive': isActive,
      'isSystemPermission': isSystemPermission,
    };

    try {
      if (isEdit) {
        await provider.updatePermission(
          permissionId: permission!.id,
          body: body,
          onSuccess: () {
            Utils().showToast('Permission updated');
            context.goNamed('permissions');
          },
        );
      } else {
        await provider.createPermission(
          body: body,
          onSuccess: () {
            Utils().showToast('Permission created');
            context.goNamed('permissions');
          },
        );
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('E11000') || msg.toLowerCase().contains('duplicate')) {
        Utils().showToast('A permission with this key already exists.');
      } else {
        Utils().showToast('Failed: $msg');
      }
      log('Create/Update Permission error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final permsNotifier = ref.watch(permissionProvider);

    final bool disableAction = _selectedSubMenu == null || _useWildcard;

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: permsNotifier.isLoading,
        child: LayoutBuilder(
          builder: (_, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  children: [
                    Expanded(
                      child: FormContainer(
                        constraints: constraints,
                        child: Column(
                          children: [
                            // Header
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 14, bottom: 6),
                              child: Text(
                                isEdit
                                    ? 'Edit Permission'
                                    : 'Create Permission',
                                style: context.text20SemiBold
                              ),
                            ),
                            const Divider(color: Colors.white24),

                            // Body
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    20.verticalSpace,

                                    // Menu
                                    BuildDropdown<Menu>(
                                      title: 'Menu',
                                      label: 'Select menu',
                                      searchHint: 'Search menu',
                                      isEnable: false,
                                      showSearch: false,
                                      isLoadingMore: false,
                                      controller: _menuController,
                                      searchController:
                                      _menuSearchController,
                                      options: kMenuCatalog, // List<Menu>
                                      displayField: (m) => m.menuName,
                                      onChange: (m) {
                                        setState(() {
                                          _selectedMenu = m;
                                          _menuController.text = m.menuName;

                                          // Reset Sub Menu when parent changes
                                          _selectedSubMenu = null;
                                          _subMenuController.clear();

                                          _useWildcard = true;
                                          _selectedAction = PermAction.view;
                                          _actionController.text =
                                              _selectedAction!.label;
                                        });
                                        _applySelectionToFields();
                                      },
                                      onSearch: (q) {
                                        // wire remote search if needed
                                      },
                                      onPagination: (_) {},
                                      searchLoading: false,
                                      padding: EdgeInsets.zero,
                                    ),

                                    12.verticalSpace,

                                    // Sub Menu (optional). If none -> parent applies
                                    BuildDropdown<SubMenu>(
                                      title: 'Sub Menu (optional)',
                                      label:
                                      'Leave empty to use parent menu permission',
                                      searchHint: 'Search sub menu',
                                      isEnable: false,
                                      showSearch: false,
                                      isLoadingMore: false,
                                      controller: _subMenuController,
                                      searchController:
                                      _subMenuSearchController,
                                      options: _selectedMenu?.subMenus ??
                                          const <SubMenu>[],
                                      displayField: (s) => s.name,
                                      onChange: (s) {
                                        setState(() {
                                          _selectedSubMenu = s;
                                          _subMenuController.text = s.name;

                                          // When submenu picked, keep wildcard ON by default
                                          // (user can toggle off to choose action)
                                          _useWildcard = true;
                                        });
                                        _applySelectionToFields();
                                      },
                                      onSearch: (q) {},
                                      onPagination: (_) {},
                                      searchLoading: false,
                                      padding: EdgeInsets.zero,
                                    ),

                                    12.verticalSpace,

                                    // Wildcard (only relevant when submenu selected)
                                    Opacity(
                                      opacity:
                                      _selectedSubMenu == null ? 0.4 : 1,
                                      child: IgnorePointer(
                                        ignoring: _selectedSubMenu == null,
                                        child: _SwitchTile(
                                          title:
                                          'All (${_selectedSubMenu?.name ?? 'Module'})',
                                          value: _useWildcard,
                                          onChanged: (v) {
                                            setState(
                                                    () => _useWildcard = v);
                                            _applySelectionToFields();
                                          },
                                        ),
                                      ),
                                    ),
                                    12.verticalSpace,

                                    // Action (disabled when parent selected OR wildcard on)
                                    Opacity(
                                      opacity: disableAction ? 0.4 : 1,
                                      child: IgnorePointer(
                                        ignoring: disableAction,
                                        child: BuildDropdown<PermAction>(
                                          title: 'Action',
                                          label: 'Select action',
                                          searchHint: 'Search action',
                                          isEnable: false,
                                          showSearch: false, // small list
                                          isLoadingMore: false,
                                          controller: _actionController,
                                          searchController:
                                          _actionSearchController,
                                          options: PermAction.values,
                                          displayField: (a) => a.label,
                                          onChange: (a) {
                                            setState(() {
                                              _selectedAction = a;
                                              _actionController.text =
                                                  a.label;
                                            });
                                            _applySelectionToFields();
                                          },
                                          onSearch: (_) {},
                                          onPagination: (_) {},
                                          searchLoading: false,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),

                                    20.verticalSpace,
                                    const Divider(color: Colors.white24),
                                    12.verticalSpace,

                                    // Auto-filled fields
                                    InputFieldWidget(
                                      title: "Key *",
                                      hint:
                                      "e.g. workforce_structure.job.view",
                                      controller: keyCtrl,
                                    ),
                                    16.verticalSpace,
                                    InputFieldWidget(
                                      title: "Label *",
                                      hint: "e.g. View Job",
                                      controller: labelCtrl,
                                      enable: false,
                                      showPadding: true,
                                    ),
                                    16.verticalSpace,
                                    InputFieldWidget(
                                      title: "Group",
                                      hint: "e.g. Workforce Structure",
                                      controller: groupCtrl,
                                      showPadding: true,
                                      enable: false,

                                    ),
                                    16.verticalSpace,
                                    InputFieldWidget(
                                      title: "Module",
                                      hint: "e.g. Job",
                                      controller: moduleCtrl,
                                      showPadding: true,
                                      enable: false,

                                    ),
                                    16.verticalSpace,
                                    _SwitchTile(
                                      title: "Active",
                                      value: isActive,
                                      onChanged: (v) =>
                                          setState(() => isActive = v),
                                    ),
                                    10.verticalSpace,
                                    _SwitchTile(
                                      title: "System Permission",
                                      value: isSystemPermission,
                                      onChanged: (v) => setState(
                                              () => isSystemPermission = v),
                                    ),
                                    24.verticalSpace,
                                  ],
                                ),
                              ),
                            ),

                            // Footer
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: customUploadBtnWidget(
                                    isLoading: permsNotifier.isLoading,
                                    text: isEdit
                                        ? 'Update Permission'
                                        : 'Create Permission',
                                    context: context,
                                    onTap: _onSubmit,
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

/// Minimal local switch tile so this file compiles independently.
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
            activeTrackColor: Colors.white.withOpacity(0.4),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
