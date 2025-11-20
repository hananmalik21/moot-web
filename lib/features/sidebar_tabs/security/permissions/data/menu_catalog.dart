import 'package:moot_web/core/model/permission_menu.dart';

// ===== Menu Key Constants =====
const _WF = 'workforce_structure';
const _EM = 'employee_management';
const _ES = 'enterprise_structure';
const _SEC = 'security';

// ===== Workforce Structure =====
final Menu kWorkforceStructureMenu = Menu(
  menuName: 'Workforce Structure',
  permissionKey: '$_WF.*',
  subMenus: const [
    SubMenu(name: 'Job', baseKey: '$_WF.job'),
    SubMenu(name: 'Grade', baseKey: '$_WF.grade'),
    SubMenu(name: 'Position', baseKey: '$_WF.position'),
    SubMenu(name: 'Location', baseKey: '$_WF.location'),
  ],
);

// ===== Enterprise Structure =====
final Menu kEnterpriseStructureMenu = Menu(
  menuName: 'Enterprise Structure',
  permissionKey: '$_ES.*',
  subMenus: const [
    SubMenu(name: 'Company', baseKey: '$_ES.company'),
    SubMenu(name: 'Business Units', baseKey: '$_ES.business_unit'),
    SubMenu(name: 'Departments', baseKey: '$_ES.department'),
  ],
);

// ===== Security =====
final Menu kSecurityMenu = Menu(
  menuName: 'Security',
  permissionKey: '$_SEC.*',
  subMenus: const [
    SubMenu(name: 'Roles', baseKey: '$_SEC.role'),
    SubMenu(name: 'Permissions', baseKey: '$_SEC.permission'),
    SubMenu(name: 'Users', baseKey: '$_SEC.user'),
  ],
);

// ===== Employee Management =====
final Menu kEmployeeManagementMenu = Menu(
  menuName: 'Employee Management',
  permissionKey: '$_EM.*',
  subMenus: const [
    SubMenu(name: 'Employee Information', baseKey: '$_EM.employee_information'),
    SubMenu(name: 'Employee Assignments', baseKey: '$_EM.employee_assignments'),
    SubMenu(name: 'Employee Contacts', baseKey: '$_EM.employee_contacts'),
    SubMenu(name: 'Employee Work Relationships', baseKey: '$_EM.employee_work_relationships'),
  ],
);

// ===== Complete Menu Catalog =====
final List<Menu> kMenuCatalog = [
  kEnterpriseStructureMenu,
  kWorkforceStructureMenu,
  // kEmployeeManagementMenu,
  kSecurityMenu,
];
