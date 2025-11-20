import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moot_web/features/auth/login/presentation/view/login_view.dart';
import 'package:moot_web/features/auth/sign_up/presentation/view/sign_up_view.dart';
import 'package:moot_web/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:moot_web/features/loading_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/view/business_unit_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/view/business_units_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/presentation/view/create_business_units_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/view/company_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/view/company_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/presentation/view/create_company_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/create_departments/view/create_departments_view.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/presentation/departments/view/department_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/view/assign_role_to_user.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/view/create_user_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/view/user_detail_page.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/presentation/view/users_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/view/create_permission_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/view/permission_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/presentation/view/permissions_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/view/create_role_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/view/role_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/presentation/view/roles_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/view/create_grade_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/view/grade_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/grades/presentation/view/grades_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/view/create_job_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/view/job_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/jobs/presentation/view/jobs_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/view/create_location_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/view/location_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/locations/presentation/view/locations_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/view/create_position_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/view/position_detail_view.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/presentation/view/position_view.dart';

import '../../features/sidebar_tabs/enterprise_structure/departments/presentation/departments/view/departments_view.dart'
    show DepartmentsView;

/// A global key for GoRouter navigation access (optional but handy)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration with ShellRoute and web-like transitions
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  // initialLocation: '/login',
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      name: 'loading',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SessionLoadingView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SignupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/departments/create',
      name: 'create-departments',
      pageBuilder: (context, state) =>
          _fadePage(const CreateDepartmentsView(), state),
    ),
    GoRoute(
      path: '/departments/edit/:id',
      name: 'edit-departments',
      pageBuilder: (context, state) =>
          _fadePage(const CreateDepartmentsView(), state),
    ),
    GoRoute(
      path: '/jobs/create',
      name: 'create-jobs',
      pageBuilder: (context, state) => _fadePage(const CreateJobsView(), state),
    ),
    GoRoute(
      path: '/jobs/edit/:id',
      name: 'edit-jobs',
      pageBuilder: (context, state) => _fadePage(const CreateJobsView(), state),
    ),
    GoRoute(
      path: '/grade/create',
      name: 'create-grade',
      pageBuilder: (context, state) =>
          _fadePage(const CreateGradeView(), state),
    ),
    GoRoute(
      path: '/grade/edit/:id',
      name: 'edit-grade',
      pageBuilder: (context, state) =>
          _fadePage(const CreateGradeView(), state),
    ),
    GoRoute(
      path: '/position/create',
      name: 'create-position',
      pageBuilder: (context, state) =>
          _fadePage(const CreatePositionView(), state),
    ),
    GoRoute(
      path: '/position/edit/:id',
      name: 'edit-position',
      pageBuilder: (context, state) =>
          _fadePage(const CreatePositionView(), state),
    ),
    GoRoute(
      path: '/location/create',
      name: 'create-location',
      pageBuilder: (context, state) =>
          _fadePage(const CreateLocationView(), state),
    ),
    GoRoute(
      path: '/location/edit/:id',
      name: 'edit-location',
      pageBuilder: (context, state) =>
          _fadePage(const CreateLocationView(), state),
    ),
    GoRoute(
      path: '/create-users',
      name: 'create-user',
      pageBuilder: (context, state) => _fadePage(const CreateUserView(), state),
    ),
    GoRoute(
      path: '/users/edit/:id',
      name: 'edit-user',
      pageBuilder: (context, state) => _fadePage(const CreateUserView(), state),
    ),
    GoRoute(
      path: '/create-role',
      name: 'create-role',
      pageBuilder: (context, state) => _fadePage(const CreateRoleView(), state),
    ),
    GoRoute(
      path: '/role/edit/:id',
      name: 'edit-role',
      pageBuilder: (context, state) => _fadePage(const CreateRoleView(), state),
    ),
    GoRoute(
      path: '/create-permission',
      name: 'create-permission',
      pageBuilder: (context, state) =>
          _fadePage(const CreatePermissionView(), state),
    ),
    GoRoute(
      path: '/permission/edit/:id',
      name: 'edit-permission',
      pageBuilder: (context, state) =>
          _fadePage(const CreatePermissionView(), state),
    ),
    GoRoute(
      path: '/create-company',
      name: 'create-company',
      pageBuilder: (context, state) =>
          _fadePage(const CreateCompanyView(), state),
    ),
    GoRoute(
      path: '/company/edit/:id',
      name: 'edit-company',
      pageBuilder: (context, state) =>
          _fadePage(const CreateCompanyView(), state),
    ),
    GoRoute(
      path: '/create-business-units',
      name: 'create-business-units',
      pageBuilder: (context, state) =>
          _fadePage(const CreateBusinessUnitView(), state),
    ),
    GoRoute(
      path: '/business-units/edit/:id',
      name: 'edit-business-units',
      pageBuilder: (context, state) =>
          _fadePage(const CreateBusinessUnitView(), state),
    ),
    GoRoute(
      path: '/user/assign-role/:id',
      name: 'assign-role',
      pageBuilder: (context, state) =>
          _fadePage(const AssignRoleToUser(), state),
    ),
    GoRoute(
      path: '/user/detail/:id',
      name: 'user-detail',
      pageBuilder: (context, state) => _fadePage(const UserDetailPage(), state),
    ),
    GoRoute(
      path: '/role/detail/:id',
      name: 'role-detail',
      pageBuilder: (context, state) => _fadePage(const RoleDetailPage(), state),
    ),
    GoRoute(
      path: '/permission/detail/:id',
      name: 'permission-detail',
      pageBuilder: (context, state) =>
          _fadePage(const PermissionDetailPage(), state),
    ),
    GoRoute(
      path: '/company/detail/:id',
      name: 'company-detail',
      pageBuilder: (context, state) =>
          _fadePage(const CompanyDetailPage(), state),
    ),
    GoRoute(
      path: '/business-unit/detail/:id',
      name: 'business-unit-detail',
      pageBuilder: (context, state) =>
          _fadePage(const BusinessUnitDetailPage(), state),
    ),
    GoRoute(
      path: '/department-detail/detail/:id',
      name: 'department-detail',
      pageBuilder: (context, state) =>
          _fadePage(const DepartmentDetailPage(), state),
    ),
    GoRoute(
      path: '/job-detail/detail/:id',
      name: 'job-detail',
      pageBuilder: (context, state) => _fadePage(const JobDetailPage(), state),
    ),
    GoRoute(
      path: '/grade-detail/detail/:id',
      name: 'grade-detail',
      pageBuilder: (context, state) =>
          _fadePage(const GradeDetailPage(), state),
    ),
    GoRoute(
      path: '/position-detail/detail/:id',
      name: 'position-detail',
      pageBuilder: (context, state) =>
          _fadePage(const PositionDetailPage(), state),
    ),
    GoRoute(
      path: '/location-detail/detail/:id',
      name: 'location-detail',
      pageBuilder: (context, state) =>
          _fadePage(const LocationDetailPage(), state),
    ),

    /// Persistent dashboard layout
    ShellRoute(
      builder: (context, state, child) {
        return DashboardShell(child: child); // Sidebar + content
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) =>
              _fadePage(const DepartmentsView(), state),
        ),
        GoRoute(
          path: '/roles',
          name: 'roles',
          pageBuilder: (context, state) => _fadePage(const RolesView(), state),
        ),
        GoRoute(
          path: '/permissions',
          name: 'permissions',
          pageBuilder: (context, state) =>
              _fadePage(const PermissionsView(), state),
        ),
        GoRoute(
          path: '/companies',
          name: 'companies',
          pageBuilder: (context, state) =>
              _fadePage(const CompanyView(), state),
        ),
        GoRoute(
          path: '/business-units',
          name: 'business-units',
          pageBuilder: (context, state) =>
              _fadePage(const BusinessUnitView(), state),
        ),
        GoRoute(
          path: '/departments',
          name: 'departments',
          pageBuilder: (context, state) =>
              _fadePage(const DepartmentsView(), state),
        ),
        GoRoute(
          path: '/jobs',
          name: 'jobs',
          pageBuilder: (context, state) => _fadePage(const JobsView(), state),
        ),
        GoRoute(
          path: '/positions',
          name: 'positions',
          pageBuilder: (context, state) =>
              _fadePage(const PositionView(), state),
        ),
        GoRoute(
          path: '/grades',
          name: 'grades',
          pageBuilder: (context, state) => _fadePage(const GradesView(), state),
        ),
        GoRoute(
          path: '/locations',
          name: 'locations',
          pageBuilder: (context, state) =>
              _fadePage(const LocationsView(), state),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          pageBuilder: (context, state) => _fadePage(const UsersView(), state),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        '404 - Page Not Found',
        style: const TextStyle(color: Colors.white),
      ),
    ),
    backgroundColor: Colors.black,
  ),
);

/// Helper function for fade transition
CustomTransitionPage _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
