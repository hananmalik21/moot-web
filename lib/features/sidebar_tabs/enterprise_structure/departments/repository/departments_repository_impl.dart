import 'dart:developer';
import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/data/models/department_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/departments/domain/repositories/department_repository.dart';

class DepartmentsRepositoryImpl extends DepartmentRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<BaseApiResponseModel> createDepartment({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.departmentsUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<DepartmentsModel> getDepartments({String? businessUnitId}) async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.departmentsUrl,
        params: {
          if(businessUnitId!=null)"businessUnitId":businessUnitId
        }
        // params: {
        //   "limit": 10,
        //   "offset": offset,
        //   if ((orderNumber ?? "").isNotEmpty) searchParam: orderNumber,
        //   if ((salesPersonId).isNotEmpty) "SALESPERSON_ID": salesPersonId,
        // },
      );

      return DepartmentsModel.fromJson(response);
    } catch (e,stacktrace) {
      log("error is ${stacktrace.toString()}");
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteDepartment({
    required String departmentId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.departmentsUrl}/$departmentId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateDepartment({
    required String departmentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      log("body is $body");
      var response = await _baseService.put(
        url: "${ApiEndPoints.departmentsUrl}/$departmentId",
        body: body
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
