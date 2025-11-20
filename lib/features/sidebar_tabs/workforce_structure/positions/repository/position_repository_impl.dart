import 'dart:developer';
import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/data/model/position_model.dart';
import 'package:moot_web/features/sidebar_tabs/workforce_structure/positions/domain/repositories/position_repository.dart';

class PositionRepositoryImpl extends PositionsRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<PositionResponse> getPositions({String? departmentId,String? positionId}) async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.positionUrl,
        params: {
          if (departmentId != null) "departmentId": departmentId,
          if (positionId != null) "positionId": positionId

        },
        // params: {
        //   "limit": 10,
        //   "offset": offset,
        //   if ((orderNumber ?? "").isNotEmpty) searchParam: orderNumber,
        //   if ((salesPersonId).isNotEmpty) "SALESPERSON_ID": salesPersonId,
        // },
      );

      return PositionResponse.fromJson(response);
    } catch (e, stacktrace) {
      log("error is ${stacktrace.toString()}");
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deletePosition({
    required String positionId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.positionUrl}/$positionId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createPosition({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.positionUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updatePosition({
    required String positionId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.positionUrl}/$positionId",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
