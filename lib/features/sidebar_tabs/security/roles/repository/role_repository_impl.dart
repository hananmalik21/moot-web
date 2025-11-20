import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/domain/repositories/role_repository.dart';

class RolesRepositoryImpl extends RoleRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<RolesResponse> getRoles() async {
    try {
      var response = await _baseService.get(url: ApiEndPoints.rolesUrl);

      return RolesResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteRole({required String roleId}) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.rolesUrl}/$roleId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createRole({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.rolesUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateRole({
    required String roleId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.rolesUrl}/$roleId",
        body: body,
      );
      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
