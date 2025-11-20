import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/model/user_data_model.dart';
import 'package:moot_web/features/auth/login/domain/repositories/login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      var value = await _baseService.post(
        url: ApiEndPoints.signInUrl,
        body: {"emailOrEmployeeId": email, "password": password},
      );
      return AuthModel.fromJson(value);
    } catch (e, stacktrace) {
      if (kDebugMode) {
        log("error is $e");
        log("error is ${stacktrace.toString()}");
      }
      rethrow;
    }
  }
}
