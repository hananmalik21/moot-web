import 'dart:developer';
import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/domain/repositories/business_units_repository.dart';

class BusinessUnitsRepositoryImpl extends BusinessUnitsRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<BusinessUnitsResponse> getBusinessUnits({
    String? companyId,
    String? businessUnitId,
  }) async {
    log("id her is $companyId");
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.businessUnitsUrl,
        params: {
          if (companyId != null) "companyId": companyId,
          if (businessUnitId != null) "businessUnitId": businessUnitId,
        },
      );

      return BusinessUnitsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteBusinessUnit({
    required String businessUnitId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.businessUnitsUrl}/$businessUnitId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createBusinessUnit({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.businessUnitsUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateBusinessUnit({
    required String businessUnitId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.businessUnitsUrl}/$businessUnitId",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
