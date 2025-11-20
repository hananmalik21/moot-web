import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/roles/data/models/role_model.dart';

abstract class RoleRepository {
  Future<BaseApiResponseModel> createRole({required Map<String, dynamic> body});

  Future<RolesResponse> getRoles();

  Future<BaseApiResponseModel> deleteRole({required String roleId});

  Future<BaseApiResponseModel> updateRole({
    required String roleId,
    required Map<String, dynamic> body,
  });
}
