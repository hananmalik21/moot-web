import 'dart:developer';
import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/data/models/user_response.dart';
import 'package:moot_web/features/sidebar_tabs/security/employees/domain/repositories/user_repository.dart';

class UsersRepositoryImpl extends UserRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<BaseApiResponseModel> createUser({
    required Map<String, dynamic> body,
  }) async {
    log("body is $body");
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.registerUserUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UsersResponse> getUsers({String? userId}) async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.usersUrl,
        params: {if ((userId ?? "").isNotEmpty) "userId": userId},
      );

      return UsersResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteUser({required String userId}) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.usersUrl}/$userId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateUser({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.usersUrl}/$userId",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> assignRoleToEmployee({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.usersUrl}/$userId/role-department",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> removeRoleFromEmployee({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.usersUrl}/$userId/role-department",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
