import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';

abstract class DepartmentRepository {
  Future<BaseApiResponseModel> createDepartment({
    required Map<String, dynamic> body,
  });

  Future<DepartmentsModel> getDepartments({String? businessUnitId});

  Future<BaseApiResponseModel> deleteDepartment({required String departmentId});

  Future<BaseApiResponseModel> updateDepartment({
    required String departmentId,
    required Map<String, dynamic> body,
  });
}
