import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/domain/repositories/permission_repository.dart';

class PermissionsRepositoryImpl extends PermissionRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<PermissionsResponse> getPermissions({String? permissionId}) async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.permissionsUrl,
        params: {if (permissionId != null) "permissionId": permissionId},
      );

      return PermissionsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deletePermission({
    required String permissionId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.permissionsUrl}/$permissionId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createPermission({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.permissionsUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updatePermission({
    required String permissionId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.permissionsUrl}/$permissionId",
        body: body,
      );
      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
