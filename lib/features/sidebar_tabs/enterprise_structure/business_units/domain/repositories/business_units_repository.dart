import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/business_units/data/model/business_unit_model.dart';

abstract class BusinessUnitsRepository {
  Future<BaseApiResponseModel> createBusinessUnit({
    required Map<String, dynamic> body,
  });

  Future<BusinessUnitsResponse> getBusinessUnits({
    String? companyId,
    String? businessUnitId,
  });

  Future<BaseApiResponseModel> deleteBusinessUnit({
    required String businessUnitId,
  });

  Future<BaseApiResponseModel> updateBusinessUnit({
    required String businessUnitId,
    required Map<String, dynamic> body,
  });
}
