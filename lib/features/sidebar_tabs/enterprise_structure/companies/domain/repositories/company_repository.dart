import 'package:moot_web/core/data/response/base_response_model.dart';
import 'package:moot_web/features/sidebar_tabs/enterprise_structure/companies/data/model/company_model.dart';

abstract class CompanyRepository {
  Future<BaseApiResponseModel> createCompany({
    required Map<String, dynamic> body,
  });

  Future<CompaniesResponse> getCompanies({String? companyId});

  Future<BaseApiResponseModel> deleteCompany({required String companyId});

  Future<BaseApiResponseModel> updateCompany({
    required String companyId,
    required Map<String, dynamic> body,
  });
}
