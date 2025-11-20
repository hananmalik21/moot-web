import 'package:moot_web/core/data/network/api_endpoints.dart';
import 'package:moot_web/core/data/network/base_api_service.dart';
import 'package:moot_web/core/data/network/network_api.dart';
import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl extends CompanyRepository {
  final BaseService _baseService = NetworkApi();

  @override
  Future<CompaniesResponse> getCompanies({String? companyId}) async {
    try {
      var response = await _baseService.get(
        url: ApiEndPoints.companiesUrl,
        params: {if (companyId != null) "companyId": companyId},
      );

      return CompaniesResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> deleteCompany({
    required String companyId,
  }) async {
    try {
      var response = await _baseService.delete(
        url: "${ApiEndPoints.companiesUrl}/$companyId",
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> createCompany({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.post(
        url: ApiEndPoints.companiesUrl,
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BaseApiResponseModel> updateCompany({
    required String companyId,
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _baseService.put(
        url: "${ApiEndPoints.companiesUrl}/$companyId",
        body: body,
      );

      return BaseApiResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
