import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/data/models/user_response.dart';

abstract class UserRepository {
  Future<BaseApiResponseModel> createUser({required Map<String, dynamic> body});

  Future<UsersResponse> getUsers({String? userId});

  Future<BaseApiResponseModel> deleteUser({required String userId});

  Future<BaseApiResponseModel> updateUser({
    required Map<String, dynamic> body,
    required String userId,
  });

  Future<BaseApiResponseModel> assignRoleToEmployee({
    required String userId,
    required Map<String, dynamic> body,
  });

  Future<BaseApiResponseModel> removeRoleFromEmployee({
    required String userId,
    required Map<String, dynamic> body,
  });
}
