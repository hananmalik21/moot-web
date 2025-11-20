import 'dart:ui';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moot_web/core/extensions/colors.dart';
import 'package:moot_web/core/extensions/textstyles.dart';
import 'package:moot_web/core/utils/global_constants.dart';
import 'package:moot_web/features/common_widgets/custom_text.dart';

// Assume you already have a user provider that exposes user.permissions
// final userDataProvider = Provider<UserData?>((ref) => ...);

/// -------------------- Permission Utils --------------------
class PermissionGuard {
  final Set<String> _perms;
  PermissionGuard(Iterable<String> permissions) : _perms = {...permissions};

  bool allows(String key) {
    if (_perms.contains(key)) return true;
    final parts = key.split('.');
    for (int i = parts.length - 1; i >= 1; i--) {
      final prefix = parts.take(i).join('.');
      if (_perms.contains('$prefix.*')) return true; // e.g. security.*, security.user.*
    }
    return false;
  }
}

/// -------------------- Models --------------------
class _NavLeaf {
  final IconData icon;
  final String label;
  final String routeName;
  final String? requiredPermission;

  const _NavLeaf({
    required this.icon,
    required this.label,
    required this.routeName,
    this.requiredPermission,
  });
}

class _NavGroup {
  final IconData icon;
  final String label;
  final List<_NavLeaf> children;

  const _NavGroup({
    required this.icon,
    required this.label,
    required this.children,
  });
}

/// Permission base constants (avoid typos)
const String pWS = 'workforce_structure';
const String pWSJob = '$pWS.job';
const String pWSGrade = '$pWS.grade';
const String pWSPos = '$pWS.position';
const String pWSLoc = '$pWS.location';

const String pEnt = 'enterprise_structure';
const String pEntCompany = '$pEnt.company';
const String pEntBU = '$pEnt.business_unit';
const String pEntDept = '$pEnt.department';

const String pSec = 'security';
const String pSecUser = '$pSec.user';
const String pSecRole = '$pSec.role';
const String pSecPerm = '$pSec.permission';

/// -------------------- Dashboard Shell --------------------
class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  String? _selectedRoute;

  // Top-level Overview
  static const _overview = _NavLeaf(
    icon: Icons.grid_view,
    label: 'Overview',
    routeName: 'overview',
    // requiredPermission: 'dashboard.view',
  );

  // Define groups/leaves with requiredPermission = "<resource>.view" keys
  static const List<_NavGroup> _allGroups = [
    _NavGroup(
      icon: Icons.work_outline,
      label: 'Workforce Structure',
      children: [
        _NavLeaf(icon: Icons.badge_outlined, label: 'Job',       routeName: 'jobs',       requiredPermission: '$pWSJob.view'),
        _NavLeaf(icon: Icons.grade,          label: 'Grade',     routeName: 'grades',     requiredPermission: '$pWSGrade.view'),
        _NavLeaf(icon: Icons.people_outline, label: 'Position',  routeName: 'positions',  requiredPermission: '$pWSPos.view'),
        _NavLeaf(icon: Icons.location_city,  label: 'Location',  routeName: 'locations',  requiredPermission: '$pWSLoc.view'),
      ],
    ),
    _NavGroup(
      icon: Icons.vpn_key,
      label: 'Security',
      children: [
        // 🔧 FIXED to singular bases so security.role.* and security.* match
        _NavLeaf(icon: Icons.people,               label: 'Users',       routeName: 'users',       requiredPermission: '$pSecUser.view'),
        _NavLeaf(icon: Icons.admin_panel_settings, label: 'Roles',       routeName: 'roles',       requiredPermission: '$pSecRole.view'),
        _NavLeaf(icon: Icons.vpn_key,              label: 'Permissions', routeName: 'permissions', requiredPermission: '$pSecPerm.view'),
      ],
    ),
    _NavGroup(
      icon: Icons.apartment,
      label: 'Enterprise Structure',
      children: [
        _NavLeaf(icon: Icons.domain,                label: 'Company',        routeName: 'companies',      requiredPermission: '$pEntCompany.view'),
        _NavLeaf(icon: Icons.account_tree_outlined, label: 'Business Units', routeName: 'business-units', requiredPermission: '$pEntBU.view'),
        _NavLeaf(icon: Icons.corporate_fare,        label: 'Departments',    routeName: 'departments',    requiredPermission: '$pEntDept.view'),
      ],
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = GoRouter.of(context)
        .routeInformationProvider
        .value
        .uri
        .pathSegments
        .join('/');
    final guessed = GoRouter.of(context).state.name ??
        GoRouter.of(context).state.uri.pathSegments.lastOrNull;
    final effective = GoRouter.of(context).state.name ?? guessed ?? name;
    if (effective != _selectedRoute) {
      setState(() => _selectedRoute = effective);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read permissions from Riverpod

    final permissions =
    (ref.watch(userDataProvider).user?.user.permissions ?? const <String>[]);

    final guard = PermissionGuard(permissions);

    // Filter groups by permissions
    final filtered = _allGroups
        .map((g) {
      final visibleChildren = g.children.where((leaf) {
        final req = leaf.requiredPermission;
        return req == null || guard.allows(req);
      }).toList();
      return _NavGroup(icon: g.icon, label: g.label, children: visibleChildren);
    })
        .where((g) => g.children.isNotEmpty)
        .toList();

    // Visible leaves for selection fallback
    final visibleLeaves = <_NavLeaf>[
      if (_overview.requiredPermission == null ||
          guard.allows(_overview.requiredPermission!))
        _overview,
      for (final g in filtered) ...g.children,
    ];

    if (_selectedRoute != null &&
        !visibleLeaves.any((l) => l.routeName == _selectedRoute)) {
      _selectedRoute = visibleLeaves.isNotEmpty ? visibleLeaves.first.routeName : null;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          CollapsibleSidebar(
            overview: _overview,
            groups: filtered,
            selectedRouteName: _selectedRoute,
            onLeafTap: (routeName) {
              setState(() => _selectedRoute = routeName);
              context.goNamed(routeName);
            },
            initiallyExpanded: true,
            permissions: permissions, // pass down for guard in tiles
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

/// -------------------- Collapsible Sidebar --------------------
class CollapsibleSidebar extends ConsumerStatefulWidget {
  final _NavLeaf overview;
  final List<_NavGroup> groups;
  final String? selectedRouteName;
  final ValueChanged<String> onLeafTap;
  final bool initiallyExpanded;
  final List<String> permissions;

  const CollapsibleSidebar({
    super.key,
    required this.overview,
    required this.groups,
    required this.selectedRouteName,
    required this.onLeafTap,
    this.initiallyExpanded = true,
    this.permissions = const [],
  });

  @override
  ConsumerState<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends ConsumerState<CollapsibleSidebar>
    with SingleTickerProviderStateMixin {
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const double mobileBreakpoint = 600;

  late bool _isExpanded;
  late AnimationController _rotationController;
  late Set<int> _openGroups;
  late PermissionGuard _guard;

  bool get _isMobile => MediaQuery.of(context).size.width < mobileBreakpoint;

  @override
  void initState() {
    super.initState();
    _guard = PermissionGuard(widget.permissions);
    _isExpanded = widget.initiallyExpanded;
    _rotationController = AnimationController(
      vsync: this,
      duration: animationDuration,
      upperBound: 0.5,
    )..value = _isExpanded ? 0.5 : 0.0;
    _openGroups = _initialOpenGroups();
  }

  @override
  void didUpdateWidget(covariant CollapsibleSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.permissions != widget.permissions) {
      _guard = PermissionGuard(widget.permissions);
    }
    if (oldWidget.selectedRouteName != widget.selectedRouteName) {
      final sel = widget.selectedRouteName;
      final idx = widget.groups.indexWhere(
            (g) => g.children.any((c) => c.routeName == sel),
      );
      if (idx >= 0 && !_openGroups.contains(idx)) {
        setState(() => _openGroups = {idx});
      }
    }
  }

  Set<int> _initialOpenGroups() {
    final sel = widget.selectedRouteName;
    if (sel == null) return {0};
    final idx = widget.groups.indexWhere(
          (g) => g.children.any((c) => c.routeName == sel),
    );
    return idx >= 0 ? {idx} : {0};
  }

  void _toggleCollapse() {
    if (_isMobile) return;
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }
  }

  double _calculateWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileBreakpoint) return 72;
    return _isExpanded ? 240 : 72;
  }

  bool _isRouteSelected(String? routeName) =>
      widget.selectedRouteName != null &&
          widget.selectedRouteName == routeName;

  bool _isGroupSelected(_NavGroup g) =>
      g.children.any((c) => _isRouteSelected(c.routeName));

  Widget _leafTile(_NavLeaf leaf) {
    // Extra guard (should already be filtered)
    final req = leaf.requiredPermission;
    if (req != null && !_guard.allows(req)) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isSelected = _isRouteSelected(leaf.routeName);

    final iconColor =
    isSelected ? theme.primaryColor : context.gray86TextColor;

    final textStyle = context.text14Regular.copyWith(
      color: isSelected ? theme.primaryColor : context.blackColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    );

    // COLLAPSED / MOBILE MODE → icon-only tile with strong shadow when selected
    if (!_isExpanded || _isMobile) {
      final child = AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeOut,
        height: 52.h,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
            color: theme.primaryColor.withOpacity(0.85),
            width: 1.4,
          )
              : null,
          // boxShadow: isSelected
          //     ? [
          //   BoxShadow(
          //     color: theme.primaryColor.withOpacity(0.4),
          //     blurRadius: 18,
          //     offset: const Offset(0, 8),
          //   ),
          // ]
          //     : [],
        ),
        alignment: Alignment.center,
        child: Icon(leaf.icon, size: 22, color: iconColor),
      );

      return Tooltip(
        message: leaf.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            widget.onLeafTap(leaf.routeName);
            if (_isExpanded && !_isMobile) _toggleCollapse();
          },
          child: child,
        ),
      );
    }

    // EXPANDED MODE → full-width tile with subtle left indicator & shadow
    final row = Row(
      children: [
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: animationDuration,
          width: 3,
          height: 22,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.95)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Icon(leaf.icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            text: leaf.label,
            ellipsisText: true,
            alignText: TextAlign.left,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOut,
      height: 48.h,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(
          color: theme.primaryColor.withOpacity(0.85),
          width: 1.2,
        )
            : null,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            widget.onLeafTap(leaf.routeName);
            if (_isExpanded && !_isMobile) _toggleCollapse();
          },
          child: row,
        ),
      ),
    );
  }

  Widget _groupTile(int index, _NavGroup group) {
    if (group.children.isEmpty) return const SizedBox.shrink();

    final isOpen = _openGroups.contains(index);
    final isActive = isOpen || _isGroupSelected(group);
    final theme = Theme.of(context);

    // COLLAPSED / MOBILE → icon-only + popup
    if (!_isExpanded || _isMobile) {
      final child = AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeOut,
        height: 52.h,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(
            color: theme.primaryColor.withOpacity(0.85),
            width: 1.4,
          )
              : null,
          boxShadow: isActive
              ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ]
              : [],
        ),
        alignment: Alignment.center,
        child: Icon(
          group.icon,
          size: 22,
          color: isActive ? theme.primaryColor : context.gray86TextColor,
        ),
      );

      return Tooltip(
        message: group.label,
          child: PopupMenuButton<_NavLeaf>(
            tooltip: group.label,
            offset: const Offset(0, 8),

            elevation: 0, // we use custom shadows instead

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            color: Colors.white, // neumorphic white

            shadowColor: Colors.transparent, // disable default shadow

            onSelected: (leaf) => widget.onLeafTap(leaf.routeName),

            itemBuilder: (ctx) => group.children.map((c) {
              return PopupMenuItem<_NavLeaf>(
                value: c,

                // Neumorphic tile style inside popup
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        offset: const Offset(3, 3),
                        blurRadius: 8,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-3, -3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

                  child: Row(
                    children: [
                      Icon(c.icon, size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            child: child,
          )
      );
    }

    // EXPANDED HEADER
    final header = AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOut,
      height: 52.h,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive
            ? theme.primaryColor.withOpacity(0.06)
            : Colors.transparent,
        boxShadow: isActive
            ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isOpen) {
                _openGroups.remove(index);
              } else {
                _openGroups = {index};
              }
            });
          },
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                group.icon,
                size: 20,
                color: isActive
                    ? theme.primaryColor
                    : context.gray86TextColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: group.label,
                  ellipsisText: true,
                  alignText: TextAlign.left,
                  textStyle: context.text14Regular.copyWith(
                    color: isActive
                        ? theme.primaryColor
                        : context.gray86TextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isOpen ? 0.5 : 0.0,
                duration: animationDuration,
                child: Icon(
                  Icons.expand_more,
                  color: isActive
                      ? theme.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );

    // CHILDREN
    final children = ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        duration: animationDuration,
        heightFactor: isOpen ? 1 : 0,
        child: Column(
          children: group.children
              .map(
                (leaf) => Padding(
              padding: EdgeInsets.only(
                left: 18.w,
                right: 10.w,
                top: 2,
                bottom: 2,
              ),
              child: _leafTile(leaf),
            ),
          )
              .toList(),
        ),
      ),
    );

    return Column(
      children: [
        header,
        children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showOverview = widget.overview.requiredPermission == null;

    return AnimatedContainer(
      duration: animationDuration,
      width: _calculateWidth(context),

      // ⭐ Neumorphic shadow works here
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          // Softer top-left highlight (dim but visible)
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-6, -6),
            blurRadius: 10,
            spreadRadius: 1,
          ),

          // Softer bottom-right shadow (dim but crisp)
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(6, 6),
            blurRadius: 14,
            spreadRadius: 1,
          ),

          // Slight side shadow for clarity (subtle)
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(4, -2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(-2, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),

    margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: Offset(4, 4),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                offset: Offset(-4, -4),
                blurRadius: 12,
              ),
            ],
          )
,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  // HEADER
                  SizedBox(
                    height: 84,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor
                                      .withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.dashboard_outlined,
                              color: Colors.white,
                            ),
                          ),
                          if (!_isMobile && _isExpanded)
                            const SizedBox(width: 12),
                          if (!_isMobile && _isExpanded)
                            Expanded(
                              child: CustomText(
                                text: 'Moot Dashboard',
                                alignText: TextAlign.left,
                                textStyle:
                                context.text16Medium.copyWith(
                                  color: context.gray86TextColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color:
                    Colors.grey.shade200.withOpacity(0.8),
                  ),

                  // NAV LIST
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: _isExpanded ? 0 : 4,
                        right: _isExpanded ? 0 : 4,
                      ),
                      children: [
                        if (showOverview)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _isExpanded ? 6 : 4,
                              vertical: 4,
                            ),
                            child: _leafTile(widget.overview),
                          ),
                        if (showOverview)
                          Divider(
                            height: 10,
                            color: Colors.grey.shade200
                                .withOpacity(0.8),
                          ),
                        ...List.generate(
                          widget.groups.length,
                              (i) => _groupTile(i, widget.groups[i]),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color:
                    Colors.grey.shade200.withOpacity(0.8),
                  ),

                  // FOOTER
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36.h,
                          height: 36.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.black54,
                          ),
                        ),
                        if (!_isMobile && _isExpanded)
                          const SizedBox(width: 10),
                        if (!_isMobile && _isExpanded)
                          Expanded(
                            child: CustomText(
                              alignText: TextAlign.left,
                              text: 'Hanan Khalid',
                              textStyle:
                              context.text16Medium.copyWith(
                                color: context.gray86TextColor,
                              ),
                              ellipsisText: true,
                            ),
                          ),
                        if (!_isMobile && _isExpanded)
                          IconButton(
                            onPressed: () async {
                              await ref.read(userDataProvider.notifier).clearUserData();
                              if (mounted) {
                                context.go('/login');
                              }
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.grey.shade400,
                            ),
                            tooltip: 'Logout',
                          ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              // COLLAPSE HANDLE
              if (!_isMobile)
                Positioned(
                  right: -14,
                  top: MediaQuery.of(context).size.height / 2 - 28,
                  child: GestureDetector(
                    onTap: _toggleCollapse,
                    child: AnimatedContainer(
                      duration: animationDuration,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor
                                .withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0 : 0.5,
                        duration: animationDuration,
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
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

extension on List<String> {
  String? get lastOrNull => isEmpty ? null : last;
}






















// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:moot_web/core/extensions/colors.dart';
// import 'package:moot_web/core/extensions/textstyles.dart';
// import 'package:moot_web/features/common_widgets/background_widget.dart';
// import 'package:moot_web/features/common_widgets/custom_text.dart';
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
//
// import 'package:moot_web/core/extensions/colors.dart';
// import 'package:moot_web/core/extensions/textstyles.dart';
// import 'package:moot_web/features/common_widgets/background_widget.dart';
// import 'package:moot_web/features/common_widgets/custom_text.dart';
//
// /// -------------------- Models --------------------
// class _NavLeaf {
//   final IconData icon;
//   final String label;
//   final String routeName; // GoRouter named route
//
//   const _NavLeaf({
//     required this.icon,
//     required this.label,
//     required this.routeName,
//   });
// }
//
// class _NavGroup {
//   final IconData icon;
//   final String label;
//   final List<_NavLeaf> children;
//
//   const _NavGroup({
//     required this.icon,
//     required this.label,
//     required this.children,
//   });
// }
//
// /// -------------------- Dashboard Shell --------------------
// class DashboardShell extends StatefulWidget {
//   final Widget child;
//
//   const DashboardShell({super.key, required this.child});
//
//   @override
//   State<DashboardShell> createState() => _DashboardShellState();
// }
//
// class _DashboardShellState extends State<DashboardShell> {
//   String? _selectedRoute;
//
//   // Top-level Overview (non-group)
//   static const _overview = _NavLeaf(
//     icon: Icons.grid_view,
//     label: 'Overview',
//     routeName: 'overview',
//   );
//
//   // Groups
//   static const List<_NavGroup> _groups = [
//     _NavGroup(
//       icon: Icons.work_outline,
//       label: 'Workforce Structure',
//       children: [
//         _NavLeaf(icon: Icons.badge_outlined, label: 'Job', routeName: 'jobs'),
//         _NavLeaf(icon: Icons.grade, label: 'Grade', routeName: 'grades'),
//         _NavLeaf(icon: Icons.people_outline, label: 'Position', routeName: 'positions'),
//         _NavLeaf(icon: Icons.location_city, label: 'Location', routeName: 'locations'),
//       ],
//     ),
//     _NavGroup(
//       icon: Icons.vpn_key,
//       label: 'Security',
//       children: [
//         _NavLeaf(icon: Icons.admin_panel_settings, label: 'Roles', routeName: 'roles'),
//         _NavLeaf(icon: Icons.vpn_key, label: 'Permissions', routeName: 'permissions'),
//         _NavLeaf(icon: Icons.people, label: 'Users', routeName: 'users'),
//       ],
//     ),
//     _NavGroup(
//       icon: Icons.apartment,
//       label: 'Enterprise Structure',
//       children: [
//         _NavLeaf(icon: Icons.domain, label: 'Company', routeName: 'companies'),
//         _NavLeaf(icon: Icons.account_tree_outlined, label: 'Business Units', routeName: 'business-units'),
//         _NavLeaf(icon: Icons.corporate_fare, label: 'Departments', routeName: 'departments'),
//       ],
//     ),
//
//   ];
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Determine current named route from GoRouter
//     final name = GoRouter.of(context).routeInformationProvider.value.uri.pathSegments.join('/');
//     // We used named routes (e.g., 'roles', 'departments'); we can read from GoRouter state:
//     // final currentName = GoRouter.of(context).namedLocation(GoRouter.of(context).routeInformationProvider.value.uri.toString(), params: {}).isNotEmpty
//     //     ? GoRouter.of(context).state.name
//     //     : GoRouter.of(context).state.name;
//
//     // Fallback: try to infer from uri if name not set
//     final guessed = GoRouter.of(context).state.name ?? GoRouter.of(context).state.uri.pathSegments.lastOrNull;
//
//     final effective = GoRouter.of(context).state.name ?? guessed ?? name;
//     if (effective != _selectedRoute) {
//       setState(() => _selectedRoute = effective);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundWidget(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Row(
//           children: [
//             CollapsibleSidebar(
//               overview: _overview,
//               groups: _groups,
//               selectedRouteName: _selectedRoute,
//               onLeafTap: (routeName) {
//                 setState(() => _selectedRoute = routeName);
//                 context.goNamed(routeName);
//               },
//               initiallyExpanded: true,
//             ),
//             Expanded(child: widget.child),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CollapsibleSidebar extends StatefulWidget {
//   final _NavLeaf overview;
//   final List<_NavGroup> groups;
//   final String? selectedRouteName;
//   final ValueChanged<String> onLeafTap;
//   final bool initiallyExpanded;
//
//   const CollapsibleSidebar({
//     super.key,
//     required this.overview,
//     required this.groups,
//     required this.selectedRouteName,
//     required this.onLeafTap,
//     this.initiallyExpanded = true,
//   });
//
//   @override
//   State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
// }
//
// class _CollapsibleSidebarState extends State<CollapsibleSidebar>
//     with SingleTickerProviderStateMixin {
//   static const Duration animationDuration = Duration(milliseconds: 250);
//   static const double mobileBreakpoint = 600;
//
//   late bool _isExpanded;
//   late AnimationController _rotationController;
//
//   // Which groups are open (by index)
//   late Set<int> _openGroups;
//
//   bool get _isMobile => MediaQuery.of(context).size.width < mobileBreakpoint;
//
//   @override
//   void initState() {
//     super.initState();
//     _isExpanded = widget.initiallyExpanded;
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: animationDuration,
//       upperBound: 0.5,
//     );
//     if (_isExpanded) _rotationController.value = 0.5;
//
//     _openGroups = _initialOpenGroups();
//   }
//
//   Set<int> _initialOpenGroups() {
//     final sel = widget.selectedRouteName;
//     if (sel == null) return {0}; // open first by default
//     final idx = widget.groups.indexWhere(
//           (g) => g.children.any((c) => c.routeName == sel),
//     );
//     return idx >= 0 ? {idx} : {0};
//   }
//
//   @override
//   void didUpdateWidget(covariant CollapsibleSidebar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.selectedRouteName != widget.selectedRouteName) {
//       // Auto-open the group that contains the selected item
//       final sel = widget.selectedRouteName;
//       final idx = widget.groups.indexWhere(
//             (g) => g.children.any((c) => c.routeName == sel),
//       );
//       if (idx >= 0 && !_openGroups.contains(idx)) {
//         setState(() => _openGroups = {idx});
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _rotationController.dispose();
//     super.dispose();
//   }
//
//   void _toggleCollapse() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < mobileBreakpoint) return;
//     setState(() => _isExpanded = !_isExpanded);
//     if (_isExpanded) {
//       _rotationController.forward();
//     } else {
//       _rotationController.reverse();
//     }
//   }
//
//   double _calculateWidth(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < mobileBreakpoint) return 72;
//     return _isExpanded ? 240 : 72;
//   }
//
//   // ---------- Selection helpers ----------
//   bool _isRouteSelected(String? routeName) =>
//       widget.selectedRouteName != null && widget.selectedRouteName == routeName;
//
//   bool _isGroupSelected(_NavGroup g) =>
//       g.children.any((c) => _isRouteSelected(c.routeName));
//
//   // ---------- Leaf tile ----------
//   Widget _leafTile(_NavLeaf leaf) {
//     final theme = Theme.of(context);
//     final isSelected = _isRouteSelected(leaf.routeName);
//
//     final bg =
//     isSelected ? theme.primaryColor.withOpacity(0.12) : Colors.transparent;
//     final iconColor =
//     isSelected ? theme.primaryColor : Colors.grey.shade300;
//     final textStyle = context.text14Regular.copyWith(
//       color: isSelected ? theme.primaryColor : context.grayD9TextColor,
//       fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//     );
//
//     // Collapsed / mobile: icon-only but highlighted
//     if (!_isExpanded || _isMobile) {
//       final child = Container(
//         height: 52.h,
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(vertical: 2),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12),
//           border:
//           isSelected ? Border.all(color: theme.primaryColor, width: 1) : null,
//         ),
//         alignment: Alignment.center,
//         child: Icon(leaf.icon, size: 22, color: iconColor),
//       );
//
//       return Tooltip(
//         message: leaf.label,
//         child: InkWell(
//           onTap: () {
//             widget.onLeafTap(leaf.routeName);
//             if (_isExpanded && !_isMobile) _toggleCollapse();
//           },
//           child: child,
//         ),
//       );
//     }
//
//     // Expanded: row with label
//     final row = SizedBox(
//       height: 48.h,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(width: 12),
//           Icon(leaf.icon, size: 20, color: iconColor),
//           const SizedBox(width: 12),
//           Expanded(
//             child: CustomText(
//               text: leaf.label,
//               ellipsisText: true,
//               alignText: TextAlign.left,
//               textStyle: textStyle,
//             ),
//           ),
//         ],
//       ),
//     );
//
//     return Material(
//       color: bg,
//       child: InkWell(
//         onTap: () {
//           widget.onLeafTap(leaf.routeName);
//           if (_isExpanded && !_isMobile) _toggleCollapse();
//         },
//         child: row,
//       ),
//     );
//   }
//
//   // ---------- Group tile ----------
//   Widget _groupTile(int index, _NavGroup group) {
//     final isOpen = _openGroups.contains(index);
//
//     // Collapsed / mobile behavior: single icon with popup; highlight if any child selected
//     if (!_isExpanded || _isMobile) {
//       final theme = Theme.of(context);
//       final selected = _isGroupSelected(group);
//
//       final child = Container(
//         height: 52.h,
//         width: double.infinity,
//         margin: const EdgeInsets.symmetric(vertical: 2),
//         decoration: BoxDecoration(
//           color:
//           selected ? theme.primaryColor.withOpacity(0.12) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border:
//           selected ? Border.all(color: theme.primaryColor, width: 1) : null,
//         ),
//         alignment: Alignment.center,
//         child: Icon(
//           group.icon,
//           size: 22,
//           color: selected ? theme.primaryColor : Colors.grey.shade300,
//         ),
//       );
//
//       return Tooltip(
//         message: group.label,
//         child: PopupMenuButton<_NavLeaf>(
//           tooltip: group.label,
//           offset: const Offset(0, 8),
//           onSelected: (leaf) => widget.onLeafTap(leaf.routeName),
//           itemBuilder: (ctx) => group.children
//               .map((c) => PopupMenuItem(
//             value: c,
//             child: Row(
//               children: [
//                 Icon(c.icon, size: 18),
//                 const SizedBox(width: 8),
//                 Text(c.label),
//               ],
//             ),
//           ))
//               .toList(),
//           child: child,
//         ),
//       );
//     }
//
//     // Expanded header (click to open/close)
//     final header = Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             if (isOpen) {
//               _openGroups.remove(index);
//             } else {
//               _openGroups = {index}; // single-open behavior
//             }
//           });
//         },
//         child: SizedBox(
//           height: 52.h,
//           child: Row(
//             children: [
//               const SizedBox(width: 12),
//               Icon(group.icon, size: 20, color: Colors.grey.shade300),
//               if (_isExpanded && !_isMobile) const SizedBox(width: 12),
//               if (_isExpanded && !_isMobile)
//                 Expanded(
//                   child: CustomText(
//                     text: group.label,
//                     ellipsisText: true,
//                     alignText: TextAlign.left,
//                     textStyle: context.text14Regular.copyWith(
//                       color: context.grayD9TextColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               if (_isExpanded && !_isMobile)
//                 AnimatedRotation(
//                   turns: isOpen ? 0.5 : 0.0,
//                   duration: animationDuration,
//                   child: Icon(Icons.expand_more, color: Colors.grey.shade300),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     // Expanded children (animated)
//     final children = ClipRect(
//       child: AnimatedAlign(
//         alignment: Alignment.topCenter,
//         duration: animationDuration,
//         heightFactor: isOpen && _isExpanded && !_isMobile ? 1 : 0,
//         child: Column(
//           children: group.children
//               .map((leaf) => Padding(
//             padding: EdgeInsets.only(
//               left: _isExpanded && !_isMobile ? 12.w : 0,
//               right: 6.w,
//             ),
//             child: _leafTile(leaf),
//           ))
//               .toList(),
//         ),
//       ),
//     );
//
//     return Column(
//       children: [
//         header,
//         children,
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return AnimatedContainer(
//       duration: animationDuration,
//       width: _calculateWidth(context),
//       margin: const EdgeInsets.all(20),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 3,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: context.gray86TextColor.withOpacity(0.3),
//                   blurRadius: 6,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Column(
//                   children: [
//                     // Header
//                     SizedBox(
//                       height: 84,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CircleAvatar(
//                               radius: 20,
//                               backgroundColor: theme.primaryColor,
//                               child: const Icon(Icons.person, color: Colors.white),
//                             ),
//                             if (!_isMobile && _isExpanded) const SizedBox(width: 12),
//                             if (!_isMobile && _isExpanded)
//                               Expanded(
//                                 child: CustomText(
//                                   text: 'Moot Dashboard',
//                                   alignText: TextAlign.left,
//                                   textStyle: context.text16Medium,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const Divider(height: 1),
//
//                     // Nav list
//                     Expanded(
//                       child: ListView(
//                         padding: EdgeInsets.zero,
//                         children: [
//                           // Overview (top-level)
//                           Padding(
//                             padding: EdgeInsets.only(
//                               left: _isExpanded && !_isMobile ? 0 : 0,
//                               right: 0,
//                             ),
//                             child: _leafTile(widget.overview),
//                           ),
//                           const Divider(height: 1),
//
//                           // Groups
//                           ...List.generate(
//                             widget.groups.length,
//                                 (i) => _groupTile(i, widget.groups[i]),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const Divider(height: 1),
//
//                     // Footer (user + logout)
//                     Padding(
//                       padding:
//                       EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 20.h,
//                             backgroundColor: Colors.grey.shade300,
//                             child: const Icon(Icons.person_outline,
//                                 color: Colors.black54),
//                           ),
//                           if (!_isMobile && _isExpanded) const SizedBox(width: 12),
//                           if (!_isMobile && _isExpanded)
//                             Expanded(
//                               child: CustomText(
//                                 alignText: TextAlign.left,
//                                 text: 'Hanan Khalid',
//                                 textStyle: context.text16Medium,
//                                 ellipsisText: true,
//                               ),
//                             ),
//                           if (!_isMobile && _isExpanded)
//                             IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.logout,
//                                   color: Colors.grey.shade300),
//                               tooltip: 'Logout',
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//
//                 // Collapse handle (desktop only)
//                 if (!_isMobile)
//                   Positioned(
//                     right: -12,
//                     top: MediaQuery.of(context).size.height / 2 - 24,
//                     child: GestureDetector(
//                       onTap: _toggleCollapse,
//                       child: CircleAvatar(
//                         radius: 24,
//                         backgroundColor: theme.primaryColor,
//                         child: Icon(
//                           _isExpanded ? Icons.chevron_left : Icons.chevron_right,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// extension on List<String> {
//   String? get lastOrNull => isEmpty ? null : last;
// }
