import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/permissions/data/models/permission_model.dart';

abstract class PermissionRepository {
  Future<BaseApiResponseModel> createPermission({required Map<String, dynamic> body});

  Future<PermissionsResponse> getPermissions({String? permissionId});

  Future<BaseApiResponseModel> deletePermission({required String permissionId});

  Future<BaseApiResponseModel> updatePermission({
    required String permissionId,
    required Map<String, dynamic> body,
  });
}
